import express from 'express';
import AdminController from '../controllers/admin.controller.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/roleCheck.js';
import { validateRegistration, handleValidationErrors } from '../utils/validators.js';

const router = express.Router();

router.use(authenticate);
router.use(requireRole('admin'));

/**
 * @swagger
 * /admin/users/pending:
 *   get:
 *     tags:
 *       - Admin
 *     summary: Svi korisnici koji čekaju odobrenje
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista pending korisnika
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/User'
 *       403:
 *         description: Nemate admin pristup
 */
router.get('/users/pending', AdminController.getPendingUsers);

/**
 * @swagger
 * /admin/users:
 *   get:
 *     tags:
 *       - Admin
 *     summary: Svi korisnici sa filterima
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [pending, approved, rejected, suspended]
 *         description: Filter po statusu
 *       - in: query
 *         name: role
 *         schema:
 *           type: string
 *           enum: [putnik, vozac, admin]
 *         description: Filter po ulozi
 *     responses:
 *       200:
 *         description: Lista korisnika
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/User'
 */
router.get('/users', AdminController.getAllUsers);

/**
 * @swagger
 * /admin/users/{userId}:
 *   get:
 *     tags:
 *       - Admin
 *     summary: Detalji korisnika sa vozilima
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
 *         description: Detalji korisnika
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/User'
 *                 - type: object
 *                   properties:
 *                     vehicles:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/Vehicle'
 *       404:
 *         description: Korisnik nije pronađen
 */
router.get('/users/:userId', AdminController.getUserDetails);

/**
 * @swagger
 * /admin/users/{userId}/approve:
 *   post:
 *     tags:
 *       - Admin
 *     summary: Odobravanje korisničkog naloga
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
 *         description: Korisnik odobren
 *       400:
 *         description: Korisnik nije u pending statusu ili email nije verifikovan
 *       404:
 *         description: Korisnik nije pronađen
 */
router.post('/users/:userId/approve', AdminController.approveUser);

/**
 * @swagger
 * /admin/users/{userId}/reject:
 *   post:
 *     tags:
 *       - Admin
 *     summary: Odbijanje korisničkog naloga
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
 *         description: Korisnik odbijen
 *       404:
 *         description: Korisnik nije pronađen
 */
router.post('/users/:userId/reject', AdminController.rejectUser);

/**
 * @swagger
 * /admin/users/{userId}/suspend:
 *   post:
 *     tags:
 *       - Admin
 *     summary: Suspendovanje korisničkog naloga
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
 *         description: Korisnik suspendovan
 *       404:
 *         description: Korisnik nije pronađen
 */
router.post('/users/:userId/suspend', AdminController.suspendUser);

/**
 * @swagger
 * /admin/create-admin:
 *   post:
 *     tags:
 *       - Admin
 *     summary: Kreiranje novog admin naloga (samo admin može)
 *     security:
 *       - bearerAuth: []
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
 *         description: Admin kreiran
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 adminId:
 *                   type: integer
 *       400:
 *         description: Email već postoji
 */
router.post(
  '/create-admin',
  validateRegistration,
  handleValidationErrors,
  AdminController.createAdmin
);

export default router;
