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
 *     summary: Gets all users that are pending approval
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of pending users
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/User'
 *       403:
 *         description: You do not have admin access
 */
router.get('/users/pending', AdminController.getPendingUsers);

/**
 * @swagger
 * /admin/users:
 *   get:
 *     tags:
 *       - Admin
 *     summary: Gets all users with filters
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
 *         description: List of users
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
 *     summary: Gets user details with vehicles
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
 *         description: User details with vehicles
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
 *         description: User not found
 */
router.get('/users/:userId', AdminController.getUserDetails);

/**
 * @swagger
 * /admin/users/{userId}/approve:
 *   post:
 *     tags:
 *       - Admin
 *     summary: Approves a user account
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
 *         description: User approved
 *       400:
 *         description: User is not in pending status or email is not verified
 *       404:
 *         description: User not found
 */
router.post('/users/:userId/approve', AdminController.approveUser);

/**
 * @swagger
 * /admin/users/{userId}/reject:
 *   post:
 *     tags:
 *       - Admin
 *     summary: Rejects a user account
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
 *         description: User rejected
 *       404:
 *         description: User not found
 */
router.post('/users/:userId/reject', AdminController.rejectUser);

/**
 * @swagger
 * /admin/users/{userId}/suspend:
 *   post:
 *     tags:
 *       - Admin
 *     summary: Suspends a user account
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
 *         description: User suspended
 *       404:
 *         description: User not found
 */
router.post('/users/:userId/suspend', AdminController.suspendUser);

/**
 * @swagger
 * /admin/create-admin:
 *   post:
 *     tags:
 *       - Admin
 *     summary: Creates a new admin account (only admin can create)
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
 *         description: Admin created
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
 *         description: Email already exists
 */
router.post(
  '/create-admin',
  validateRegistration,
  handleValidationErrors,
  AdminController.createAdmin
);

export default router;
