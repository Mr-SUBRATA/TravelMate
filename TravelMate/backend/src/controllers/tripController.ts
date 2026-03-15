import { Request, Response } from 'express';
import { getAuth } from '@clerk/express';
import Trip from '../models/Trip';

// Save a trip
export const saveTrip = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = getAuth(req);

    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const {
      destinationCity,
      destinationCountry,
      startDate,
      endDate,
      groupSize,
      totalBudget
    } = req.body;

    const trip = await Trip.create({
      userId,
      destinationCity,
      destinationCountry,
      startDate,
      endDate,
      groupSize,
      totalBudget
    });

    res.status(201).json({ message: 'Trip saved', trip });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// Get all trips of logged in user
export const getMyTrips = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = getAuth(req);

    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const trips = await Trip.find({ userId }).sort({ createdAt: -1 });

    res.status(200).json({ trips });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

// Delete a trip
export const deleteTrip = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = getAuth(req);

    if (!userId) {
      res.status(401).json({ message: 'Unauthorized' });
      return;
    }

    const trip = await Trip.findOneAndDelete({
      _id: req.params.id,
      userId
    });

    if (!trip) {
      res.status(404).json({ message: 'Trip not found' });
      return;
    }

    res.status(200).json({ message: 'Trip deleted' });

  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};