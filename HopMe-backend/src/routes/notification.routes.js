import express from 'express';
import NotificationController from '../controllers/notification.controller.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticate);

/**
 * @swagger
 * /notifications:
 *   get:
 *     tags:
 *       - Notifications
 *     summary: Sve notifikacije trenutnog korisnika
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 50
 *         description: Broj notifikacija za učitavanje
 *     responses:
 *       200:
 *         description: Lista notifikacija
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Notification'
 */
router.get('/', NotificationController.getNotifications);

/**
 * @swagger
 * /notifications/unread-count:
 *   get:
 *     tags:
 *       - Notifications
 *     summary: Broj nepročitanih notifikacija
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Broj nepročitanih
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 count:
 *                   type: integer
 *                   example: 5
 */
router.get('/unread-count', NotificationController.getUnreadCount);

/**
 * @swagger
 * /notifications/{notificationId}/read:
 *   post:
 *     tags:
 *       - Notifications
 *     summary: Označi notifikaciju kao pročitanu
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: notificationId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Notifikacija označena kao pročitana
 */
router.post('/:notificationId/read', NotificationController.markAsRead);

/**
 * @swagger
 * /notifications/mark-all-read:
 *   post:
 *     tags:
 *       - Notifications
 *     summary: Označi sve notifikacije kao pročitane
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Sve notifikacije označene kao pročitane
 */
router.post('/mark-all-read', NotificationController.markAllAsRead);

/**
 * @swagger
 * /notifications/{notificationId}:
 *   delete:
 *     tags:
 *       - Notifications
 *     summary: Brisanje notifikacije
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: notificationId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Notifikacija obrisana
 */
router.delete('/:notificationId', NotificationController.deleteNotification);

export default router;