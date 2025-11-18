import pool from '../config/database.js';

class User {
  static async create({ email, password, firstName, lastName, phone, roles }) {
    const query = `
      INSERT INTO users (email, password, first_name, last_name, phone, roles)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, email, first_name, last_name, phone, roles, account_status, is_email_verified, created_at
    `;
    const values = [email, password, firstName, lastName, phone, roles];
    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async findByEmail(email) {
    const query = 'SELECT * FROM users WHERE email = $1';
    const result = await pool.query(query, [email]);
    return result.rows[0];
  }

  static async findById(id) {
    const query = 'SELECT * FROM users WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  static async updateEmailVerification(userId) {
    const query = `
      UPDATE users 
      SET is_email_verified = true, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `;
    const result = await pool.query(query, [userId]);
    return result.rows[0];
  }

  static async updateAccountStatus(userId, status, approvedBy = null) {
    const query = `
      UPDATE users 
      SET account_status = $1, approved_by = $2, approved_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
      WHERE id = $3
      RETURNING *
    `;
    const result = await pool.query(query, [status, approvedBy, userId]);
    return result.rows[0];
  }

  static async findPendingUsers() {
    const query = `
      SELECT id, email, first_name, last_name, phone, roles, created_at
      FROM users 
      WHERE account_status = 'pending'
      ORDER BY created_at DESC
    `;
    const result = await pool.query(query);
    return result.rows;
  }

  static async addRole(userId, role) {
    const query = `
      UPDATE users 
      SET roles = array_append(roles, $1::user_role), updated_at = CURRENT_TIMESTAMP
      WHERE id = $2 AND NOT ($1 = ANY(roles))
      RETURNING *
    `;
    const result = await pool.query(query, [role, userId]);
    return result.rows[0];
  }

  static async getUserWithVehicles(userId) {
    const userQuery = 'SELECT * FROM users WHERE id = $1';
    const vehiclesQuery = `
      SELECT v.*, 
        json_agg(
          json_build_object(
            'id', vi.id,
            'image_url', vi.image_url,
            'is_primary', vi.is_primary
          )
        ) FILTER (WHERE vi.id IS NOT NULL) as images
      FROM vehicles v
      LEFT JOIN vehicle_images vi ON v.id = vi.vehicle_id
      WHERE v.user_id = $1
      GROUP BY v.id
    `;
    
    const userResult = await pool.query(userQuery, [userId]);
    const vehiclesResult = await pool.query(vehiclesQuery, [userId]);
    
    return {
      ...userResult.rows[0],
      vehicles: vehiclesResult.rows
    };
  }
}

export default User;