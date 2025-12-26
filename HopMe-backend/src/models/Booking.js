import pool from '../config/database.js';

class Booking {
  static async create(bookingData) {
    const {
      rideId, passengerId, seatsBooked, totalPrice,
      pickupLocation, dropoffLocation, message
    } = bookingData;

    const query = `
      INSERT INTO bookings (
        ride_id, passenger_id, seats_booked, total_price,
        pickup_location, dropoff_location, message
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;

    const values = [
      rideId, passengerId, seatsBooked, totalPrice,
      pickupLocation, dropoffLocation, message
    ];

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async findById(id) {
    const query = `
      SELECT 
        b.*,
        json_build_object(
          'id', p.id,
          'firstName', p.first_name,
          'lastName', p.last_name,
          'phone', p.phone,
          'profileImage', p.profile_image_url,
          'averageRating', COALESCE(pr.average_rating, 0),
          'totalRatings', COALESCE(pr.total_ratings, 0)
        ) as passenger,
        json_build_object(
          'id', r.id,
          'departureLocation', r.departure_location,
          'arrivalLocation', r.arrival_location,
          'departureTime', to_char(r.departure_time, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
          'pricePerSeat', r.price_per_seat,
          'driverId', r.driver_id,
          'status', r.status,
          'driver', json_build_object(
            'id', d.id,
            'firstName', d.first_name,
            'lastName', d.last_name,
            'phone', d.phone,
            'profileImage', d.profile_image_url,
            'averageRating', COALESCE(dr.average_rating, 0)
          ),
          'vehicle', json_build_object(
            'type', v.vehicle_type,
            'brand', v.brand,
            'model', v.model,
            'color', v.color
          )
        ) as ride
      FROM bookings b
      JOIN users p ON b.passenger_id = p.id
      JOIN rides r ON b.ride_id = r.id
      JOIN users d ON r.driver_id = d.id
      LEFT JOIN vehicles v ON r.vehicle_id = v.id
      LEFT JOIN user_ratings pr ON p.id = pr.user_id
      LEFT JOIN user_ratings dr ON d.id = dr.user_id
      WHERE b.id = $1
    `;

    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  static async findByRideId(rideId) {
    const query = `
      SELECT 
        b.*,
        json_build_object(
          'id', p.id,
          'firstName', p.first_name,
          'lastName', p.last_name,
          'phone', p.phone,
          'profileImage', p.profile_image_url,
          'averageRating', COALESCE(pr.average_rating, 0),
          'totalRatings', COALESCE(pr.total_ratings, 0)
        ) as passenger,
        json_build_object(
          'id', r.id,
          'departureLocation', r.departure_location,
          'arrivalLocation', r.arrival_location,
          'departureTime', to_char(r.departure_time, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
          'pricePerSeat', r.price_per_seat,
          'driverId', r.driver_id,
          'status', r.status,
          'driver', json_build_object(
            'id', d.id,
            'firstName', d.first_name,
            'lastName', d.last_name,
            'phone', d.phone,
            'profileImage', d.profile_image_url,
            'averageRating', COALESCE(dr.average_rating, 0)
          ),
          'vehicle', json_build_object(
            'type', v.vehicle_type,
            'brand', v.brand,
            'model', v.model,
            'color', v.color
          )
        ) as ride
      FROM bookings b
      JOIN users p ON b.passenger_id = p.id
      JOIN rides r ON b.ride_id = r.id
      JOIN users d ON r.driver_id = d.id
      LEFT JOIN vehicles v ON r.vehicle_id = v.id
      LEFT JOIN user_ratings pr ON p.id = pr.user_id
      LEFT JOIN user_ratings dr ON d.id = dr.user_id
      WHERE b.ride_id = $1
      ORDER BY b.created_at DESC
    `;

    const result = await pool.query(query, [rideId]);
    return result.rows;
  }

  static async findByPassengerId(passengerId) {
    const query = `
      SELECT 
        b.*,
        json_build_object(
          'id', r.id,
          'departureLocation', r.departure_location,
          'arrivalLocation', r.arrival_location,
          'departureTime', to_char(r.departure_time, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
          'status', r.status,
          'driver', json_build_object(
            'id', d.id,
            'firstName', d.first_name,
            'lastName', d.last_name,
            'phone', d.phone,
            'profileImage', d.profile_image_url,
            'averageRating', COALESCE(dr.average_rating, 0)
          ),
          'vehicle', json_build_object(
            'type', v.vehicle_type,
            'brand', v.brand,
            'model', v.model,
            'color', v.color
          )
        ) as ride
      FROM bookings b
      JOIN rides r ON b.ride_id = r.id
      JOIN users d ON r.driver_id = d.id
      LEFT JOIN vehicles v ON r.vehicle_id = v.id
      LEFT JOIN user_ratings dr ON d.id = dr.user_id
      WHERE b.passenger_id = $1
      ORDER BY r.departure_time DESC
    `;

    const result = await pool.query(query, [passengerId]);
    return result.rows;
  }

  static async updateStatus(bookingId, status, driverResponse = null) {
    let query = 'UPDATE bookings SET status = $1, updated_at = NOW()';
    const values = [status];
    let paramIndex = 2;

    if (status === 'accepted') {
      query += `, accepted_at = NOW()`;
    } else if (status === 'rejected') {
      query += `, rejected_at = NOW()`;
    } else if (status === 'completed') {
      query += `, completed_at = NOW()`;
    }

    if (driverResponse) {
      query += `, driver_response = $${paramIndex}`;
      values.push(driverResponse);
      paramIndex++;
    }

    query += ` WHERE id = $${paramIndex} RETURNING *`;
    values.push(bookingId);

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async checkAvailability(rideId, seatsRequested) {
    const query = `
      SELECT 
        r.available_seats,
        COALESCE(SUM(b.seats_booked), 0) as booked_seats
      FROM rides r
      LEFT JOIN bookings b ON r.id = b.ride_id 
        AND b.status IN ('accepted', 'completed')
      WHERE r.id = $1
      GROUP BY r.available_seats
    `;

    const result = await pool.query(query, [rideId]);
    if (result.rows.length === 0) return false;

    const { available_seats, booked_seats } = result.rows[0];
    return (available_seats - booked_seats) >= seatsRequested;
  }

  static async cancelBooking(bookingId, userId) {
    const query = `
      UPDATE bookings 
      SET status = 'cancelled', updated_at = NOW()
      WHERE id = $1 AND passenger_id = $2 AND status = 'pending'
      RETURNING *
    `;

    const result = await pool.query(query, [bookingId, userId]);
    return result.rows[0];
  }
}

export default Booking;