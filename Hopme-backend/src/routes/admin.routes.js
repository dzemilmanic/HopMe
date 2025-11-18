import express from 'express';
import AdminController from '../controllers/admin.controller.js';
import { authenticate } from '../middleware/auth.js';
import { requireRole } from '../middleware/roleCheck.js';
import { validateRegistration, handleValidationErrors } from '../utils/validators.js';

const router = express.Router();

// Sve rute zahtevaju admin ulogu
router.use(authenticate);
router.use(requireRole('admin'));

router.get('/users/pending', AdminController.getPendingUsers);
router.get('/users', AdminController.getAllUsers);
router.get('/users/:userId', AdminController.getUserDetails);

router.post('/users/:userId/approve', AdminController.approveUser);
router.post('/users/:userId/reject', AdminController.rejectUser);
router.post('/users/:userId/suspend', AdminController.suspendUser);

router.post(
  '/create-admin',
  validateRegistration,
  handleValidationErrors,
  AdminController.createAdmin
);

export default router;