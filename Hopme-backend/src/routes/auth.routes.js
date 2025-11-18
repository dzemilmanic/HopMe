import express from 'express';
import AuthController from '../controllers/auth.controller.js';
import { authenticate } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';
import { 
  validateRegistration, 
  validateVehicle,
  handleValidationErrors 
} from '../utils/validators.js';

const router = express.Router();

// Javne rute
router.post(
  '/register/passenger',
  validateRegistration,
  handleValidationErrors,
  AuthController.registerPassenger
);

router.post(
  '/register/driver',
  upload.array('vehicleImages', 5),
  validateRegistration,
  validateVehicle,
  handleValidationErrors,
  AuthController.registerDriver
);

router.get('/verify-email', AuthController.verifyEmail);

router.post('/login', AuthController.login);

router.post('/request-password-reset', AuthController.requestPasswordReset);

router.post('/reset-password', AuthController.resetPassword);

// Zaštićene rute
router.post(
  '/add-driver-role',
  authenticate,
  upload.array('vehicleImages', 5),
  validateVehicle,
  handleValidationErrors,
  AuthController.addDriverRole
);

export default router;