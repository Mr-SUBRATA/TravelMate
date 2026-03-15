import { Router } from 'express';
import { saveTrip, getMyTrips, deleteTrip } from '../controllers/tripController';
import { requireAuth } from '../middleware/verifyClerk';

const router = Router();

router.post('/save', requireAuth, saveTrip);
router.get('/mytrips', requireAuth, getMyTrips);
router.delete('/:id', requireAuth, deleteTrip);

export default router;