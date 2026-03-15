import { Router } from 'express';
import { generateRecommendations } from '../controllers/recommendationController';
import { requireAuth } from '../middleware/verifyClerk';

const router = Router();

router.post('/generate', requireAuth, generateRecommendations);

export default router;