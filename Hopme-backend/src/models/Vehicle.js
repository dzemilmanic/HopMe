import pool from '../config/database.js';

class Vehicle {
  static async create({ userId, vehicleType, brand, model, year, licensePlate, color }) {
    const query = `
      INSERT INTO vehicles (user_id, vehicle_type, brand, model, year, license_plate, color)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;
    const values = [userId, vehicleType, brand, model, year, licensePlate, color];
    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async addImage(vehicleId, imageUrl, blobName, isPrimary = false) {
    const query = `
      INSERT INTO vehicle_images (vehicle_id, image_url, blob_name, is_primary)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;
    const result = await pool.query(query, [vehicleId, imageUrl, blobName, isPrimary]);
    return result.rows[0];
  }

  static async findByUserId(userId) {
    const query = `
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
    const result = await pool.query(query, [userId]);
    return result.rows;
  }

  static async findById(id) {
    const query = `
      SELECT v.*, 
        json_agg(
          json_build_object(
            'id', vi.id,
            'image_url', vi.image_url,
            'blob_name', vi.blob_name,
            'is_primary', vi.is_primary
          )
        ) FILTER (WHERE vi.id IS NOT NULL) as images
      FROM vehicles v
      LEFT JOIN vehicle_images vi ON v.id = vi.vehicle_id
      WHERE v.id = $1
      GROUP BY v.id
    `;
    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  static async delete(id, userId) {
    const query = 'DELETE FROM vehicles WHERE id = $1 AND user_id = $2 RETURNING *';
    const result = await pool.query(query, [id, userId]);
    return result.rows[0];
  }
}

export default Vehicle;