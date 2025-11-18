import express from 'express';
import BookingController from '../controllers/booking.controller.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/roleCheck.js';

const router = express.Router();

router.use(authenticate);

// Putnik rute
router.post('/', BookingController.createBooking);

router.get('/my-bookings', BookingController.getPassengerBookings);

router.post('/:bookingId/cancel', BookingController.cancelBooking);

router.get('/:bookingId', BookingController.getBookingDetails);

// Vozač rute
router.get(
  '/ride/:rideId',
  requireRole('vozac'),
  BookingController.getRideBookings
);

router.post(
  '/:bookingId/accept',
  requireRole('vozac'),
  BookingController.acceptBooking
);

router.post(
  '/:bookingId/reject',
  requireRole('vozac'),
  BookingController.rejectBooking
);

export default router;