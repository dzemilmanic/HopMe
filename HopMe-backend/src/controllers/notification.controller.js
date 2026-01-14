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
      console.error('❌ Error:', error);
      res.status(500).json({ message: 'Error' });
    }
  }

  static async markAsRead(req, res) {
    try {
      const { notificationId } = req.params;
      const userId = req.user.id;

      await Notification.markAsRead(notificationId, userId);

      res.json({ message: 'Notification marked as read' });
    } catch (error) {
      console.error('❌ Error:', error);
      res.status(500).json({ message: 'Error' });
    }
  }

  static async markAllAsRead(req, res) {
    try {
      const userId = req.user.id;

      await Notification.markAllAsRead(userId);

      res.json({ message: 'All notifications marked as read' });
    } catch (error) {
      console.error('❌ Error:', error);
      res.status(500).json({ message: 'Error' });
    }
  }

  static async getUnreadCount(req, res) {
    try {
      const userId = req.user.id;

      const count = await Notification.getUnreadCount(userId);

      res.json({ count });
    } catch (error) {
      console.error('Error:', error);
      res.status(500).json({ message: 'Error' });
    }
  }

  static async deleteNotification(req, res) {
    try {
      const { notificationId } = req.params;
      const userId = req.user.id;

      await Notification.delete(notificationId, userId);

      res.json({ message: 'Notification deleted' });
    } catch (error) {
      console.error('Error:', error);
      res.status(500).json({ message: 'Error' });
    }
  }
}

export default NotificationController;