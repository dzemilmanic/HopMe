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

/**
 * @swagger
 * /auth/register/passenger:
 *   post:
 *     tags:
 *       - Auth
 *     summary: Registracija putnika
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - firstName
 *               - lastName
 *               - phone
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               password:
 *                 type: string
 *                 minLength: 6
 *               firstName:
 *                 type: string
 *               lastName:
 *                 type: string
 *               phone:
 *                 type: string
 *     responses:
 *       201:
 *         description: Registracija uspešna
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 userId:
 *                   type: integer
 *       400:
 *         description: Nevalidni podaci
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/register/passenger',
  validateRegistration,
  handleValidationErrors,
  AuthController.registerPassenger
);

/**
 * @swagger
 * /auth/register/driver:
 *   post:
 *     tags:
 *       - Auth
 *     summary: Registracija vozača
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - firstName
 *               - lastName
 *               - phone
 *               - vehicleType
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               firstName:
 *                 type: string
 *               lastName:
 *                 type: string
 *               phone:
 *                 type: string
 *               vehicleType:
 *                 type: string
 *               brand:
 *                 type: string
 *               model:
 *                 type: string
 *               year:
 *                 type: integer
 *               licensePlate:
 *                 type: string
 *               color:
 *                 type: string
 *               vehicleImages:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       201:
 *         description: Registracija vozača uspešna
 */
router.post(
  '/register/driver',
  upload.array('vehicleImages', 5),
  validateRegistration,
  validateVehicle,
  handleValidationErrors,
  AuthController.registerDriver
);

/**
 * @swagger
 * /auth/verify-email:
 *   get:
 *     tags:
 *       - Auth
 *     summary: Verifikacija email adrese
 *     parameters:
 *       - in: query
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         description: Verifikacioni token
 *     responses:
 *       200:
 *         description: Email uspešno verifikovan
 *       400:
 *         description: Nevažeći token
 */
router.get('/verify-email', AuthController.verifyEmail);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     tags:
 *       - Auth
 *     summary: Prijava korisnika
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Prijava uspešna
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token:
 *                   type: string
 *                 user:
 *                   $ref: '#/components/schemas/User'
 *       401:
 *         description: Nevalidni kredencijali
 *       403:
 *         description: Nalog nije verifikovan ili odobren
 */
router.post('/login', AuthController.login);

/**
 * @swagger
 * /auth/request-password-reset:
 *   post:
 *     tags:
 *       - Auth
 *     summary: Zahtev za resetovanje lozinke
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *     responses:
 *       200:
 *         description: Email sa linkom poslat
 */
router.post('/request-password-reset', AuthController.requestPasswordReset);

/**
 * @swagger
 * /auth/reset-password:
 *   post:
 *     tags:
 *       - Auth
 *     summary: Resetovanje lozinke
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *               - newPassword
 *             properties:
 *               token:
 *                 type: string
 *               newPassword:
 *                 type: string
 *                 minLength: 6
 *     responses:
 *       200:
 *         description: Lozinka uspešno promenjena
 */
router.post('/reset-password', AuthController.resetPassword);

/**
 * @swagger
 * /auth/add-driver-role:
 *   post:
 *     tags:
 *       - Auth
 *     summary: Dodavanje vozačke uloge postojećem korisniku
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - vehicleType
 *             properties:
 *               vehicleType:
 *                 type: string
 *               brand:
 *                 type: string
 *               model:
 *                 type: string
 *               vehicleImages:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       200:
 *         description: Uloga vozača dodata
 */
router.post(
  '/add-driver-role',
  authenticate,
  upload.array('vehicleImages', 5),
  validateVehicle,
  handleValidationErrors,
  AuthController.addDriverRole
);

export default router;