import User from '../models/User.js';
import EmailService from '../services/email.service.js';
import bcrypt from 'bcryptjs';

class AdminController {
  // Pregled svih pending korisnika
  static async getPendingUsers(req, res) {
    try {
      const pendingUsers = await User.findPendingUsers();
      res.json(pendingUsers);
    } catch (error) {
      console.error('Greška pri učitavanju pending korisnika:', error);
      res.status(500).json({ message: 'Greška pri učitavanju' });
    }
  }

  // Odobravanje korisnika
  static async approveUser(req, res) {
    try {
      const { userId } = req.params;
      const adminId = req.user.id;

      const user = await User.findById(userId);
      
      if (!user) {
        return res.status(404).json({ message: 'Korisnik nije pronađen' });
      }

      if (user.account_status !== 'pending') {
        return res.status(400).json({ 
          message: 'Korisnik nije u statusu pending' 
        });
      }

      if (!user.is_email_verified) {
        return res.status(400).json({ 
          message: 'Korisnik mora prvo verifikovati email' 
        });
      }

      await User.updateAccountStatus(userId, 'approved', adminId);

      await EmailService.sendApprovalEmail(
        user.email,
        user.first_name,
        true
      );

      res.json({ message: 'Korisnik uspešno odobren' });
    } catch (error) {
      console.error('Greška pri odobravanju korisnika:', error);
      res.status(500).json({ message: 'Greška pri odobravanju' });
    }
  }

  // Odbijanje korisnika
  static async rejectUser(req, res) {
    try {
      const { userId } = req.params;

      const user = await User.findById(userId);
      
      if (!user) {
        return res.status(404).json({ message: 'Korisnik nije pronađen' });
      }

      await User.updateAccountStatus(userId, 'rejected');

      await EmailService.sendApprovalEmail(
        user.email,
        user.first_name,
        false
      );

      res.json({ message: 'Korisnik odbijen' });
    } catch (error) {
      console.error('Greška pri odbijanju korisnika:', error);
      res.status(500).json({ message: 'Greška pri odbijanju' });
    }
  }

  // Suspendovanje korisnika
  static async suspendUser(req, res) {
    try {
      const { userId } = req.params;

      await User.updateAccountStatus(userId, 'suspended');

      res.json({ message: 'Korisnik suspendovan' });
    } catch (error) {
      console.error('Greška pri suspendovanju:', error);
      res.status(500).json({ message: 'Greška pri suspendovanju' });
    }
  }

  // Kreiranje novog admina (samo admin može)
  static async createAdmin(req, res) {
    try {
      const { email, password, firstName, lastName, phone } = req.body;

      const existingUser = await User.findByEmail(email);
      if (existingUser) {
        return res.status(400).json({ message: 'Email već postoji' });
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

      // Admin se automatski odobrava i verifikuje
      await User.updateEmailVerification(admin.id);
      await User.updateAccountStatus(admin.id, 'approved', req.user.id);

      res.status(201).json({
        message: 'Admin uspešno kreiran',
        adminId: admin.id
      });
    } catch (error) {
      console.error('Greška pri kreiranju admina:', error);
      res.status(500).json({ message: 'Greška pri kreiranju admina' });
    }
  }

  // Pregled svih korisnika sa filterima
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
      console.error('Greška pri učitavanju korisnika:', error);
      res.status(500).json({ message: 'Greška pri učitavanju' });
    }
  }

  // Detalji korisnika sa vozilima
  static async getUserDetails(req, res) {
    try {
      const { userId } = req.params;

      const user = await User.getUserWithVehicles(userId);

      if (!user) {
        return res.status(404).json({ message: 'Korisnik nije pronađen' });
      }

      delete user.password;

      res.json(user);
    } catch (error) {
      console.error('Greška pri učitavanju detalja:', error);
      res.status(500).json({ message: 'Greška pri učitavanju detalja' });
    }
  }
}

export default AdminController;