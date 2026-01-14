import pool from '../config/database.js';
import { validationResult } from 'express-validator';

class TestimonialController {
  
  // @desc    Get all approved testimonials
  // @route   GET /api/testimonials
  // @access  Public
  static async getAllTestimonials(req, res) {
    try {
      const query = `
        SELECT t.*, 
               u.first_name, 
               u.last_name, 
               u.profile_image_url
        FROM testimonials t
        JOIN users u ON t.user_id = u.id
        WHERE t.is_approved = true
        ORDER BY t.created_at DESC
        LIMIT 50
      `;
      
      const result = await pool.query(query);

      // Format response to match frontend expectations (camelCase mostly handled by middleware but let's be safe if needed)
      // The middleware responseTransformer should handle basic snake_case to camelCase conversion if configured properly.
      // Based on server.js: app.use('/api', responseTransformer); it seems it does.
      
      res.json({
        success: true,
        count: result.rows.length,
        testimonials: result.rows
      });
    } catch (error) {
      console.error('Error getting testimonials:', error);
      res.status(500).json({
        success: false,
        message: 'Error getting testimonials'
      });
    }
  }

  // @desc    Create a testimonial
  // @route   POST /api/testimonials
  // @access  Private
  static async createTestimonial(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation error',
          errors: errors.array()
        });
      }

      const { rating, text } = req.body;
      const userId = req.user.id;

      // Check if user already has a testimonial
      const checkQuery = 'SELECT id FROM testimonials WHERE user_id = $1';
      const checkResult = await pool.query(checkQuery, [userId]);
      
      if (checkResult.rows.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'You have already left a testimonial. You can update or delete it.'
        });
      }

      // Insert new testimonial
      const insertQuery = `
        INSERT INTO testimonials (user_id, rating, text, is_approved)
        VALUES ($1, $2, $3, true)
        RETURNING *
      `;
      
      const insertResult = await pool.query(insertQuery, [userId, rating, text]);
      const newTestimonial = insertResult.rows[0];
      
      // Fetch user details to return complete object
      const userQuery = 'SELECT first_name, last_name, profile_image_url FROM users WHERE id = $1';
      const userResult = await pool.query(userQuery, [userId]);
      
      // Merge user details into testimonial at root level (not nested)
      const testimonialWithUser = {
        ...newTestimonial,
        ...userResult.rows[0]
      };

      res.status(201).json({
        success: true,
        message: 'Testimonial successfully created',
        testimonial: testimonialWithUser
      });
    } catch (error) {
      console.error('Create testimonial error:', error);
      res.status(500).json({
        success: false,
        message: 'Error creating testimonial'
      });
    }
  }

  // @desc    Update user's own testimonial
  // @route   PUT /api/testimonials/my
  // @access  Private
  static async updateMyTestimonial(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation error',
          errors: errors.array()
        });
      }

      const { rating, text } = req.body;
      const userId = req.user.id;

      const updateQuery = `
        UPDATE testimonials 
        SET rating = $1, text = $2, updated_at = CURRENT_TIMESTAMP
        WHERE user_id = $3
        RETURNING *
      `;

      const result = await pool.query(updateQuery, [rating, text, userId]);

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'You do not have an active testimonial'
        });
      }
      
      const testimonial = result.rows[0];
      
      // Fetch user info and merge at root level
      const userQuery = 'SELECT first_name, last_name, profile_image_url FROM users WHERE id = $1';
      const userResult = await pool.query(userQuery, [userId]);
      const testimonialWithUser = {
        ...testimonial,
        ...userResult.rows[0]
      };

      res.json({
        success: true,
        message: 'Testimonial successfully updated',
        testimonial: testimonialWithUser
      });
    } catch (error) {
      console.error('Update testimonial error:', error);
      res.status(500).json({
        success: false,
        message: 'Error updating testimonial'
      });
    }
  }

  // @desc    Get user's own testimonial
  // @route   GET /api/testimonials/my
  // @access  Private
  static async getMyTestimonial(req, res) {
    try {
      const userId = req.user.id;
      
      const query = `
        SELECT t.*, u.first_name, u.last_name, u.profile_image_url
        FROM testimonials t
        JOIN users u ON t.user_id = u.id
        WHERE t.user_id = $1
      `;
      
      const result = await pool.query(query, [userId]);

      res.json({
        success: true,
        testimonial: result.rows[0] || null
      });
    } catch (error) {
      console.error('Get my testimonial error:', error);
      res.status(500).json({
        success: false,
        message: 'Error loading testimonial'
      });
    }
  }

  // @desc    Delete a testimonial
  // @route   DELETE /api/testimonials/:id
  // @access  Private (Admin only)
  static async deleteTestimonial(req, res) {
    try {
      const { id } = req.params;
      
      const result = await pool.query('DELETE FROM testimonials WHERE id = $1 RETURNING id', [id]);

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Testimonial not found'
        });
      }

      res.json({
        success: true,
        message: 'Testimonial successfully deleted'
      });
    } catch (error) {
      console.error('Delete testimonial error:', error);
      res.status(500).json({
        success: false,
        message: 'Error deleting testimonial'
      });
    }
  }

  // @desc    Delete user's own testimonial
  // @route   DELETE /api/testimonials/my
  // @access  Private
  static async deleteMyTestimonial(req, res) {
    try {
      const userId = req.user.id;
      
      const result = await pool.query('DELETE FROM testimonials WHERE user_id = $1 RETURNING id', [userId]);

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'You do not have an active testimonial'
        });
      }

      res.json({
        success: true,
        message: 'Testimonial successfully deleted'
      });
    } catch (error) {
      console.error('Delete my testimonial error:', error);
      res.status(500).json({
        success: false,
        message: 'Error deleting testimonial'
      });
    }
  }
}

export default TestimonialController;
