import { Router } from 'express';
import { saveFeedback, getMyFeedback } from '../controllers/feedbackController';
import { requireAuth } from '../middleware/verifyClerk';

const router = Router();

router.post('/save', requireAuth, saveFeedback);
router.get('/', requireAuth, getMyFeedback);

export default router;