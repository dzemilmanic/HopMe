import Notification from '../models/Notification.js';

class NotificationController {
  static async getNotifications(req, res) {
    try {
      const userId = req.user.id;
      const { limit } = req.query;

      const notifications = await Notification.findByUserId(
        userId, 
        limit ? parseInt(limit) : 50
      );

      res.json(notifications);
    } catch (error) {
      console.error('Greška:', error);
      res.status(500).json({ message: 'Greška' });
    }
  }

  static async markAsRead(req, res) {
    try {
      const { notificationId } = req.params;
      const userId = req.user.id;

      await Notification.markAsRead(notificationId, userId);

      res.json({ message: 'Notifikacija označena kao pročitana' });
    } catch (error) {
      console.error('Greška:', error);
      res.status(500).json({ message: 'Greška' });
    }
  }

  static async markAllAsRead(req, res) {
    try {
      const userId = req.user.id;

      await Notification.markAllAsRead(userId);

      res.json({ message: 'Sve notifikacije označene kao pročitane' });
    } catch (error) {
      console.error('Greška:', error);
      res.status(500).json({ message: 'Greška' });
    }
  }

  static async getUnreadCount(req, res) {
    try {
      const userId = req.user.id;

      const count = await Notification.getUnreadCount(userId);

      res.json({ count });
    } catch (error) {
      console.error('Greška:', error);
      res.status(500).json({ message: 'Greška' });
    }
  }

  static async deleteNotification(req, res) {
    try {
      const { notificationId } = req.params;
      const userId = req.user.id;

      await Notification.delete(notificationId, userId);

      res.json({ message: 'Notifikacija obrisana' });
    } catch (error) {
      console.error('Greška:', error);
      res.status(500).json({ message: 'Greška' });
    }
  }
}

export default NotificationController;