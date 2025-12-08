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
 *     summary: Kreiranje ocene
 *     description: Putnik ocenjuje vozača ili vozač ocenjuje putnika nakon završene vožnje
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
 *                 example: "Odličan vozač, preporučujem!"
 *     responses:
 *       201:
 *         description: Ocena kreirana
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
 *         description: Ne možete oceniti (već ocenjeno, vožnja nije završena)
 */
router.post('/', RatingController.createRating);

/**
 * @swagger
 * /ratings/user/{userId}:
 *   get:
 *     tags:
 *       - Ratings
 *     summary: Sve ocene korisnika sa statistikom
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
 *         description: Ocene i statistika
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
 *     summary: Ocene koje je trenutni korisnik dao drugima
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista ocena
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Rating'
 */
router.get('/my-ratings', RatingController.getMyRatings);

export default router;