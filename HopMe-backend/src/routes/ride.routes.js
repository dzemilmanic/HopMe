import express from 'express';
import RideController from '../controllers/ride.controller.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/roleCheck.js';

const router = express.Router();

/**
 * @swagger
 * /rides/search:
 *   get:
 *     tags:
 *       - Rides
 *     summary: Pretraga vožnji
 *     parameters:
 *       - in: query
 *         name: from
 *         schema:
 *           type: string
 *         description: Polazna lokacija
 *       - in: query
 *         name: to
 *         schema:
 *           type: string
 *         description: Dolazna lokacija
 *       - in: query
 *         name: date
 *         schema:
 *           type: string
 *           format: date
 *         description: Datum vožnje (YYYY-MM-DD)
 *       - in: query
 *         name: seats
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Broj potrebnih mesta
 *       - in: query
 *         name: maxPrice
 *         schema:
 *           type: number
 *         description: Maksimalna cena po mestu
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Broj stranice
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *         description: Broj rezultata po stranici
 *     responses:
 *       200:
 *         description: Lista vožnji
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 rides:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Ride'
 *                 count:
 *                   type: integer
 *                 page:
 *                   type: integer
 */
router.get('/search', RideController.searchRides);

/**
 * @swagger
 * /rides/{rideId}:
 *   get:
 *     tags:
 *       - Rides
 *     summary: Detalji vožnje
 *     parameters:
 *       - in: path
 *         name: rideId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Detalji vožnje
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Ride'
 *       404:
 *         description: Vožnja nije pronađena
 */
router.get('/:rideId', RideController.getRideDetails);

/**
 * @swagger
 * /rides:
 *   post:
 *     tags:
 *       - Rides
 *     summary: Kreiranje nove vožnje (samo vozači)
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - vehicleId
 *               - departureLocation
 *               - arrivalLocation
 *               - departureTime
 *               - availableSeats
 *               - pricePerSeat
 *             properties:
 *               vehicleId:
 *                 type: integer
 *               departureLocation:
 *                 type: string
 *               departureLat:
 *                 type: number
 *               departureLng:
 *                 type: number
 *               arrivalLocation:
 *                 type: string
 *               arrivalLat:
 *                 type: number
 *               arrivalLng:
 *                 type: number
 *               departureTime:
 *                 type: string
 *                 format: date-time
 *               arrivalTime:
 *                 type: string
 *                 format: date-time
 *               availableSeats:
 *                 type: integer
 *               pricePerSeat:
 *                 type: number
 *               description:
 *                 type: string
 *               autoAcceptBookings:
 *                 type: boolean
 *               allowSmoking:
 *                 type: boolean
 *               allowPets:
 *                 type: boolean
 *               maxTwoInBack:
 *                 type: boolean
 *               luggageSize:
 *                 type: string
 *               waypoints:
 *                 type: array
 *                 items:
 *                   type: object
 *     responses:
 *       201:
 *         description: Vožnja kreirana
 *       403:
 *         description: Nemate vozačku ulogu
 */
router.post(
  '/',
  authenticate,
  requireRole('vozac'),
  RideController.createRide
);

/**
 * @swagger
 * /rides/driver/my-rides:
 *   get:
 *     tags:
 *       - Rides
 *     summary: Sve vožnje vozača
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista vožnji vozača
 */
router.get(
  '/driver/my-rides',
  authenticate,
  requireRole('vozac'),
  RideController.getDriverRides
);

/**
 * @swagger
 * /rides/{rideId}/cancel:
 *   post:
 *     tags:
 *       - Rides
 *     summary: Otkazivanje vožnje
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
 *         description: Vožnja otkazana
 */
router.post(
  '/:rideId/cancel',
  authenticate,
  requireRole('vozac'),
  RideController.cancelRide
);

/**
 * @swagger
 * /rides/{rideId}/start:
 *   post:
 *     tags:
 *       - Rides
 *     summary: Početak vožnje
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
 *         description: Vožnja započeta
 */
router.post(
  '/:rideId/start',
  authenticate,
  requireRole('vozac'),
  RideController.startRide
);

/**
 * @swagger
 * /rides/{rideId}/complete:
 *   post:
 *     tags:
 *       - Rides
 *     summary: Završetak vožnje
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
 *         description: Vožnja završena
 */
router.post(
  '/:rideId/complete',
  authenticate,
  requireRole('vozac'),
  RideController.completeRide
);

export default router;