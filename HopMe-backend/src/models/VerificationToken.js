import pool from '../config/database.js';
import crypto from 'crypto';

class VerificationToken {
  static async create(userId, type, expiresInHours = 24) {
    const token = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + expiresInHours * 60 * 60 * 1000);
    
    const query = `
      INSERT INTO verification_tokens (user_id, token, type, expires_at)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;
    const result = await pool.query(query, [userId, token, type, expiresAt]);
    return result.rows[0];
  }

  static async findByToken(token) {
    const query = `
      SELECT vt.*, u.email, u.first_name, u.last_name
      FROM verification_tokens vt
      JOIN users u ON vt.user_id = u.id
      WHERE vt.token = $1 AND vt.expires_at > CURRENT_TIMESTAMP
    `;
    const result = await pool.query(query, [token]);
    return result.rows[0];
  }

  static async deleteByUserId(userId, type) {
    const query = 'DELETE FROM verification_tokens WHERE user_id = $1 AND type = $2';
    await pool.query(query, [userId, type]);
  }

  static async deleteExpired() {
    const query = 'DELETE FROM verification_tokens WHERE expires_at < CURRENT_TIMESTAMP';
    await pool.query(query);
  }
}

export default VerificationToken;