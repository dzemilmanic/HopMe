import Booking from '../models/Booking.js';
import Ride from '../models/Ride.js';
import Notification from '../models/Notification.js';
import pool from '../config/database.js';

class BookingController {
  // Creating a reservation
  static async createBooking(req, res) {
    try {
      const passengerId = req.user.id;
      const { rideId, seatsBooked, pickupLocation, dropoffLocation, message } = req.body;

      // Checking if the ride exists
      const ride = await Ride.findById(rideId);
      if (!ride) {
        return res.status(404).json({ message: 'Ride not found' });
      }

      // Checking if the driver is trying to book their own ride
      if (ride.driver.id === passengerId) {
        return res.status(400).json({ message: 'You cannot book your own ride' });
      }

      // Checking availability of seats
      const isAvailable = await Booking.checkAvailability(rideId, seatsBooked);
      if (!isAvailable) {
        return res.status(400).json({ message: 'Not enough available seats' });
      }

      // Checking if the passenger already has a pending or accepted booking
      const existingBooking = await pool.query(
        'SELECT * FROM bookings WHERE ride_id = $1 AND passenger_id = $2 AND status IN ($3, $4)',
        [rideId, passengerId, 'pending', 'accepted']
      );

      if (existingBooking.rows.length > 0) {
        return res.status(400).json({ 
          message: 'You already have an active booking for this ride' 
        });
      }

      const totalPrice = ride.price_per_seat * seatsBooked;

      const booking = await Booking.create({
        rideId, passengerId, seatsBooked, totalPrice,
        pickupLocation, dropoffLocation, message
      });

      // Automatically accepting if enabled
      if (ride.auto_accept_bookings) {
        await Booking.updateStatus(booking.id, 'accepted');
        
        await Notification.create({
          userId: passengerId,
          type: 'booking_accepted',
          title: 'Booking accepted',
          message: `Your booking for the ride ${ride.departure_location} → ${ride.arrival_location} has been automatically accepted`,
          data: { bookingId: String(booking.id), rideId: String(rideId) }
        });
      } else {
        // Notifying the driver
        await Notification.create({
          userId: ride.driver.id,
          type: 'new_booking',
          title: 'New booking',
          message: `You have a new booking for the ride ${ride.departure_location} → ${ride.arrival_location}`,
          data: { bookingId: String(booking.id), rideId: String(rideId) }
        });
      }

      const bookingDetails = await Booking.findById(booking.id);

      res.status(201).json({
        message: ride.auto_accept_bookings ? 'Booking automatically accepted' : 'Booking sent to driver',
        booking: bookingDetails
      });
    } catch (error) {
      console.error('Error creating booking:', error);
      res.status(500).json({ message: 'Error creating booking' });
    }
  }

  // Passenger's bookings
  static async getPassengerBookings(req, res) {
    try {
      const passengerId = req.user.id;
      const { status } = req.query;

      let bookings = await Booking.findByPassengerId(passengerId);

      if (status) {
        bookings = bookings.filter(b => b.status === status);
      }

      res.json(bookings);
    } catch (error) {
      console.error('Error loading bookings:', error);
      res.status(500).json({ message: 'Error loading bookings' });
    }
  }

  // Driver's bookings
  static async getRideBookings(req, res) {
    try {
      const { rideId } = req.params;
      const driverId = req.user.id;

      // Provera da li vožnja pripada vozaču
      const ride = await pool.query(
        'SELECT * FROM rides WHERE id = $1 AND driver_id = $2',
        [rideId, driverId]
      );

      if (ride.rows.length === 0) {
        return res.status(403).json({ message: 'You do not have access to this ride' });
      }

      const bookings = await Booking.findByRideId(rideId);

      res.json(bookings);
    } catch (error) {
      console.error('Error loading bookings:', error);
      res.status(500).json({ message: 'Error loading bookings' });
    }
  }

  // Accepting a booking (driver)
  static async acceptBooking(req, res) {
    try {
      const { bookingId } = req.params;
      const driverId = req.user.id;
      const { response } = req.body;

      const booking = await Booking.findById(bookingId);

      if (!booking) {
        return res.status(404).json({ message: 'Booking not found' });
      }

      if (booking.ride.driverId !== driverId) {
        return res.status(403).json({ message: 'You do not have access to this booking' });
      }

      if (booking.status !== 'pending') {
        return res.status(400).json({ message: 'Booking already processed' });
      }

      // Checking availability
      const isAvailable = await Booking.checkAvailability(
        booking.ride_id, 
        booking.seats_booked
      );

      if (!isAvailable) {
        return res.status(400).json({ message: 'Not enough available seats' });
      }

      await Booking.updateStatus(bookingId, 'accepted', response);

      // Notifying the passenger
      await Notification.create({
        userId: booking.passenger.id,
        type: 'booking_accepted',
        title: 'Booking accepted',
        message: `Your booking has been accepted for the ride ${booking.ride.departureLocation} → ${booking.ride.arrivalLocation}`,
        data: { bookingId: String(bookingId), rideId: String(booking.ride.id) }
      });

      res.json({ message: 'Booking accepted' });
    } catch (error) {
      console.error('❌ Error accepting booking:', error);
      console.error('   Error message:', error.message);
      console.error('   Error code:', error.code);
      console.error('   Error detail:', error.detail);
      res.status(500).json({ message: 'Error accepting booking' });
    }
  }

  // Rejecting a booking (driver)
  static async rejectBooking(req, res) {
    try {
      const { bookingId } = req.params;
      const driverId = req.user.id;
      const { response } = req.body;

      const booking = await Booking.findById(bookingId);

      if (!booking) {
        return res.status(404).json({ message: 'Booking not found' });
      }

      if (booking.ride.driverId !== driverId) {
        return res.status(403).json({ message: 'You do not have access to this booking' });
      }

      if (booking.status !== 'pending') {
        return res.status(400).json({ message: 'Booking already processed' });
      }

      await Booking.updateStatus(bookingId, 'rejected', response);

      // Notifying the passenger
      await Notification.create({
        userId: booking.passenger.id,
        type: 'booking_rejected',
        title: 'Booking rejected',
        message: `Your booking for the ride ${booking.ride.departureLocation} → ${booking.ride.arrivalLocation} has been rejected`,
        data: { bookingId: String(bookingId), rideId: String(booking.ride_id) }
      });

      res.json({ message: 'Booking rejected' });
    } catch (error) {
      console.error('❌ Error rejecting booking:', error);
      res.status(500).json({ message: 'Error rejecting booking' });
    }
  }

  // Canceling a booking (passenger)
  static async cancelBooking(req, res) {
    try {
      const { bookingId } = req.params;
      const passengerId = req.user.id;

      const booking = await Booking.findById(bookingId);

      if (!booking) {
        return res.status(404).json({ message: 'Booking not found' });
      }

      if (booking.passenger_id !== passengerId) {
        return res.status(403).json({ message: 'You do not have access to this booking' });
      }

      // Checking if the ride has started
      const ride = await Ride.findById(booking.ride_id);
      if (new Date(ride.departure_time) < new Date()) {
        return res.status(400).json({ 
          message: 'You cannot cancel the booking after the ride has started' 
        });
      }

      await Booking.cancelBooking(bookingId, passengerId);

      // Notifying the driver
      await Notification.create({
        userId: ride.driver.id,
        type: 'booking_cancelled',
        title: 'Booking cancelled',
        message: `Passenger has cancelled the booking for the ride ${ride.departure_location} → ${ride.arrival_location}`,
        data: { bookingId: String(bookingId), rideId: String(booking.ride_id) }
      });

      res.json({ message: 'Booking cancelled' });
    } catch (error) {
      console.error('❌ Error cancelling booking:', error);
      res.status(500).json({ message: 'Error cancelling booking' });
    }
  }

  // Booking details
  static async getBookingDetails(req, res) {
    try {
      const { bookingId } = req.params;
      const userId = req.user.id;

      const booking = await Booking.findById(bookingId);

      if (!booking) {
        return res.status(404).json({ message: 'Booking not found' });
      }

      // Checking access
      if (booking.passenger.id !== userId && booking.ride.driverId !== userId) {
        return res.status(403).json({ message: 'You do not have access to this booking' });
      }

      res.json(booking);
    } catch (error) {
      console.error('❌ Error loading booking details:', error);
      res.status(500).json({ message: 'Error loading booking details' });
    }
  }
}

export default BookingController;