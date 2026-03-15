import { Router } from 'express';
import { savePreference, getPreference } from '../controllers/preferenceController';
import { requireAuth } from '../middleware/verifyClerk';

const router = Router();

router.post('/save', requireAuth, savePreference);
router.get('/', requireAuth, getPreference);

export default router;