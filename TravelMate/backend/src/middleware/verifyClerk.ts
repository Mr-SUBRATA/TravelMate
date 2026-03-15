import { clerkMiddleware, getAuth } from '@clerk/express';
import { Request, Response, NextFunction } from 'express';

export const requireAuth = (req: Request, res: Response, next: NextFunction): void => {
  const auth = getAuth(req);
  
  if (!auth.userId) {
    res.status(401).json({ message: 'Unauthorized' });
    return;
  }

  next();
};

export default clerkMiddleware();