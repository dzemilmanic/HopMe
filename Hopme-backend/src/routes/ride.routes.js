import express from 'express';
import RideController from '../controllers/ride.controller.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/roleCheck.js';

const router = express.Router();

// Javne rute
router.get('/search', RideController.searchRides);
router.get('/:rideId', RideController.getRideDetails);

// Zaštićene rute - vozači
router.post(
  '/',
  authenticate,
  requireRole('vozac'),
  RideController.createRide
);

router.get(
  '/driver/my-rides',
  authenticate,
  requireRole('vozac'),
  RideController.getDriverRides
);

router.put(
  '/:rideId',
  authenticate,
  requireRole('vozac'),
  RideController.updateRide
);

router.post(
  '/:rideId/cancel',
  authenticate,
  requireRole('vozac'),
  RideController.cancelRide
);

router.delete(
  '/:rideId',
  authenticate,
  requireRole('vozac'),
  RideController.deleteRide
);

router.post(
  '/:rideId/start',
  authenticate,
  requireRole('vozac'),
  RideController.startRide
);

router.post(
  '/:rideId/complete',
  authenticate,
  requireRole('vozac'),
  RideController.completeRide
);

export default router;