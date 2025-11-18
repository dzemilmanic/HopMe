import Ride from '../models/Ride.js';
import Vehicle from '../models/Vehicle.js';
import Notification from '../models/Notification.js';
import pool from '../config/database.js';

class RideController {
  // Kreiranje nove vožnje (samo vozači)
  static async createRide(req, res) {
    try {
      const driverId = req.user.id;
      const {
        vehicleId, departureLocation, departureLat, departureLng,
        arrivalLocation, arrivalLat, arrivalLng, departureTime, arrivalTime,
        availableSeats, pricePerSeat, description, autoAcceptBookings,
        allowSmoking, allowPets, maxTwoInBack, luggageSize, waypoints
      } = req.body;

      // Provera da li vozilo pripada vozaču
      const vehicle = await Vehicle.findById(vehicleId);
      if (!vehicle || vehicle.user_id !== driverId) {
        return res.status(403).json({ message: 'Nemate pristup ovom vozilu' });
      }

      const ride = await Ride.create({
        driverId, vehicleId, departureLocation, departureLat, departureLng,
        arrivalLocation, arrivalLat, arrivalLng, departureTime, arrivalTime,
        availableSeats, pricePerSeat, description, autoAcceptBookings,
        allowSmoking, allowPets, maxTwoInBack, luggageSize
      });

      // Dodavanje međupostaja ako postoje
      if (waypoints && waypoints.length > 0) {
        for (let i = 0; i < waypoints.length; i++) {
          const wp = waypoints[i];
          await Ride.addWaypoint(
            ride.id, wp.location, wp.lat, wp.lng, i, wp.estimatedTime
          );
        }
      }

      const rideWithDetails = await Ride.findById(ride.id);

      res.status(201).json({
        message: 'Vožnja uspešno kreirana',
        ride: rideWithDetails
      });
    } catch (error) {
      console.error('Greška pri kreiranju vožnje:', error);
      res.status(500).json({ message: 'Greška pri kreiranju vožnje' });
    }
  }

  // Pretraga vožnji
  static async searchRides(req, res) {
    try {
      const { from, to, date, seats, maxPrice, page, limit } = req.query;

      const rides = await Ride.searchRides({
        from, to, date, 
        seats: seats ? parseInt(seats) : 1,
        maxPrice: maxPrice ? parseFloat(maxPrice) : null,
        page: page ? parseInt(page) : 1,
        limit: limit ? parseInt(limit) : 20
      });

      res.json({
        rides,
        count: rides.length,
        page: parseInt(page) || 1
      });
    } catch (error) {
      console.error('Greška pri pretrazi vožnji:', error);
      res.status(500).json({ message: 'Greška pri pretrazi' });
    }
  }

  // Detalji vožnje
  static async getRideDetails(req, res) {
    try {
      const { rideId } = req.params;

      const ride = await Ride.findById(rideId);

      if (!ride) {
        return res.status(404).json({ message: 'Vožnja nije pronađena' });
      }

      res.json(ride);
    } catch (error) {
      console.error('Greška pri učitavanju detalja:', error);
      res.status(500).json({ message: 'Greška pri učitavanju' });
    }
  }

  // Vožnje vozača
  static async getDriverRides(req, res) {
    try {
      const driverId = req.user.id;

      const rides = await Ride.findByDriverId(driverId);

      res.json(rides);
    } catch (error) {
      console.error('Greška pri učitavanju vožnji:', error);
      res.status(500).json({ message: 'Greška pri učitavanju' });
    }
  }

  // Ažuriranje vožnje
  static async updateRide(req, res) {
    try {
      const { rideId } = req.params;
      const driverId = req.user.id;

      // Provera da li vožnja ima rezervacije
      const bookingsCheck = await pool.query(
        'SELECT COUNT(*) as count FROM bookings WHERE ride_id = $1 AND status IN ($2, $3)',
        [rideId, 'accepted', 'completed']
      );

      if (parseInt(bookingsCheck.rows[0].count) > 0) {
        return res.status(400).json({ 
          message: 'Ne možete menjati vožnju koja ima prihvaćene rezervacije' 
        });
      }

      const ride = await Ride.update(rideId, driverId, req.body);

      if (!ride) {
        return res.status(404).json({ message: 'Vožnja nije pronađena' });
      }

      res.json({
        message: 'Vožnja uspešno ažurirana',
        ride
      });
    } catch (error) {
      console.error('Greška pri ažuriranju vožnje:', error);
      res.status(500).json({ message: 'Greška pri ažuriranju' });
    }
  }

  // Otkazivanje vožnje
  static async cancelRide(req, res) {
    try {
      const { rideId } = req.params;
      const driverId = req.user.id;

      // Dobijanje svih prihvaćenih rezervacija
      const bookings = await pool.query(
        `SELECT b.*, u.first_name, u.last_name 
         FROM bookings b 
         JOIN users u ON b.passenger_id = u.id
         WHERE b.ride_id = $1 AND b.status = 'accepted'`,
        [rideId]
      );

      const ride = await Ride.updateStatus(rideId, 'cancelled');

      if (!ride || ride.driver_id !== driverId) {
        return res.status(404).json({ message: 'Vožnja nije pronađena' });
      }

      // Otkazivanje svih rezervacija i slanje notifikacija
      for (const booking of bookings.rows) {
        await pool.query(
          'UPDATE bookings SET status = $1 WHERE id = $2',
          ['cancelled', booking.id]
        );

        await Notification.create({
          userId: booking.passenger_id,
          type: 'ride_cancelled',
          title: 'Vožnja otkazana',
          message: `Vožnja ${ride.departure_location} → ${ride.arrival_location} je otkazana od strane vozača`,
          data: { rideId: ride.id, bookingId: booking.id }
        });
      }

      res.json({ message: 'Vožnja uspešno otkazana' });
    } catch (error) {
      console.error('Greška pri otkazivanju vožnje:', error);
      res.status(500).json({ message: 'Greška pri otkazivanju' });
    }
  }

  // Brisanje vožnje
  static async deleteRide(req, res) {
    try {
      const { rideId } = req.params;
      const driverId = req.user.id;

      // Provera rezervacija
      const bookingsCheck = await pool.query(
        'SELECT COUNT(*) as count FROM bookings WHERE ride_id = $1 AND status IN ($2, $3)',
        [rideId, 'accepted', 'completed']
      );

      if (parseInt(bookingsCheck.rows[0].count) > 0) {
        return res.status(400).json({ 
          message: 'Ne možete obrisati vožnju koja ima rezervacije' 
        });
      }

      const ride = await Ride.delete(rideId, driverId);

      if (!ride) {
        return res.status(404).json({ message: 'Vožnja nije pronađena' });
      }

      res.json({ message: 'Vožnja uspešno obrisana' });
    } catch (error) {
      console.error('Greška pri brisanju vožnje:', error);
      res.status(500).json({ message: 'Greška pri brisanju' });
    }
  }

  // Početak vožnje
  static async startRide(req, res) {
    try {
      const { rideId } = req.params;
      const driverId = req.user.id;

      const ride = await pool.query(
        'SELECT * FROM rides WHERE id = $1 AND driver_id = $2',
        [rideId, driverId]
      );

      if (ride.rows.length === 0) {
        return res.status(404).json({ message: 'Vožnja nije pronađena' });
      }

      await Ride.updateStatus(rideId, 'in_progress');

      res.json({ message: 'Vožnja započeta' });
    } catch (error) {
      console.error('Greška:', error);
      res.status(500).json({ message: 'Greška' });
    }
  }

  // Završetak vožnje
  static async completeRide(req, res) {
    try {
      const { rideId } = req.params;
      const driverId = req.user.id;

      const ride = await pool.query(
        'SELECT * FROM rides WHERE id = $1 AND driver_id = $2',
        [rideId, driverId]
      );

      if (ride.rows.length === 0) {
        return res.status(404).json({ message: 'Vožnja nije pronađena' });
      }

      await Ride.updateStatus(rideId, 'completed');

      // Ažuriranje svih prihvaćenih rezervacija na completed
      await pool.query(
        `UPDATE bookings 
         SET status = 'completed', completed_at = NOW() 
         WHERE ride_id = $1 AND status = 'accepted'`,
        [rideId]
      );

      // Slanje notifikacija putnicima
      const bookings = await pool.query(
        'SELECT passenger_id FROM bookings WHERE ride_id = $1 AND status = $2',
        [rideId, 'completed']
      );

      for (const booking of bookings.rows) {
        await Notification.create({
          userId: booking.passenger_id,
          type: 'ride_completed',
          title: 'Vožnja završena',
          message: 'Vožnja je uspešno završena. Molimo ocenite vozača.',
          data: { rideId }
        });
      }

      res.json({ message: 'Vožnja završena' });
    } catch (error) {
      console.error('Greška:', error);
      res.status(500).json({ message: 'Greška' });
    }
  }
}

export default RideController;