import express from 'express';
import RatingController from '../controllers/rating.controller.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticate);

router.post('/', RatingController.createRating);
router.get('/user/:userId', RatingController.getUserRatings);
router.get('/my-ratings', RatingController.getMyRatings);

export default router;