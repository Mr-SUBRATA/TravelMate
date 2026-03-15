import { Request, Response } from 'express';
import { getAuth } from '@clerk/express';
import { getWeather } from '../services/weatherService';
import { getRecommendations } from '../services/mlServices';
import { getPlaces } from '../services/placesService';
import Recommendation from '../models/Recommendation';
import Trip from '../models/Trip';

export const generateRecommendations = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = getAuth(req);

    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const {
      destination,
      destinationCountry,
      startDate,
      endDate,
      groupSize,
      totalBudget,
      quizAnswers,
      top_k
    } = req.body;

    // Step 1 - Save trip to MongoDB
    const trip = await Trip.create({
      userId,
      destinationCity: destination,
      destinationCountry,
      startDate,
      endDate,
      groupSize,
      totalBudget,
      status: 'planning'
    });

    // Step 2 - Get weather for destination
    const weather = await getWeather(destination);

    // Step 3 - Get places from Geoapify
    const places = await getPlaces(destination);

    // Step 4 - Call ML service
    const mlResponse = await getRecommendations({
      user_id: userId,
      quiz_answers: quizAnswers,
      destination,
      weather,
      places,
      top_k: top_k || 5
    });

    // Step 5 - Save recommendations to MongoDB
    const savedRecommendations = await Promise.all(
      mlResponse.recommendations.map(async (rec, index: number) => {
        return await Recommendation.create({
          tripId: trip._id,
          placeId: rec.id,
          placeName: rec.name,
          placeTypes: rec.categories,
          matchScore: rec.match_score * 100,
          mlScoreDetails: rec.scores,
          outdoor: rec.outdoor,
          rankPosition: index + 1
        });
      })
    );

    // Step 6 - Send back to Flutter
    res.status(200).json({
      message: 'Recommendations generated',
      trip,
      weather,
      recommendations: savedRecommendations
    });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};