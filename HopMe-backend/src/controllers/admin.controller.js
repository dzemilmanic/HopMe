import User from '../models/User.js';
import EmailService from '../services/email.service.js';
import bcrypt from 'bcryptjs';

class AdminController {
  // View all pending users
  static async getPendingUsers(req, res) {
    try {
      const pendingUsers = await User.findPendingUsers();
      res.json(pendingUsers);
    } catch (error) {
      console.error('Error loading pending users:', error);
      res.status(500).json({ message: 'Error loading' });
    }
  }

  // Approve user
  static async approveUser(req, res) {
    try {
      const { userId } = req.params;
      const adminId = req.user.id;

      const user = await User.findById(userId);
      
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }

      if (user.account_status !== 'pending') {
        return res.status(400).json({ 
          message: 'User is not in pending status' 
        });
      }

      if (!user.is_email_verified) {
        return res.status(400).json({ 
          message: 'User must first verify email' 
        });
      }

      await User.updateAccountStatus(userId, 'approved', adminId);

      await EmailService.sendApprovalEmail(
        user.email,
        user.first_name,
        true
      );

      res.json({ message: 'User approved successfully' });
    } catch (error) {
      console.error('Error approving user:', error);
      res.status(500).json({ message: 'Error approving user' });
    }
  }

  // Reject user
  static async rejectUser(req, res) {
    try {
      const { userId } = req.params;

      const user = await User.findById(userId);
      
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }

      await User.updateAccountStatus(userId, 'rejected');

      await EmailService.sendApprovalEmail(
        user.email,
        user.first_name,
        false
      );

      res.json({ message: 'User rejected successfully' });
    } catch (error) {
      console.error('Error rejecting user:', error);
      res.status(500).json({ message: 'Error rejecting user' });
    }
  }

  // Suspend user
  static async suspendUser(req, res) {
    try {
      const { userId } = req.params;

      await User.updateAccountStatus(userId, 'suspended');

      res.json({ message: 'User suspended successfully' });
    } catch (error) {
      console.error('Error suspending user:', error);
      res.status(500).json({ message: 'Error suspending user' });
    }
  }

  // Create new admin (only admin can create)
  static async createAdmin(req, res) {
    try {
      const { email, password, firstName, lastName, phone } = req.body;

      const existingUser = await User.findByEmail(email);
      if (existingUser) {
        return res.status(400).json({ message: 'Email already exists' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      const admin = await User.create({
        email,
        password: hashedPassword,
        firstName,
        lastName,
        phone,
        roles: ['admin']
      });

      // Admin is automatically approved and verified
      await User.updateEmailVerification(admin.id);
      await User.updateAccountStatus(admin.id, 'approved', req.user.id);

      res.status(201).json({
        message: 'Admin successfully created',
        adminId: admin.id
      });
    } catch (error) {
      console.error('Error creating admin:', error);
      res.status(500).json({ message: 'Error creating admin' });
    }
  }

  // View all users with filters
  static async getAllUsers(req, res) {
    try {
      const { status, role } = req.query;
      
      let query = 'SELECT id, email, first_name, last_name, phone, roles, account_status, is_email_verified, created_at FROM users WHERE 1=1';
      const params = [];

      if (status) {
        params.push(status);
        query += ` AND account_status = ${params.length}`;
      }

      if (role) {
        params.push(role);
        query += ` AND ${params.length} = ANY(roles)`;
      }

      query += ' ORDER BY created_at DESC';

      const result = await pool.query(query, params);
      res.json(result.rows);
    } catch (error) {
      console.error('Error loading users:', error);
      res.status(500).json({ message: 'Error loading users' });
    }
  }

  // User details with vehicles
  static async getUserDetails(req, res) {
    try {
      const { userId } = req.params;

      const user = await User.getUserWithVehicles(userId);

      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }

      delete user.password;

      res.json(user);
    } catch (error) {
      console.error('Error loading user details:', error);
      res.status(500).json({ message: 'Error loading user details' });
    }
  }
}

export default AdminController;