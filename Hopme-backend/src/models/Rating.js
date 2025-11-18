import pool from '../config/database.js';

class Rating {
  static async create({ bookingId, rideId, raterId, ratedId, rating, comment }) {
    const query = `
      INSERT INTO ratings (booking_id, ride_id, rater_id, rated_id, rating, comment)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `;

    const values = [bookingId, rideId, raterId, ratedId, rating, comment];
    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async findByUserId(userId) {
    const query = `
      SELECT 
        r.*,
        json_build_object(
          'id', rater.id,
          'firstName', rater.first_name,
          'lastName', rater.last_name,
          'profileImage', rater.profile_image_url
        ) as rater
      FROM ratings r
      JOIN users rater ON r.rater_id = rater.id
      WHERE r.rated_id = $1
      ORDER BY r.created_at DESC
    `;

    const result = await pool.query(query, [userId]);
    return result.rows;
  }

  static async getUserStats(userId) {
    const query = 'SELECT * FROM user_ratings WHERE user_id = $1';
    const result = await pool.query(query, [userId]);
    return result.rows[0];
  }

  static async canRate(bookingId, raterId) {
    const query = `
      SELECT 
        b.status,
        b.passenger_id,
        r.driver_id,
        EXISTS(
          SELECT 1 FROM ratings 
          WHERE booking_id = $1 AND rater_id = $2
        ) as already_rated
      FROM bookings b
      JOIN rides r ON b.ride_id = r.id
      WHERE b.id = $1
    `;

    const result = await pool.query(query, [bookingId, raterId]);
    if (result.rows.length === 0) return { canRate: false, reason: 'Rezervacija ne postoji' };

    const { status, passenger_id, driver_id, already_rated } = result.rows[0];

    if (already_rated) {
      return { canRate: false, reason: 'Već ste ocenili' };
    }

    if (status !== 'completed') {
      return { canRate: false, reason: 'Vožnja još nije završena' };
    }

    if (raterId !== passenger_id && raterId !== driver_id) {
      return { canRate: false, reason: 'Niste učesnik ove vožnje' };
    }

    return { canRate: true, passengerId: passenger_id, driverId: driver_id };
  }
}

export default Rating;