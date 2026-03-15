import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import clerkMiddleware from './middleware/verifyClerk';
import connectDB from './config/database';
import userRoutes from './routes/userRoutes';
import tripRoutes from './routes/tripRoutes';
import preferenceRoutes from './routes/preferenceRoutes';
import recommendationRoutes from './routes/recommendationRoutes';
import feedbackRoutes from './routes/feedbackRoutes';


dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());
app.use(clerkMiddleware);

connectDB();

// Routes
app.use('/api/user', userRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/preferences', preferenceRoutes);
app.use('/api/recommendations', recommendationRoutes);
app.use('/api/feedback', feedbackRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Server is running!' });
});
app.get('/api/test/weather/:city', async (req, res) => {
    try {
      const { getWeather } = require('./services/weatherService');
      const weather = await getWeather(req.params.city);
      res.status(200).json({ weather });
    } catch (error) {
      console.log('WEATHER ERROR:', error);
      res.status(500).json({ message: 'Server error', error: String(error) });
    }
  });
  // TEMPORARY TEST ROUTE - remove after testing
app.get('/api/test/places/:city', async (req, res) => {
  try {
    const { getPlaces } = require('./services/placesService');
    const places = await getPlaces(req.params.city);
    res.status(200).json({ places });
  } catch (error) {
    console.log('PLACES ERROR:', error);
    res.status(500).json({ message: 'Server error', error: String(error) });
  }
});
app.post('/api/test/recommend', async (req, res) => {
  try {
    const { getWeather } = require('./services/weatherService');
    const { getPlaces } = require('./services/placesService');
    const { getRecommendations } = require('./services/mlService');

    const { destination, quizAnswers } = req.body;

    // Get weather
    const weather = await getWeather(destination);

    // Get places
    const places = await getPlaces(destination);

    // Call ML service
    const mlResponse = await getRecommendations({
      user_id: 'test_user',
      quiz_answers: quizAnswers,
      destination,
      weather,
      places,
      top_k: 5
    });

    res.status(200).json({ weather, places, mlResponse });

  } catch (error) {
    console.log('RECOMMEND ERROR:', error);
    res.status(500).json({ message: 'Server error', error: String(error) });
  }
});

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;