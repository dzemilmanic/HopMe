import Ride from '../models/Ride.js';
import Vehicle from '../models/Vehicle.js';
import Notification from '../models/Notification.js';
import pool from '../config/database.js';

class RideController {
  // Create new ride (only drivers)
  static async createRide(req, res) {
    try {
      const driverId = req.user.id;
      const {
        vehicleId, departureLocation, departureLat, departureLng,
        arrivalLocation, arrivalLat, arrivalLng, departureTime, arrivalTime,
        availableSeats, pricePerSeat, description, autoAcceptBookings,
        allowSmoking, allowPets, maxTwoInBack, luggageSize, waypoints
      } = req.body;

      console.log('📝 Create Ride Request:');
      console.log('   driverId:', driverId);
      console.log('   vehicleId:', vehicleId);
      console.log('   departureTime:', departureTime);
      console.log('   departureLocation:', departureLocation);
      console.log('   arrivalLocation:', arrivalLocation);

      // Check if vehicle belongs to driver
      const vehicle = await Vehicle.findById(vehicleId);
      console.log('   vehicle found:', vehicle ? 'YES' : 'NO');
      console.log('   vehicle.user_id:', vehicle?.user_id);
      
      if (!vehicle || vehicle.user_id !== driverId) {
        return res.status(403).json({ message: 'You do not have access to this vehicle' });
      }

      const ride = await Ride.create({
        driverId, vehicleId, departureLocation, departureLat, departureLng,
        arrivalLocation, arrivalLat, arrivalLng, departureTime, arrivalTime,
        availableSeats, pricePerSeat, description, autoAcceptBookings,
        allowSmoking, allowPets, maxTwoInBack, luggageSize
      });

      console.log('   ride created:', ride?.id);

      // Add waypoints if they exist
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
        message: 'Ride successfully created',
        ride: rideWithDetails
      });
    } catch (error) {
      console.error('Error creating ride:', error);
      res.status(500).json({ message: 'Error creating ride' });
    }
  }

  // Search rides
  static async searchRides(req, res) {
    try {
      const { from, to, date, seats, maxPrice, page, limit } = req.query;

      console.log('🔍 Search Rides Request:');
      console.log('   Params:', { from, to, date, seats, maxPrice, page, limit });

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
      console.error('❌ Error searching rides:', error);
      console.error('   Error message:', error.message);
      console.error('   Error code:', error.code);
      console.error('   Error detail:', error.detail);
      console.error('   Error hint:', error.hint);
      res.status(500).json({ message: 'Error searching rides' });
    }
  }

  // Ride details
  static async getRideDetails(req, res) {
    try {
      const { rideId } = req.params;

      const ride = await Ride.findById(rideId);

      if (!ride) {
        return res.status(404).json({ message: 'Ride not found' });
      }

      res.json(ride);
    } catch (error) {
      console.error('Error loading ride details:', error);
      res.status(500).json({ message: 'Error loading ride details' });
    }
  }

  // Driver's rides
  static async getDriverRides(req, res) {
    try {
      const driverId = req.user.id;

      const rides = await Ride.findByDriverId(driverId);

      res.json(rides);
    } catch (error) {
      console.error('Error loading driver rides:', error);
      res.status(500).json({ message: 'Error loading driver rides' });
    }
  }

  // Update ride
  static async updateRide(req, res) {
    try {
      const { rideId } = req.params;
      const driverId = req.user.id;

      // Check if ride has accepted bookings
      const bookingsCheck = await pool.query(
        'SELECT COUNT(*) as count FROM bookings WHERE ride_id = $1 AND status IN ($2, $3)',
        [rideId, 'accepted', 'completed']
      );

      if (parseInt(bookingsCheck.rows[0].count) > 0) {
        return res.status(400).json({ 
          message: 'You cannot change a ride that has accepted bookings' 
        });
      }

      const ride = await Ride.update(rideId, driverId, req.body);

      if (!ride) {
        return res.status(404).json({ message: 'Ride not found' });
      }

      res.json({
        message: 'Ride successfully updated',
        ride
      });
    } catch (error) {
      console.error('Error updating ride:', error);
      res.status(500).json({ message: 'Error updating ride' });
    }
  }

  // Cancel ride
  static async cancelRide(req, res) {
    try {
      const { rideId } = req.params;
      const driverId = req.user.id;

      // Get all accepted bookings
      const bookings = await pool.query(
        `SELECT b.*, u.first_name, u.last_name 
         FROM bookings b 
         JOIN users u ON b.passenger_id = u.id
         WHERE b.ride_id = $1 AND b.status = 'accepted'`,
        [rideId]
      );

      const ride = await Ride.updateStatus(rideId, 'cancelled');

      if (!ride || ride.driver_id !== driverId) {
        return res.status(404).json({ message: 'Ride not found' });
      }

      // Cancel all bookings and send notifications
      for (const booking of bookings.rows) {
        await pool.query(
          'UPDATE bookings SET status = $1 WHERE id = $2',
          ['cancelled', booking.id]
        );

        await Notification.create({
          userId: booking.passenger_id,
          type: 'ride_cancelled',
          title: 'Ride cancelled',
          message: `Ride ${ride.departure_location} → ${ride.arrival_location} has been cancelled by the driver`,
          data: { rideId: String(ride.id), bookingId: String(booking.id) }
        });
      }

      res.json({ message: 'Ride successfully cancelled' });
    } catch (error) {
      console.error('Error cancelling ride:', error);
      res.status(500).json({ message: 'Error cancelling ride' });
    }
  }

  // Delete ride
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
          message: 'You cannot delete a ride that has accepted bookings' 
        });
      }

      const ride = await Ride.delete(rideId, driverId);

      if (!ride) {
        return res.status(404).json({ message: 'Ride not found' });
      }

      res.json({ message: 'Ride successfully deleted' });
    } catch (error) {
      console.error('Error deleting ride:', error);
      res.status(500).json({ message: 'Error deleting ride' });
    }
  }

  // Start ride
  static async startRide(req, res) {
    try {
      const { rideId } = req.params;
      const driverId = req.user.id;

      const ride = await pool.query(
        'SELECT * FROM rides WHERE id = $1 AND driver_id = $2',
        [rideId, driverId]
      );

      if (ride.rows.length === 0) {
        return res.status(404).json({ message: 'Ride not found' });
      }

      await Ride.updateStatus(rideId, 'in_progress');

      res.json({ message: 'Ride started' });
    } catch (error) {
      console.error('Error starting ride:', error);
      res.status(500).json({ message: 'Error starting ride' });
    }
  }

  // End ride
  static async completeRide(req, res) {
    try {
      const { rideId } = req.params;
      const driverId = req.user.id;

      const ride = await pool.query(
        'SELECT * FROM rides WHERE id = $1 AND driver_id = $2',
        [rideId, driverId]
      );

      if (ride.rows.length === 0) {
        return res.status(404).json({ message: 'Ride not found' });
      }

      await Ride.updateStatus(rideId, 'completed');

      // Updating all accepted reservations to completed
      await pool.query(
        `UPDATE bookings 
         SET status = 'completed', completed_at = NOW() 
         WHERE ride_id = $1 AND status = 'accepted'`,
        [rideId]
      );

      // Sending notifications to passengers
      const bookings = await pool.query(
        'SELECT passenger_id FROM bookings WHERE ride_id = $1 AND status = $2',
        [rideId, 'completed']
      );

      for (const booking of bookings.rows) {
        await Notification.create({
          userId: booking.passenger_id,
          type: 'ride_completed',
          title: 'Ride completed',
          message: 'Ride has been successfully completed. Please rate the driver.',
          data: { rideId: String(rideId) }
        });
      }

      res.json({ message: 'Ride successfully completed' });
    } catch (error) {
      console.error('Error completing ride:', error);
      res.status(500).json({ message: 'Error completing ride' });
    }
  }
}

export default RideController;