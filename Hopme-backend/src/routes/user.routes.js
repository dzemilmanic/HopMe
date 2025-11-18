import express from 'express';
import UserController from '../controllers/user.controller.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/roleCheck.js';
import { upload } from '../middleware/upload.js';
import { validateVehicle, handleValidationErrors } from '../utils/validators.js';

const router = express.Router();

// Sve rute zahtevaju autentifikaciju
router.use(authenticate);

// Profil rute
router.get('/profile', UserController.getProfile);
router.put('/profile', UserController.updateProfile);

// Vozila rute (samo za vozače)
router.get('/vehicles', UserController.getVehicles);

router.post(
  '/vehicles',
  requireRole('vozac'),
  upload.array('vehicleImages', 5),
  validateVehicle,
  handleValidationErrors,
  UserController.addVehicle
);

router.put(
  '/vehicles/:vehicleId',
  requireRole('vozac'),
  UserController.updateVehicle
);

router.post(
  '/vehicles/:vehicleId/images',
  requireRole('vozac'),
  upload.array('vehicleImages', 5),
  UserController.addVehicleImages
);

router.delete(
  '/vehicles/:vehicleId/images/:imageId',
  requireRole('vozac'),
  UserController.deleteVehicleImage
);

router.delete(
  '/vehicles/:vehicleId',
  requireRole('vozac'),
  UserController.deleteVehicle
);

export default router;