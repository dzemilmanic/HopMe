// ============================================
// src/routes/user.routes.js - KOMPLETNO SA SWAGGER-OM
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
 *     summary: Profil trenutnog korisnika
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profil korisnika sa vozilima
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
 *     summary: Ažuriranje profila
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
 *         description: Profil ažuriran
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
 *     summary: Sva vozila trenutnog korisnika
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista vozila
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
 *     summary: Dodavanje novog vozila (samo vozači)
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
 *         description: Vozilo dodato
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Vozilo uspešno dodato" }
 *                 vehicle:
 *                   type: object
 *                   properties:
 *                     id: { type: integer }
 *                     vehicleType: { type: string }
 *       403:
 *         description: Samo vozači mogu dodavati vozila
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
 *     summary: Ažuriranje vozila
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: vehicleId
 *         required: true
 *         schema: { type: integer }
 *         description: ID vozila
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
 *         description: Vozilo ažurirano
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Vozilo uspešno ažurirano" }
 *                 vehicle: { type: object }
 *       404:
 *         description: Vozilo nije pronađeno
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
 *     summary: Dodavanje slika vozilu
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: vehicleId
 *         required: true
 *         schema: { type: integer }
 *         description: ID vozila
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
 *                 description: Maksimalno 5 slika
 *     responses:
 *       200:
 *         description: Slike dodati
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
 *         description: Nema slika za upload
 *       404:
 *         description: Vozilo nije pronađeno
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
 *     summary: Brisanje slike vozila
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: vehicleId
 *         required: true
 *         schema: { type: integer }
 *         description: ID vozila
 *       - in: path
 *         name: imageId
 *         required: true
 *         schema: { type: integer }
 *         description: ID slike
 *     responses:
 *       200:
 *         description: Slika obrisana
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Slika uspešno obrisana" }
 *       403:
 *         description: Nemate pristup ovoj slici
 *       404:
 *         description: Slika nije pronađena
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
 *     summary: Brisanje vozila
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: vehicleId
 *         required: true
 *         schema: { type: integer }
 *         description: ID vozila
 *     responses:
 *       200:
 *         description: Vozilo obrisano
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Vozilo uspešno obrisano" }
 *       400:
 *         description: Ne možete obrisati vozilo koje ima rezervacije
 *       404:
 *         description: Vozilo nije pronađeno
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
 *     summary: Promena lozinke
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
 *         description: Lozinka promenjena
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success: { type: boolean, example: true }
 *                 message: { type: string, example: "Lozinka uspešno promenjena" }
 *       400:
 *         description: Nevalidni podaci
 *       401:
 *         description: Netačna trenutna lozinka
 */
router.post('/change-password', UserController.changePassword);

export default router;