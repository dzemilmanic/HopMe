import express from 'express';
import { body } from 'express-validator';
import TestimonialController from '../controllers/testimonial.controller.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

// Validation rules
const testimonialValidation = [
  body('rating')
    .isInt({ min: 1, max: 5 })
    .withMessage('Ocena mora biti između 1 i 5'),
  body('text')
    .trim()
    .isLength({ min: 10, max: 500 })
    .withMessage('Tekst mora biti između 10 i 500 karaktera')
];

// Public routes
router.get('/', TestimonialController.getAllTestimonials);

// Protected routes (authenticated users)
router.use(authenticate);

router.post('/', testimonialValidation, TestimonialController.createTestimonial);
router.get('/my', TestimonialController.getMyTestimonial);
router.put('/my', testimonialValidation, TestimonialController.updateMyTestimonial);
router.delete('/my', TestimonialController.deleteMyTestimonial);

// Admin routes
router.delete('/:id', authorize('admin'), TestimonialController.deleteTestimonial);

export default router;
