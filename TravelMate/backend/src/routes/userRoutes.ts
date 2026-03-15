import { Router } from 'express';
import { syncUser } from '../controllers/userController';
import { requireAuth } from '../middleware/verifyClerk';

const router = Router();

router.post('/sync',  requireAuth,syncUser);

export default router;