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
 *     summary: Searches for rides
 *     parameters:
 *       - in: query
 *         name: from
 *         schema:
 *           type: string
 *         description: Starting location
 *       - in: query
 *         name: to
 *         schema:
 *           type: string
 *         description: Destination location
 *       - in: query
 *         name: date
 *         schema:
 *           type: string
 *           format: date
 *         description: Ride date (YYYY-MM-DD)
 *       - in: query
 *         name: seats
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Number of seats needed
 *       - in: query
 *         name: maxPrice
 *         schema:
 *           type: number
 *         description: Maximum price per seat
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Page number
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *         description: Number of results per page
 *     responses:
 *       200:
 *         description: List of rides
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
 *     summary: Gets ride details
 *     parameters:
 *       - in: path
 *         name: rideId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Ride details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Ride'
 *       404:
 *         description: Ride not found
 */
router.get('/:rideId', RideController.getRideDetails);

/**
 * @swagger
 * /rides:
 *   post:
 *     tags:
 *       - Rides
 *     summary: Creates a new ride (only drivers)
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
 *         description: Ride created
 *       403:
 *         description: You do not have a driver role
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
 *     summary: Gets all rides of the driver
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of driver's rides
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
 *     summary: Cancels a ride
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
 *         description: Ride cancelled
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
 *     summary: Starts a ride
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
 *         description: Ride started
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
 *     summary: Completes a ride
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
 *         description: Ride completed
 */
router.post(
  '/:rideId/complete',
  authenticate,
  requireRole('vozac'),
  RideController.completeRide
);

export default router;