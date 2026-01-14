import express from 'express';
import RatingController from '../controllers/rating.controller.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticate);

/**
 * @swagger
 * /ratings:
 *   post:
 *     tags:
 *       - Ratings
 *     summary: Creates a rating
 *     description: Passenger rates the driver or the driver rates the passenger after the ride
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - bookingId
 *               - rideId
 *               - rating
 *             properties:
 *               bookingId:
 *                 type: integer
 *                 example: 1
 *               rideId:
 *                 type: integer
 *                 example: 1
 *               rating:
 *                 type: integer
 *                 minimum: 1
 *                 maximum: 5
 *                 example: 5
 *               comment:
 *                 type: string
 *                 example: "Excellent driver, I recommend!"
 *     responses:
 *       201:
 *         description: Rating created
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 rating:
 *                   $ref: '#/components/schemas/Rating'
 *       400:
 *         description: You cannot rate (already rated, ride not completed)
 */
router.post('/', RatingController.createRating);

/**
 * @swagger
 * /ratings/user/{userId}:
 *   get:
 *     tags:
 *       - Ratings
 *     summary: Gets all ratings for a user with statistics
 *     security:    
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Ratings and statistics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 ratings:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Rating'
 *                 stats:
 *                   type: object
 *                   properties:
 *                     totalRatings:
 *                       type: integer
 *                       example: 25
 *                     averageRating:
 *                       type: number
 *                       format: double
 *                       example: 4.8
 *                     fiveStar:
 *                       type: integer
 *                       example: 20
 *                     fourStar:
 *                       type: integer
 *                       example: 3
 *                     threeStar:
 *                       type: integer
 *                       example: 1
 *                     twoStar:
 *                       type: integer
 *                       example: 1
 *                     oneStar:
 *                       type: integer
 *                       example: 0
 */
router.get('/user/:userId', RatingController.getUserRatings);

/**
 * @swagger
 * /ratings/my-ratings:
 *   get:
 *     tags:
 *       - Ratings
 *     summary: Gets all ratings made by the current user
 *     security:    
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of ratings
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Rating'
 */
router.get('/my-ratings', RatingController.getMyRatings);

/**
 * @swagger
 * /ratings/all-my-ratings:
 *   get:
 *     tags:
 *       - Ratings
 *     summary: Gets all ratings made by and received by the current user
 *     description: Returns all ratings received from others and all ratings given to others
 *     security:    
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Ratings and statistics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 receivedRatings:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Rating'
 *                 givenRatings:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Rating'
 *                 stats:
 *                   type: object
 *                   properties:
 *                     total_received:
 *                       type: integer
 *                       example: 25
 *                     average_received:
 *                       type: number
 *                       format: double
 *                       example: 4.8
 *                     total_given:
 *                       type: integer
 *                       example: 15
 */
router.get('/all-my-ratings', RatingController.getAllMyRatings);

export default router;