import pool from '../config/database.js';

class Testimonial {
  static async create({ userId, rating, text }) {
    const query = `
      INSERT INTO testimonials (user_id, rating, text, is_approved)
      VALUES ($1, $2, $3, true)
      RETURNING *
    `;

    const values = [userId, rating, text];
    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async findAll() {
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
    return result.rows;
  }

  static async findByUserId(userId) {
    const query = `
      SELECT t.*, 
             u.first_name, 
             u.last_name, 
             u.profile_image_url
      FROM testimonials t
      JOIN users u ON t.user_id = u.id
      WHERE t.user_id = $1
    `;

    const result = await pool.query(query, [userId]);
    return result.rows[0];
  }

  static async update({ userId, rating, text }) {
    const query = `
      UPDATE testimonials 
      SET rating = $1, text = $2, updated_at = CURRENT_TIMESTAMP
      WHERE user_id = $3
      RETURNING *
    `;

    const values = [rating, text, userId];
    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async delete(id) {
    const query = 'DELETE FROM testimonials WHERE id = $1 RETURNING id';
    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  static async deleteByUserId(userId) {
    const query = 'DELETE FROM testimonials WHERE user_id = $1 RETURNING id';
    const result = await pool.query(query, [userId]);
    return result.rows[0];
  }

  static async checkExists(userId) {
    const query = 'SELECT id FROM testimonials WHERE user_id = $1';
    const result = await pool.query(query, [userId]);
    return result.rows.length > 0;
  }
}

export default Testimonial;
