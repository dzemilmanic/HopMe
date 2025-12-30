import User from '../models/User.js';
import Vehicle from '../models/Vehicle.js';
import AzureService from '../services/azure.service.js';
import pool from '../config/database.js';
import bcrypt from 'bcryptjs';
import { formatUserResponse, formatVehicleResponse } from '../utils/responseFormatter.js';

class UserController {
  // Dobijanje profila trenutnog korisnika
  static async getProfile(req, res) {
    try {
      const user = await User.getUserWithVehicles(req.user.id);

      if (!user) {
        return res.status(404).json({ message: 'Korisnik nije pronađen' });
      }

      delete user.password;

      const formattedUser = formatUserResponse(user);
      
      // Extract vehicles to match Swift UserProfile structure which expects vehicles at root
      const vehicles = formattedUser.vehicles;

      res.json({ 
        user: formattedUser,
        vehicles: vehicles
      });
    } catch (error) {
      console.error('Greška pri učitavanju profila:', error);
      res.status(500).json({ message: 'Greška pri učitavanju profila' });
    }
  }

  // Ažuriranje profila
  static async updateProfile(req, res) {
    try {
      const { firstName, lastName, phone } = req.body;
      const userId = req.user.id;

      const query = `
        UPDATE users 
        SET first_name = $1, last_name = $2, phone = $3, updated_at = CURRENT_TIMESTAMP
        WHERE id = $4
        RETURNING *
      `;

      const result = await pool.query(query, [firstName, lastName, phone, userId]);

      res.json({
        message: 'Profil uspešno ažuriran',
        user: formatUserResponse(result.rows[0])
      });
    } catch (error) {
      console.error('Greška pri ažuriranju profila:', error);
      res.status(500).json({ message: 'Greška pri ažuriranju' });
    }
  }

  // Dodavanje novog vozila
  static async addVehicle(req, res) {
    try {
      const userId = req.user.id;
      const { vehicleType, brand, model, year, licensePlate, color } = req.body;

      if (!req.user.roles.includes('vozac')) {
        return res.status(403).json({ 
          message: 'Samo vozači mogu dodavati vozila' 
        });
      }

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

      const vehicleWithImages = await Vehicle.findById(vehicle.id);

      res.status(201).json({
        message: 'Vozilo uspešno dodato',
        vehicle: vehicleWithImages
      });
    } catch (error) {
      console.error('Greška pri dodavanju vozila:', error);
      res.status(500).json({ message: 'Greška pri dodavanju vozila' });
    }
  }

  // Dobijanje svih vozila korisnika
  static async getVehicles(req, res) {
    try {
      const vehicles = await Vehicle.findByUserId(req.user.id);
      res.json(vehicles);
    } catch (error) {
      console.error('Greška pri učitavanju vozila:', error);
      res.status(500).json({ message: 'Greška pri učitavanju' });
    }
  }

  // Ažuriranje vozila
  static async updateVehicle(req, res) {
    try {
      const { vehicleId } = req.params;
      const { vehicleType, brand, model, year, licensePlate, color } = req.body;
      const userId = req.user.id;

      const query = `
        UPDATE vehicles 
        SET vehicle_type = $1, brand = $2, model = $3, year = $4, 
            license_plate = $5, color = $6, updated_at = CURRENT_TIMESTAMP
        WHERE id = $7 AND user_id = $8
        RETURNING *
      `;

      const result = await pool.query(query, [
        vehicleType, brand, model, year, licensePlate, color, vehicleId, userId
      ]);

      if (result.rows.length === 0) {
        return res.status(404).json({ message: 'Vozilo nije pronađeno' });
      }

      res.json({
        message: 'Vozilo uspešno ažurirano',
        vehicle: result.rows[0]
      });
    } catch (error) {
      console.error('Greška pri ažuriranju vozila:', error);
      res.status(500).json({ message: 'Greška pri ažuriranju' });
    }
  }

  // Dodavanje slika vozilu
  static async addVehicleImages(req, res) {
    try {
      const { vehicleId } = req.params;
      const userId = req.user.id;

      // Provera da li vozilo pripada korisniku
      const vehicle = await pool.query(
        'SELECT * FROM vehicles WHERE id = $1 AND user_id = $2',
        [vehicleId, userId]
      );

      if (vehicle.rows.length === 0) {
        return res.status(404).json({ message: 'Vozilo nije pronađeno' });
      }

      if (!req.files || req.files.length === 0) {
        return res.status(400).json({ message: 'Nema slika za upload' });
      }

      const uploadedImages = [];

      for (const file of req.files) {
        const { url, blobName } = await AzureService.uploadImage(file);
        const image = await Vehicle.addImage(vehicleId, url, blobName, false);
        uploadedImages.push(image);
      }

      res.json({
        message: 'Slike uspešno dodati',
        images: uploadedImages
      });
    } catch (error) {
      console.error('Greška pri dodavanju slika:', error);
      res.status(500).json({ message: 'Greška pri dodavanju slika' });
    }
  }

  // Brisanje slike vozila
  static async deleteVehicleImage(req, res) {
    try {
      const { imageId } = req.params;
      const userId = req.user.id;

      // Provera da li slika pripada korisniku
      const result = await pool.query(
        `SELECT vi.*, v.user_id 
         FROM vehicle_images vi
         JOIN vehicles v ON vi.vehicle_id = v.id
         WHERE vi.id = $1`,
        [imageId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ message: 'Slika nije pronađena' });
      }

      if (result.rows[0].user_id !== userId) {
        return res.status(403).json({ message: 'Nemate pristup ovoj slici' });
      }

      const blobName = result.rows[0].blob_name;

      await AzureService.deleteImage(blobName);

      await pool.query('DELETE FROM vehicle_images WHERE id = $1', [imageId]);

      res.json({ message: 'Slika uspešno obrisana' });
    } catch (error) {
      console.error('Greška pri brisanju slike:', error);
      res.status(500).json({ message: 'Greška pri brisanju' });
    }
  }

  // Brisanje vozila
  static async deleteVehicle(req, res) {
    try {
      const { vehicleId } = req.params;
      const userId = req.user.id;

      // Prvo dobijamo sve slike vozila
      const imagesResult = await pool.query(
        'SELECT blob_name FROM vehicle_images WHERE vehicle_id = $1',
        [vehicleId]
      );

      // Brišemo slike sa Azure-a
      if (imagesResult.rows.length > 0) {
        const blobNames = imagesResult.rows.map(row => row.blob_name);
        await AzureService.deleteMultipleImages(blobNames);
      }

      // Brišemo vozilo (CASCADE će obrisati i slike iz baze)
      const vehicle = await Vehicle.delete(vehicleId, userId);

      if (!vehicle) {
        return res.status(404).json({ message: 'Vozilo nije pronađeno' });
      }

      res.json({ message: 'Vozilo uspešno obrisano' });
    } catch (error) {
      console.error('Greška pri brisanju vozila:', error);
      res.status(500).json({ message: 'Greška pri brisanju' });
    }
  }

  // Promena lozinke
  static async changePassword(req, res) {
    try {
      const { currentPassword, newPassword } = req.body;
      const userId = req.user.id;

      // Validacija
      if (!currentPassword || !newPassword) {
        return res.status(400).json({ 
          success: false,
          message: 'Trenutna i nova lozinka su obavezne' 
        });
      }

      if (newPassword.length < 6) {
        return res.status(400).json({ 
          success: false,
          message: 'Nova lozinka mora imati najmanje 6 karaktera' 
        });
      }

      // Učitaj trenutnog korisnika sa lozinkom
      const userQuery = 'SELECT * FROM users WHERE id = $1';
      const userResult = await pool.query(userQuery, [userId]);
      
      if (userResult.rows.length === 0) {
        return res.status(404).json({ 
          success: false,
          message: 'Korisnik nije pronađen' 
        });
      }

      const user = userResult.rows[0];

      // Provera trenutne lozinke
      const isPasswordValid = await bcrypt.compare(currentPassword, user.password);
      
      if (!isPasswordValid) {
        return res.status(401).json({ 
          success: false,
          message: 'Trenutna lozinka nije tačna' 
        });
      }

      // Hash nove lozinke
      const hashedPassword = await bcrypt.hash(newPassword, 10);

      // Ažuriraj lozinku
      const updateQuery = `
        UPDATE users 
        SET password = $1, updated_at = CURRENT_TIMESTAMP
        WHERE id = $2
        RETURNING id, email, first_name, last_name
      `;
      
      await pool.query(updateQuery, [hashedPassword, userId]);

      res.json({ 
        success: true,
        message: 'Lozinka uspešno promenjena' 
      });
    } catch (error) {
      console.error('Greška pri promeni lozinke:', error);
      res.status(500).json({ 
        success: false,
        message: 'Greška pri promeni lozinke' 
      });
    }
  }
}

export default UserController;