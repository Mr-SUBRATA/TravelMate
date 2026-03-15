import { Request, Response } from 'express';
import { getAuth } from '@clerk/express';
import User from '../models/User';

export const syncUser = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = getAuth(req);
    const { name, email } = req.body;

    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    let user = await User.findOne({ clerkId: userId });

    if (!user) {
      user = await User.create({
        clerkId: userId,
        name,
        email
      });
    }

    res.status(200).json({ message: 'User synced', user });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};