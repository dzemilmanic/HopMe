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
 *     summary: Kreiranje rezervacije
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
 *         description: Rezervacija kreirana
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
 *         description: Greška (nema mesta, već postoji rezervacija)
 *       404:
 *         description: Vožnja nije pronađena
 */
router.post('/', BookingController.createBooking);

/**
 * @swagger
 * /bookings/my-bookings:
 *   get:
 *     tags:
 *       - Bookings
 *     summary: Sve rezervacije trenutnog korisnika
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
 *     summary: Detalji rezervacije
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
 *         description: Detalji rezervacije
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Booking'
 *       404:
 *         description: Rezervacija nije pronađena
 */
router.get('/:bookingId', BookingController.getBookingDetails);

/**
 * @swagger
 * /bookings/{bookingId}/cancel:
 *   post:
 *     tags:
 *       - Bookings
 *     summary: Otkazivanje rezervacije (putnik)
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
 *         description: Rezervacija otkazana
 *       400:
 *         description: Ne može se otkazati nakon početka vožnje
 *       403:
 *         description: Nemate pristup ovoj rezervaciji
 */
router.post('/:bookingId/cancel', BookingController.cancelBooking);

/**
 * @swagger
 * /bookings/ride/{rideId}:
 *   get:
 *     tags:
 *       - Bookings
 *     summary: Sve rezervacije za vožnju (samo vozač)
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
 *         description: Lista rezervacija
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Booking'
 *       403:
 *         description: Nemate pristup ovoj vožnji
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
 *     summary: Prihvatanje rezervacije (samo vozač)
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
 *         description: Rezervacija prihvaćena
 *       400:
 *         description: Rezervacija već obrađena ili nema mesta
 *       403:
 *         description: Nemate pristup ovoj rezervaciji
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
 *     summary: Odbijanje rezervacije (samo vozač)
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
 *         description: Rezervacija odbijena
 *       400:
 *         description: Rezervacija već obrađena
 *       403:
 *         description: Nemate pristup ovoj rezervaciji
 */
router.post(
  '/:bookingId/reject',
  requireRole('vozac'),
  BookingController.rejectBooking
);

export default router;