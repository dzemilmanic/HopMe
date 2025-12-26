import bcrypt from 'bcryptjs';
import User from '../models/User.js';
import Vehicle from '../models/Vehicle.js';
import VerificationToken from '../models/VerificationToken.js';
import EmailService from '../services/email.service.js';
import TokenService from '../services/token.service.js';
import AzureService from '../services/azure.service.js';

class AuthController {
  // Registracija putnika
  static async registerPassenger(req, res) {
    try {
      const { email, password, firstName, lastName, phone } = req.body;

      const existingUser = await User.findByEmail(email);
      if (existingUser) {
        return res.status(400).json({ message: 'Email već postoji' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      const user = await User.create({
        email,
        password: hashedPassword,
        firstName,
        lastName,
        phone,
        roles: ['putnik']
      });

      const verificationToken = await VerificationToken.create(
        user.id, 
        'email_verification'
      );

      // Fire-and-forget email sending - don't block response
      EmailService.sendVerificationEmail(email, verificationToken.token, firstName)
        .catch(err => console.error('Failed to send verification email:', err));

      res.status(201).json({
        message: 'Registracija uspešna. Proverite email za verifikaciju.',
        userId: user.id
      });
    } catch (error) {
      console.error('Greška pri registraciji putnika:', error);
      res.status(500).json({ message: 'Greška pri registraciji' });
    }
  }

  // Registracija vozača
  static async registerDriver(req, res) {
    try {
      const { 
        email, password, firstName, lastName, phone,
        vehicleType, brand, model, year, licensePlate, color
      } = req.body;

      const existingUser = await User.findByEmail(email);
      if (existingUser) {
        return res.status(400).json({ message: 'Email već postoji' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      const user = await User.create({
        email,
        password: hashedPassword,
        firstName,
        lastName,
        phone,
        roles: ['vozac']
      });

      const vehicle = await Vehicle.create({
        userId: user.id,
        vehicleType,
        brand,
        model,
        year,
        licensePlate,
        color
      });

      // Upload slika vozila ako postoje
      if (req.files && req.files.length > 0) {
        for (let i = 0; i < req.files.length; i++) {
          const file = req.files[i];
          const { url, blobName } = await AzureService.uploadImage(file);
          await Vehicle.addImage(vehicle.id, url, blobName, i === 0);
        }
      }

      const verificationToken = await VerificationToken.create(
        user.id, 
        'email_verification'
      );

      // Fire-and-forget email sending - don't block response
      EmailService.sendVerificationEmail(email, verificationToken.token, firstName)
        .catch(err => console.error('Failed to send verification email:', err));

      res.status(201).json({
        message: 'Registracija vozača uspešna. Proverite email za verifikaciju.',
        userId: user.id,
        vehicleId: vehicle.id
      });
    } catch (error) {
      console.error('Greška pri registraciji vozača:', error);
      res.status(500).json({ message: 'Greška pri registraciji' });
    }
  }

  // Verifikacija email-a
  static async verifyEmail(req, res) {
    try {
      const { token } = req.query;

      const verificationToken = await VerificationToken.findByToken(token);
      
      if (!verificationToken) {
        return res.status(400).json({ 
          message: 'Nevažeći ili istekao verifikacioni token' 
        });
      }

      await User.updateEmailVerification(verificationToken.user_id);
      await VerificationToken.deleteByUserId(
        verificationToken.user_id, 
        'email_verification'
      );

      res.json({ 
        message: 'Email uspešno verifikovan. Sada možete sačekati odobrenje administratora.' 
      });
    } catch (error) {
      console.error('Greška pri verifikaciji email-a:', error);
      res.status(500).json({ message: 'Greška pri verifikaciji' });
    }
  }

  // Prijava korisnika
  static async login(req, res) {
    try {
      const { email, password } = req.body;

      const user = await User.findByEmail(email);
      
      if (!user) {
        return res.status(401).json({ message: 'Nevalidni kredencijali' });
      }

      const isPasswordValid = await bcrypt.compare(password, user.password);
      
      if (!isPasswordValid) {
        return res.status(401).json({ message: 'Nevalidni kredencijali' });
      }

      if (!user.is_email_verified) {
        return res.status(403).json({ 
          message: 'Email nije verifikovan. Proverite vaš inbox.' 
        });
      }

      if (user.account_status !== 'approved') {
        return res.status(403).json({ 
          message: 'Vaš nalog još uvek čeka odobrenje administratora.' 
        });
      }

      const token = TokenService.generateAccessToken(
        user.id, 
        user.email, 
        user.roles
      );

      // Parse PostgreSQL array string to proper array
      // PostgreSQL returns "{putnik}" but iOS expects ["putnik"]
      const parseRoles = (roles) => {
        if (Array.isArray(roles)) return roles;
        if (typeof roles === 'string') {
          // Remove curly braces and split by comma
          return roles.replace(/[{}]/g, '').split(',').filter(r => r.trim());
        }
        return [];
      };

      res.json({
        token,
        user: {
          id: user.id,
          email: user.email,
          firstName: user.first_name,
          lastName: user.last_name,
          phone: user.phone,
          roles: parseRoles(user.roles)
        }
      });
    } catch (error) {
      console.error('Greška pri prijavi:', error);
      res.status(500).json({ message: 'Greška pri prijavi' });
    }
  }

  // Zahtev za resetovanje lozinke
  static async requestPasswordReset(req, res) {
    try {
      const { email } = req.body;

      const user = await User.findByEmail(email);
      
      if (!user) {
        return res.json({ 
          message: 'Ako email postoji, link za resetovanje će biti poslat.' 
        });
      }

      await VerificationToken.deleteByUserId(user.id, 'password_reset');

      const resetToken = await VerificationToken.create(
        user.id, 
        'password_reset',
        1 // Ističe za 1 sat
      );

      await EmailService.sendPasswordResetEmail(
        email,
        resetToken.token,
        user.first_name
      );

      res.json({ 
        message: 'Ako email postoji, link za resetovanje će biti poslat.' 
      });
    } catch (error) {
      console.error('Greška pri zahtevu za reset:', error);
      res.status(500).json({ message: 'Greška pri zahtevu' });
    }
  }

  // Resetovanje lozinke
  static async resetPassword(req, res) {
    try {
      const { token, newPassword } = req.body;

      const resetToken = await VerificationToken.findByToken(token);
      
      if (!resetToken) {
        return res.status(400).json({ 
          message: 'Nevažeći ili istekao token za resetovanje' 
        });
      }

      const hashedPassword = await bcrypt.hash(newPassword, 10);
      
      await pool.query(
        'UPDATE users SET password = $1 WHERE id = $2',
        [hashedPassword, resetToken.user_id]
      );

      await VerificationToken.deleteByUserId(
        resetToken.user_id, 
        'password_reset'
      );

      res.json({ message: 'Lozinka uspešno promenjena' });
    } catch (error) {
      console.error('Greška pri resetovanju lozinke:', error);
      res.status(500).json({ message: 'Greška pri resetovanju' });
    }
  }

  // Dodavanje uloge vozača postojećem putniku
  static async addDriverRole(req, res) {
    try {
      const userId = req.user.id;
      const { 
        vehicleType, brand, model, year, licensePlate, color
      } = req.body;

      const user = await User.findById(userId);
      
      if (user.roles.includes('vozac')) {
        return res.status(400).json({ 
          message: 'Već imate ulogu vozača' 
        });
      }

      await User.addRole(userId, 'vozac');

      const vehicle = await Vehicle.create({
        userId,
        vehicleType,
        brand,
        model,
        year,
        licensePlate,
        color
      });

      if (req.files && req.files.length > 0) {
        for (let i = 0; i < req.files.length; i++) {
          const file = req.files[i];
          const { url, blobName } = await AzureService.uploadImage(file);
          await Vehicle.addImage(vehicle.id, url, blobName, i === 0);
        }
      }

      res.json({
        message: 'Uloga vozača uspešno dodata',
        vehicleId: vehicle.id
      });
    } catch (error) {
      console.error('Greška pri dodavanju uloge vozača:', error);
      res.status(500).json({ message: 'Greška pri dodavanju uloge' });
    }
  }
}

export default AuthController;