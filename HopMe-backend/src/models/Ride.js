import pool from '../config/database.js';

class Ride {
  static async create(rideData) {
    const {
      driverId, vehicleId, departureLocation, departureLat, departureLng,
      arrivalLocation, arrivalLat, arrivalLng, departureTime, arrivalTime,
      availableSeats, pricePerSeat, description, autoAcceptBookings,
      allowSmoking, allowPets, maxTwoInBack, luggageSize
    } = rideData;

    const query = `
      INSERT INTO rides (
        driver_id, vehicle_id, departure_location, departure_lat, departure_lng,
        arrival_location, arrival_lat, arrival_lng, departure_time, arrival_time,
        available_seats, price_per_seat, description, auto_accept_bookings,
        allow_smoking, allow_pets, max_two_in_back, luggage_size
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
      RETURNING *
    `;

    const values = [
      driverId, vehicleId, departureLocation, departureLat, departureLng,
      arrivalLocation, arrivalLat, arrivalLng, departureTime, arrivalTime,
      availableSeats, pricePerSeat, description, autoAcceptBookings,
      allowSmoking, allowPets, maxTwoInBack, luggageSize
    ];

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async addWaypoint(rideId, location, lat, lng, orderIndex, estimatedTime) {
    const query = `
      INSERT INTO waypoints (ride_id, location, lat, lng, order_index, estimated_time)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `;
    const result = await pool.query(query, [rideId, location, lat, lng, orderIndex, estimatedTime]);
    return result.rows[0];
  }

  static async findById(id) {
    const query = `
      SELECT 
        r.*,
        json_build_object(
          'id', d.id,
          'firstName', d.first_name,
          'lastName', d.last_name,
          'profileImage', d.profile_image_url,
          'averageRating', COALESCE(ds.average_rating, 0),
          'totalRatings', COALESCE(ds.total_ratings, 0),
          'totalRides', COALESCE(ds.total_rides, 0)
        ) as driver,
        json_build_object(
          'id', v.id,
          'userId', v.user_id,
          'vehicleType', v.vehicle_type,
          'brand', v.brand,
          'model', v.model,
          'year', v.year,
          'color', v.color,
          'seats', v.seats
        ) as vehicle,
        COALESCE(
          json_agg(
            json_build_object(
              'id', w.id,
              'location', w.location,
              'lat', w.lat,
              'lng', w.lng,
              'orderIndex', w.order_index,
              'estimatedTime', w.estimated_time
            ) ORDER BY w.order_index
          ) FILTER (WHERE w.id IS NOT NULL),
          '[]'
        ) as waypoints,
        (
          SELECT COUNT(*) 
          FROM bookings 
          WHERE ride_id = r.id AND status IN ('accepted', 'completed')
        ) as booked_seats
      FROM rides r
      JOIN users d ON r.driver_id = d.id
      LEFT JOIN vehicles v ON r.vehicle_id = v.id
      LEFT JOIN driver_stats ds ON d.id = ds.driver_id
      LEFT JOIN waypoints w ON r.id = w.ride_id
      WHERE r.id = $1
      GROUP BY r.id, d.id, v.id, ds.average_rating, ds.total_ratings, ds.total_rides
    `;

    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  static async searchRides({ from, to, date, seats, maxPrice, page = 1, limit = 20 }) {
    let query = `
      SELECT 
        r.*,
        json_build_object(
          'id', d.id,
          'firstName', d.first_name,
          'lastName', d.last_name,
          'profileImage', d.profile_image_url,
          'averageRating', COALESCE(ds.average_rating, 0),
          'totalRatings', COALESCE(ds.total_ratings, 0)
        ) as driver,
        json_build_object(
          'id', v.id,
          'userId', v.user_id,
          'vehicleType', v.vehicle_type,
          'brand', v.brand,
          'model', v.model,
          'year', v.year,
          'color', v.color,
          'seats', v.seats
        ) as vehicle,
        (r.available_seats - COALESCE(
          (SELECT SUM(seats_booked) 
           FROM bookings 
           WHERE ride_id = r.id AND status IN ('accepted', 'completed')), 0
        )) as remaining_seats
      FROM rides r
      JOIN users d ON r.driver_id = d.id
      LEFT JOIN vehicles v ON r.vehicle_id = v.id
      LEFT JOIN driver_stats ds ON d.id = ds.driver_id
      WHERE r.status = 'scheduled'
        AND r.departure_time > NOW()
    `;

    const values = [];
    let paramIndex = 1;

    if (from) {
      query += ` AND LOWER(r.departure_location) LIKE LOWER($${paramIndex})`;
      values.push(`%${from}%`);
      paramIndex++;
    }

    if (to) {
      query += ` AND LOWER(r.arrival_location) LIKE LOWER($${paramIndex})`;
      values.push(`%${to}%`);
      paramIndex++;
    }

    if (date) {
      query += ` AND DATE(r.departure_time) = $${paramIndex}`;
      values.push(date);
      paramIndex++;
    }

    if (maxPrice) {
      query += ` AND r.price_per_seat <= $${paramIndex}`;
      values.push(maxPrice);
      paramIndex++;
    }

    query += ` 
      AND (r.available_seats - COALESCE(
        (SELECT SUM(seats_booked) 
         FROM bookings 
         WHERE ride_id = r.id AND status IN ('accepted', 'completed')), 0
      )) >= ${seats || 1}
      ORDER BY r.departure_time ASC
      LIMIT ${limit} OFFSET ${(page - 1) * limit}
    `;

    const result = await pool.query(query, values);
    return result.rows;
  }

  static async findByDriverId(driverId) {
    const query = `
      SELECT 
        r.*,
        json_build_object(
          'id', d.id,
          'firstName', d.first_name,
          'lastName', d.last_name,
          'profileImage', d.profile_image_url,
          'averageRating', COALESCE(ds.average_rating, 0),
          'totalRatings', COALESCE(ds.total_ratings, 0)
        ) as driver,
        json_build_object(
          'id', v.id,
          'userId', v.user_id,
          'vehicleType', v.vehicle_type,
          'brand', v.brand,
          'model', v.model,
          'year', v.year,
          'color', v.color,
          'seats', v.seats
        ) as vehicle,
        (r.available_seats - COALESCE(
          (SELECT SUM(seats_booked) 
           FROM bookings 
           WHERE ride_id = r.id AND status IN ('accepted', 'completed')), 0
        )) as remaining_seats,
        (SELECT COUNT(*) FROM bookings WHERE ride_id = r.id AND status = 'pending') as pending_bookings
      FROM rides r
      JOIN users d ON r.driver_id = d.id
      LEFT JOIN vehicles v ON r.vehicle_id = v.id
      LEFT JOIN driver_stats ds ON d.id = ds.driver_id
      WHERE r.driver_id = $1
      ORDER BY r.departure_time DESC
    `;

    const result = await pool.query(query, [driverId]);
    return result.rows;
  }

  static async updateStatus(rideId, status) {
    const query = 'UPDATE rides SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *';
    const result = await pool.query(query, [status, rideId]);
    return result.rows[0];
  }

  static async delete(rideId, driverId) {
    const query = 'DELETE FROM rides WHERE id = $1 AND driver_id = $2 RETURNING *';
    const result = await pool.query(query, [rideId, driverId]);
    return result.rows[0];
  }

  static async update(rideId, driverId, updateData) {
    const {
      departureLocation, departureLat, departureLng,
      arrivalLocation, arrivalLat, arrivalLng,
      departureTime, arrivalTime, availableSeats,
      pricePerSeat, description, allowSmoking,
      allowPets, maxTwoInBack, luggageSize
    } = updateData;

    const query = `
      UPDATE rides SET
        departure_location = $1, departure_lat = $2, departure_lng = $3,
        arrival_location = $4, arrival_lat = $5, arrival_lng = $6,
        departure_time = $7, arrival_time = $8, available_seats = $9,
        price_per_seat = $10, description = $11, allow_smoking = $12,
        allow_pets = $13, max_two_in_back = $14, luggage_size = $15,
        updated_at = NOW()
      WHERE id = $16 AND driver_id = $17
      RETURNING *
    `;

    const values = [
      departureLocation, departureLat, departureLng,
      arrivalLocation, arrivalLat, arrivalLng,
      departureTime, arrivalTime, availableSeats,
      pricePerSeat, description, allowSmoking,
      allowPets, maxTwoInBack, luggageSize,
      rideId, driverId
    ];

    const result = await pool.query(query, values);
    return result.rows[0];
  }
}

export default Ride;