import { Request, Response } from 'express';
import { getAuth } from '@clerk/express';
import UserFeedback from '../models/UserFeedback';

// Save feedback
export const saveFeedback = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = getAuth(req);

    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const {
      recommendationId,
      rating,
      actuallyVisited,
      feedbackText,
      mlPredictedScore,
      actualEnjoyment
    } = req.body;

    const feedback = await UserFeedback.create({
      userId,
      recommendationId,
      rating,
      actuallyVisited,
      feedbackText,
      mlPredictedScore,
      actualEnjoyment
    });

    res.status(201).json({ message: 'Feedback saved', feedback });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// Get all feedback by user
export const getMyFeedback = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = getAuth(req);

    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const feedback = await UserFeedback.find({ userId })
      .sort({ createdAt: -1 });

    res.status(200).json({ feedback });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};