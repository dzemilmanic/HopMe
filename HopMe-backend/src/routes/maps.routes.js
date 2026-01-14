import express from 'express';
import MapsController from '../controllers/maps.controller.js';

const router = express.Router();

/**
 * @swagger
 * /maps/geocode:
 *   get:
 *     tags: [Maps]
 *     summary: Converts address to coordinates
 *     parameters:
 *       - in: query
 *         name: address
 *         required: true
 *         schema:
 *           type: string
 *         example: "Beograd, Trg Republike"
 *     responses:
 *       200:
 *         description: Koordinate lokacije
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 lat: { type: number, example: 44.7866 }
 *                 lng: { type: number, example: 20.4489 }
 *                 formattedAddress: { type: string }
 */
router.get('/geocode', MapsController.geocode);

/**
 * @swagger
 * /maps/reverse:
 *   get:
 *     tags: [Maps]
 *     summary: Converts coordinates to address
 *     parameters:
 *       - in: query
 *         name: lat
 *         required: true
 *         schema:
 *           type: number
 *       - in: query
 *         name: lng
 *         required: true
 *         schema:
 *           type: number
 *     responses:
 *       200:
 *         description: Adresa lokacije
 */
router.get('/reverse', MapsController.reverseGeocode);

/**
 * @swagger
 * /maps/route:
 *   post:
 *     tags: [Maps]
 *     summary: Gets route between two points
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [startLat, startLng, endLat, endLng]
 *             properties:
 *               startLat: { type: number, example: 44.7866 }
 *               startLng: { type: number, example: 20.4489 }
 *               endLat: { type: number, example: 45.2671 }
 *               endLng: { type: number, example: 19.8335 }
 *               waypoints:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     lat: { type: number }
 *                     lng: { type: number }
 *     responses:
 *       200:
 *         description: Route with distance and duration
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 distance: { type: string, example: "85.3km" }
 *                 duration: { type: string, example: "1h 15min" }
 *                 geometry: { type: object }
 *                 steps: { type: array }
 */
router.post('/route', MapsController.getRoute);

/**
 * @swagger
 * /maps/distance:
 *   get:
 *     tags: [Maps]
 *     summary: Calculates distance between two points
 *     parameters:
 *       - in: query
 *         name: lat1
 *         required: true
 *         schema: { type: number }
 *       - in: query
 *         name: lng1
 *         required: true
 *         schema: { type: number }
 *       - in: query
 *         name: lat2
 *         required: true
 *         schema: { type: number }
 *       - in: query
 *         name: lng2
 *         required: true
 *         schema: { type: number }
 *     responses:
 *       200:
 *         description: Distance in kilometers
 */
router.get('/distance', MapsController.calculateDistance);

/**
 * @swagger
 * /maps/search:
 *   get:
 *     tags: [Maps]
 *     summary: Autocomplete location search
 *     parameters:
 *       - in: query
 *         name: query
 *         required: true
 *         schema:
 *           type: string
 *         example: "Beograd"
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 5
 *     responses:
 *       200:
 *         description: Lista lokacija
 */
router.get('/search', MapsController.searchLocations);

/**
 * @swagger
 * /maps/nearby:
 *   get:
 *     tags: [Maps]
 *     summary: Gets nearby cities and places
 *     parameters:
 *       - in: query
 *         name: lat
 *         required: true
 *         schema: { type: number }
 *       - in: query
 *         name: lng
 *         required: true
 *         schema: { type: number }
 *       - in: query
 *         name: radius
 *         schema:
 *           type: integer
 *           default: 5000
 *         description: Radius in meters
 *     responses:
 *       200:
 *         description: List of places
 */
router.get('/nearby', MapsController.getNearbyPlaces);

export default router;