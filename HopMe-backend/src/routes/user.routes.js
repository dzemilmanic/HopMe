// ============================================
// src/routes/user.routes.js - COMPLETELY WITH SWAGGER
// ============================================
import express from 'express';
import UserController from '../controllers/user.controller.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/roleCheck.js';
import { upload } from '../middleware/upload.js';
import { validateVehicle, handleValidationErrors } from '../utils/validators.js';

const router = express.Router();

router.use(authenticate);

/**
 * @swagger
 * /user/profile:
 *   get:
 *     tags: [User]
 *     summary: Gets the profile of the current user
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile with vehicles
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id: { type: integer, example: 1 }
 *                 email: { type: string, example: "marko@example.com" }
 *                 firstName: { type: string, example: "Marko" }
 *                 lastName: { type: string, example: "Petrović" }
 *                 phone: { type: string, example: "+381641234567" }
 *                 roles: { type: array, items: { type: string }, example: ["putnik", "vozac"] }
 *                 vehicles:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id: { type: integer }
 *                       vehicleType: { type: string }
 *                       brand: { type: string }
 *                       model: { type: string }
 */
router.get('/profile', UserController.getProfile);

/**
 * @swagger
 * /user/profile:
 *   put:
 *     tags: [User]
 *     summary: Updates the profile of the current user
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               firstName: { type: string, example: "Marko" }
 *               lastName: { type: string, example: "Petrović" }
 *               phone: { type: string, example: "+381641234567" }
 *     responses:
 *       200:
 *         description: Profile updated
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Profil uspešno ažuriran" }
 *                 user:
 *                   type: object
 *                   properties:
 *                     id: { type: integer }
 *                     firstName: { type: string }
 *                     lastName: { type: string }
 */
router.put('/profile', UserController.updateProfile);

/**
 * @swagger
 * /user/vehicles:
 *   get:
 *     tags: [User]
 *     summary: Gets all vehicles of the current user
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of vehicles
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id: { type: integer, example: 1 }
 *                   vehicleType: { type: string, example: "Sedan" }
 *                   brand: { type: string, example: "Volkswagen" }
 *                   model: { type: string, example: "Passat" }
 *                   year: { type: integer, example: 2020 }
 *                   color: { type: string, example: "Plava" }
 *                   seats: { type: integer, example: 5 }
 *                   images:
 *                     type: array
 *                     items:
 *                       type: object
 *                       properties:
 *                         id: { type: integer }
 *                         imageUrl: { type: string }
 *                         isPrimary: { type: boolean }
 */
router.get('/vehicles', UserController.getVehicles);

/**
 * @swagger
 * /user/vehicles:
 *   post:
 *     tags: [User]
 *     summary: Adds a new vehicle (only drivers)
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [vehicleType]
 *             properties:
 *               vehicleType: { type: string, example: "Sedan" }
 *               brand: { type: string, example: "Volkswagen" }
 *               model: { type: string, example: "Passat" }
 *               year: { type: integer, example: 2020 }
 *               licensePlate: { type: string, example: "BG-123-AB" }
 *               color: { type: string, example: "Plava" }
 *               vehicleImages:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       201:
 *         description: Vehicle added
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Vehicle successfully added" }
 *                 vehicle:
 *                   type: object
 *                   properties:
 *                     id: { type: integer }
 *                     vehicleType: { type: string }
 *       403:
 *         description: Only drivers can add vehicles
 */
router.post(
  '/vehicles',
  requireRole('vozac'),
  upload.array('vehicleImages', 5),
  validateVehicle,
  handleValidationErrors,
  UserController.addVehicle
);

/**
 * @swagger
 * /user/vehicles/{vehicleId}:
 *   put:
 *     tags: [User]
 *     summary: Updates a vehicle
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: vehicleId
 *         required: true
 *         schema: { type: integer }
 *         description: ID vehicle
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               vehicleType: { type: string, example: "SUV" }
 *               brand: { type: string, example: "Toyota" }
 *               model: { type: string, example: "RAV4" }
 *               year: { type: integer, example: 2021 }
 *               licensePlate: { type: string, example: "BG-456-CD" }
 *               color: { type: string, example: "Crvena" }
 *     responses:
 *       200:
 *         description: Vehicle updated
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Vehicle successfully updated" }
 *                 vehicle: { type: object }
 *       404:
 *         description: Vehicle not found
 */
router.put(
  '/vehicles/:vehicleId',
  requireRole('vozac'),
  UserController.updateVehicle
);

/**
 * @swagger
 * /user/vehicles/{vehicleId}/images:
 *   post:
 *     tags: [User]
 *     summary: Adds images to a vehicle
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: vehicleId
 *         required: true
 *         schema: { type: integer }
 *         description: ID vehicle
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               vehicleImages:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                 description: Maximum 5 images
 *     responses:
 *       200:
 *         description: Images added
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Slike uspešno dodati" }
 *                 images:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id: { type: integer }
 *                       imageUrl: { type: string }
 *       400:
 *         description: No images for upload
 *       404:
 *         description: Vehicle not found
 */
router.post(
  '/vehicles/:vehicleId/images',
  requireRole('vozac'),
  upload.array('vehicleImages', 5),
  UserController.addVehicleImages
);

/**
 * @swagger
 * /user/vehicles/{vehicleId}/images/{imageId}:
 *   delete:
 *     tags: [User]
 *     summary: Deletes a vehicle image
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: vehicleId
 *         required: true
 *         schema: { type: integer }
 *         description: ID vehicle
 *       - in: path
 *         name: imageId
 *         required: true
 *         schema: { type: integer }
 *         description: ID image
 *     responses:
 *       200:
 *         description: Image deleted
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Image successfully deleted" }
 *       403:
 *         description: You do not have access to this image
 *       404:
 *         description: Image not found
 */
router.delete(
  '/vehicles/:vehicleId/images/:imageId',
  requireRole('vozac'),
  UserController.deleteVehicleImage
);

/**
 * @swagger
 * /user/vehicles/{vehicleId}:
 *   delete:
 *     tags: [User]
 *     summary: Deletes a vehicle
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: vehicleId
 *         required: true
 *         schema: { type: integer }
 *         description: ID vehicle
 *     responses:
 *       200:
 *         description: Vehicle deleted
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Vehicle successfully deleted" }
 *       400:
 *         description: You cannot delete a vehicle that has reservations
 *       404:
 *         description: Vehicle not found
 */
router.delete(
  '/vehicles/:vehicleId',
  requireRole('vozac'),
  UserController.deleteVehicle
);

/**
 * @swagger
 * /user/change-password:
 *   post:
 *     tags: [User]
 *     summary: Changes password
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [currentPassword, newPassword]
 *             properties:
 *               currentPassword: { type: string, example: "stara123" }
 *               newPassword: { type: string, example: "nova123456" }
 *     responses:
 *       200:
 *         description: Password changed
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success: { type: boolean, example: true }
 *                 message: { type: string, example: "Password successfully changed" }
 *       400:
 *         description: Invalid data
 *       401:
 *         description: Invalid current password
 */
router.post('/change-password', UserController.changePassword);

export default router;