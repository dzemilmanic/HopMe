import User from '../models/User.js';
import Vehicle from '../models/Vehicle.js';
import AzureService from '../services/azure.service.js';
import pool from '../config/database.js';
import bcrypt from 'bcryptjs';
import { formatUserResponse, formatVehicleResponse } from '../utils/responseFormatter.js';

class UserController {
  // Get current user profile
  static async getProfile(req, res) {
    try {
      const user = await User.getUserWithVehicles(req.user.id);

      if (!user) {
        return res.status(404).json({ message: 'User not found' });
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
      console.error('Error loading profile:', error);
      res.status(500).json({ message: 'Error loading profile' });
    }
  }

  // Update profile
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
        message: 'Profile successfully updated',
        user: formatUserResponse(result.rows[0])
      });
    } catch (error) {
      console.error('Error updating profile:', error);
      res.status(500).json({ message: 'Error updating profile' });
    }
  }

  // Add new vehicle
  static async addVehicle(req, res) {
    try {
      const userId = req.user.id;
      const { vehicleType, brand, model, year, licensePlate, color } = req.body;

      if (!req.user.roles.includes('vozac')) {
        return res.status(403).json({ 
          message: 'Only drivers can add vehicles' 
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
        message: 'Vehicle successfully added',
        vehicle: vehicleWithImages
      });
    } catch (error) {
      console.error('Error adding vehicle:', error);
      res.status(500).json({ message: 'Error adding vehicle' });
    }
  }

  // Get all vehicles of user
  static async getVehicles(req, res) {
    try {
      const vehicles = await Vehicle.findByUserId(req.user.id);
      res.json(vehicles);
    } catch (error) {
      console.error('Error loading vehicles:', error);
      res.status(500).json({ message: 'Error loading vehicles' });
    }
  }

  // Update vehicle
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
        return res.status(404).json({ message: 'Vehicle not found' });
      }

      res.json({
        message: 'Vehicle successfully updated',
        vehicle: result.rows[0]
      });
    } catch (error) {
      console.error('Error updating vehicle:', error);
      res.status(500).json({ message: 'Error updating vehicle' });
    }
  }

  // Add vehicle images
  static async addVehicleImages(req, res) {
    try {
      const { vehicleId } = req.params;
      const userId = req.user.id;

      // Checking if the vehicle belongs to the user
      const vehicle = await pool.query(
        'SELECT * FROM vehicles WHERE id = $1 AND user_id = $2',
        [vehicleId, userId]
      );

      if (vehicle.rows.length === 0) {
        return res.status(404).json({ message: 'Vehicle not found' });
      }

      if (!req.files || req.files.length === 0) {
        return res.status(400).json({ message: 'No images to upload' });
      }

      const uploadedImages = [];

      for (const file of req.files) {
        const { url, blobName } = await AzureService.uploadImage(file);
        const image = await Vehicle.addImage(vehicleId, url, blobName, false);
        uploadedImages.push(image);
      }

      res.json({
        message: 'Images successfully added',
        images: uploadedImages
      });
    } catch (error) {
      console.error('Error adding images:', error);
      res.status(500).json({ message: 'Error adding images' });
    }
  }

  // Delete vehicle image
  static async deleteVehicleImage(req, res) {
    try {
      const { imageId } = req.params;
      const userId = req.user.id;

      // Checking if the image belongs to the user
      const result = await pool.query(
        `SELECT vi.*, v.user_id 
         FROM vehicle_images vi
         JOIN vehicles v ON vi.vehicle_id = v.id
         WHERE vi.id = $1`,
        [imageId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ message: 'Image not found' });
      }

      if (result.rows[0].user_id !== userId) {
        return res.status(403).json({ message: 'You do not have access to this image' });
      }

      const blobName = result.rows[0].blob_name;

      await AzureService.deleteImage(blobName);

      await pool.query('DELETE FROM vehicle_images WHERE id = $1', [imageId]);

      res.json({ message: 'Image successfully deleted' });
    } catch (error) {
      console.error('Error deleting image:', error);
      res.status(500).json({ message: 'Error deleting image' });
    }
  }

  // Delete vehicle
  static async deleteVehicle(req, res) {
    try {
      const { vehicleId } = req.params;
      const userId = req.user.id;

      // First we get all the vehicle images
      const imagesResult = await pool.query(
        'SELECT blob_name FROM vehicle_images WHERE vehicle_id = $1',
        [vehicleId]
      );

      // Delete images from Azure
      if (imagesResult.rows.length > 0) {
        const blobNames = imagesResult.rows.map(row => row.blob_name);
        await AzureService.deleteMultipleImages(blobNames);
      }

      // Delete vehicle (CASCADE will delete images from the database)
      const vehicle = await Vehicle.delete(vehicleId, userId);

      if (!vehicle) {
        return res.status(404).json({ message: 'Vehicle not found' });
      }

      res.json({ message: 'Vehicle successfully deleted' });
    } catch (error) {
      console.error('Error deleting vehicle:', error);
      res.status(500).json({ message: 'Error deleting vehicle' });
    }
  }

  // Change password
  static async changePassword(req, res) {
    try {
      const { currentPassword, newPassword } = req.body;
      const userId = req.user.id;

      // Validation
      if (!currentPassword || !newPassword) {
        return res.status(400).json({ 
          success: false,
          message: 'Current and new password are required' 
        });
      }

      if (newPassword.length < 6) {
        return res.status(400).json({ 
          success: false,
          message: 'New password must have at least 6 characters' 
        });
      }

      // Load current user with password
      const userQuery = 'SELECT * FROM users WHERE id = $1';
      const userResult = await pool.query(userQuery, [userId]);
      
      if (userResult.rows.length === 0) {
        return res.status(404).json({ 
          success: false,
          message: 'User not found' 
        });
      }

      const user = userResult.rows[0];

      // Check current password
      const isPasswordValid = await bcrypt.compare(currentPassword, user.password);
      
      if (!isPasswordValid) {
        return res.status(401).json({ 
          success: false,
          message: 'Current password is incorrect' 
        });
      }

      // Hash new password
      const hashedPassword = await bcrypt.hash(newPassword, 10);

      // Update password
      const updateQuery = `
        UPDATE users 
        SET password = $1, updated_at = CURRENT_TIMESTAMP
        WHERE id = $2
        RETURNING id, email, first_name, last_name
      `;
      
      await pool.query(updateQuery, [hashedPassword, userId]);

      res.json({ 
        success: true,
        message: 'Password successfully changed' 
      });
    } catch (error) {
      console.error('Error changing password:', error);
      res.status(500).json({ 
        success: false,
        message: 'Error changing password' 
      });
    }
  }
}

export default UserController;