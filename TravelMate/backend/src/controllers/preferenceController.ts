import { Request, Response } from 'express';
import { getAuth } from '@clerk/express';
import UserPreference from '../models/UserPreference';

// Save or update user preferences
export const savePreference = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = getAuth(req);

    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const {
      quizAnswers,
      travelPace,
      crowdTolerance,
      budgetRange,
      groupSizePreference,
      dealBreakers
    } = req.body;

    // Update if exists, create if not
    const preference = await UserPreference.findOneAndUpdate(
      { userId },
      {
        userId,
        quizAnswers,
        travelPace,
        crowdTolerance,
        budgetRange,
        groupSizePreference,
        dealBreakers,
        updatedAt: new Date()
      },
      { upsert: true, new: true }
    );

    res.status(200).json({ message: 'Preferences saved', preference });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// Get user preferences
export const getPreference = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = getAuth(req);

    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const preference = await UserPreference.findOne({ userId });

    if (!preference) {
      res.status(404).json({ message: 'No preferences found' });
      return;
    }

    res.status(200).json({ preference });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};