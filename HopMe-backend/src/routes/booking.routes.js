import express from 'express';
import BookingController from '../controllers/booking.controller.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/roleCheck.js';

const router = express.Router();

router.use(authenticate);

/**
 * @swagger
 * /bookings:
 *   post:
 *     tags:
 *       - Bookings
 *     summary: Creates a booking
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - rideId
 *               - seatsBooked
 *             properties:
 *               rideId:
 *                 type: integer
 *                 example: 1
 *               seatsBooked:
 *                 type: integer
 *                 minimum: 1
 *                 example: 2
 *               pickupLocation:
 *                 type: string
 *                 example: "Trg Republike"
 *               dropoffLocation:
 *                 type: string
 *                 example: "Sajmište"
 *               message:
 *                 type: string
 *                 example: "Možete li da me sačekate 5 minuta?"
 *     responses:
 *       201:
 *         description: Booking created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 booking:
 *                   $ref: '#/components/schemas/Booking'
 *       400:
 *         description: Error (no seats available, booking already exists)
 *       404:
 *         description: Ride not found
 */
router.post('/', BookingController.createBooking);

/**
 * @swagger
 * /bookings/my-bookings:
 *   get:
 *     tags:
 *       - Bookings
 *     summary: All bookings of the current user
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [pending, accepted, rejected, cancelled, completed]
 *         description: Filter po statusu
 *     responses:
 *       200:
 *         description: Lista rezervacija
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Booking'
 */
router.get('/my-bookings', BookingController.getPassengerBookings);

/**
 * @swagger
 * /bookings/{bookingId}:
 *   get:
 *     tags:
 *       - Bookings
 *     summary: Booking details
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Booking details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Booking'
 *       404:
 *         description: Booking not found
 */
router.get('/:bookingId', BookingController.getBookingDetails);

/**
 * @swagger
 * /bookings/{bookingId}/cancel:
 *   post:
 *     tags:
 *       - Bookings
 *     summary: Cancel booking (passenger)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Booking cancelled successfully
 *       400:
 *         description: Cannot cancel booking after ride has started
 *       403:
 *         description: You do not have access to this booking
 */
router.post('/:bookingId/cancel', BookingController.cancelBooking);

/**
 * @swagger
 * /bookings/ride/{rideId}:
 *   get:
 *     tags:
 *       - Bookings
 *     summary: All bookings for a ride (only driver)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: rideId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: List of bookings for a ride
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Booking'
 *       403:
 *         description: You do not have access to this ride
 */
router.get(
  '/ride/:rideId',
  requireRole('vozac'),
  BookingController.getRideBookings
);

/**
 * @swagger
 * /bookings/{bookingId}/accept:
 *   post:
 *     tags:
 *       - Bookings
 *     summary: Accept booking (only driver)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               response:
 *                 type: string
 *                 example: "Vidimo se! Dolazim na vreme."
 *     responses:
 *       200:
 *         description: Booking accepted
 *       400:
 *         description: Booking already processed or no seats available
 *       403:
 *         description: You do not have access to this booking
 */
router.post(
  '/:bookingId/accept',
  requireRole('vozac'),
  BookingController.acceptBooking
);

/**
 * @swagger
 * /bookings/{bookingId}/reject:
 *   post:
 *     tags:
 *       - Bookings
 *     summary: Reject booking (only driver)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               response:
 *                 type: string
 *                 example: "Žao mi je, već imam druge putanje."
 *     responses:
 *       200:
 *         description: Booking rejected
 *       400:
 *         description: Booking already processed
 *       403:
 *         description: You do not have access to this booking
 */
router.post(
  '/:bookingId/reject',
  requireRole('vozac'),
  BookingController.rejectBooking
);

export default router;