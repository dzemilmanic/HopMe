import Booking from '../models/Booking.js';
import Ride from '../models/Ride.js';
import Notification from '../models/Notification.js';
import pool from '../config/database.js';

class BookingController {
  // Kreiranje rezervacije
  static async createBooking(req, res) {
    try {
      const passengerId = req.user.id;
      const { rideId, seatsBooked, pickupLocation, dropoffLocation, message } = req.body;

      // Provera da li vožnja postoji
      const ride = await Ride.findById(rideId);
      if (!ride) {
        return res.status(404).json({ message: 'Vožnja nije pronađena' });
      }

      // Provera da li vozač pokušava da rezerviše svoju vožnju
      if (ride.driver.id === passengerId) {
        return res.status(400).json({ message: 'Ne možete rezervisati sopstvenu vožnju' });
      }

      // Provera dostupnosti mesta
      const isAvailable = await Booking.checkAvailability(rideId, seatsBooked);
      if (!isAvailable) {
        return res.status(400).json({ message: 'Nema dovoljno slobodnih mesta' });
      }

      // Provera da li već postoji pending ili accepted rezervacija
      const existingBooking = await pool.query(
        'SELECT * FROM bookings WHERE ride_id = $1 AND passenger_id = $2 AND status IN ($3, $4)',
        [rideId, passengerId, 'pending', 'accepted']
      );

      if (existingBooking.rows.length > 0) {
        return res.status(400).json({ 
          message: 'Već imate aktivnu rezervaciju za ovu vožnju' 
        });
      }

      const totalPrice = ride.price_per_seat * seatsBooked;

      const booking = await Booking.create({
        rideId, passengerId, seatsBooked, totalPrice,
        pickupLocation, dropoffLocation, message
      });

      // Automatsko prihvatanje ako je uključeno
      if (ride.auto_accept_bookings) {
        await Booking.updateStatus(booking.id, 'accepted');
        
        await Notification.create({
          userId: passengerId,
          type: 'booking_accepted',
          title: 'Rezervacija prihvaćena',
          message: `Vaša rezervacija za vožnju ${ride.departure_location} → ${ride.arrival_location} je automatski prihvaćena`,
          data: { bookingId: String(booking.id), rideId: String(rideId) }
        });
      } else {
        // Notifikacija vozaču
        await Notification.create({
          userId: ride.driver.id,
          type: 'new_booking',
          title: 'Nova rezervacija',
          message: `Imate novu rezervaciju za vožnju ${ride.departure_location} → ${ride.arrival_location}`,
          data: { bookingId: String(booking.id), rideId: String(rideId) }
        });
      }

      const bookingDetails = await Booking.findById(booking.id);

      res.status(201).json({
        message: ride.auto_accept_bookings ? 'Rezervacija automatski prihvaćena' : 'Rezervacija poslata vozaču',
        booking: bookingDetails
      });
    } catch (error) {
      console.error('Greška pri kreiranju rezervacije:', error);
      res.status(500).json({ message: 'Greška pri kreiranju rezervacije' });
    }
  }

  // Rezervacije putnika
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
      console.error('Greška pri učitavanju rezervacija:', error);
      res.status(500).json({ message: 'Greška pri učitavanju' });
    }
  }

  // Rezervacije za vožnju (vozač)
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
        return res.status(403).json({ message: 'Nemate pristup ovoj vožnji' });
      }

      const bookings = await Booking.findByRideId(rideId);

      res.json(bookings);
    } catch (error) {
      console.error('Greška pri učitavanju rezervacija:', error);
      res.status(500).json({ message: 'Greška pri učitavanju' });
    }
  }

  // Prihvatanje rezervacije (vozač)
  static async acceptBooking(req, res) {
    try {
      const { bookingId } = req.params;
      const driverId = req.user.id;
      const { response } = req.body;

      const booking = await Booking.findById(bookingId);

      if (!booking) {
        return res.status(404).json({ message: 'Rezervacija nije pronađena' });
      }

      if (booking.ride.driverId !== driverId) {
        return res.status(403).json({ message: 'Nemate pristup ovoj rezervaciji' });
      }

      if (booking.status !== 'pending') {
        return res.status(400).json({ message: 'Rezervacija već obrađena' });
      }

      // Provera dostupnosti
      const isAvailable = await Booking.checkAvailability(
        booking.ride_id, 
        booking.seats_booked
      );

      if (!isAvailable) {
        return res.status(400).json({ message: 'Nema više slobodnih mesta' });
      }

      await Booking.updateStatus(bookingId, 'accepted', response);

      // Notifikacija putniku
      await Notification.create({
        userId: booking.passenger.id,
        type: 'booking_accepted',
        title: 'Rezervacija prihvaćena',
        message: `Vaša rezervacija je prihvaćena za vožnju ${booking.ride.departureLocation} → ${booking.ride.arrivalLocation}`,
        data: { bookingId: String(bookingId), rideId: String(booking.ride.id) }
      });

      res.json({ message: 'Rezervacija prihvaćena' });
    } catch (error) {
      console.error('❌ Greška pri prihvatanju rezervacije:', error);
      console.error('   Error message:', error.message);
      console.error('   Error code:', error.code);
      console.error('   Error detail:', error.detail);
      res.status(500).json({ message: 'Greška pri prihvatanju' });
    }
  }

  // Odbijanje rezervacije (vozač)
  static async rejectBooking(req, res) {
    try {
      const { bookingId } = req.params;
      const driverId = req.user.id;
      const { response } = req.body;

      const booking = await Booking.findById(bookingId);

      if (!booking) {
        return res.status(404).json({ message: 'Rezervacija nije pronađena' });
      }

      if (booking.ride.driverId !== driverId) {
        return res.status(403).json({ message: 'Nemate pristup ovoj rezervaciji' });
      }

      if (booking.status !== 'pending') {
        return res.status(400).json({ message: 'Rezervacija već obrađena' });
      }

      await Booking.updateStatus(bookingId, 'rejected', response);

      // Notifikacija putniku
      await Notification.create({
        userId: booking.passenger.id,
        type: 'booking_rejected',
        title: 'Rezervacija odbijena',
        message: `Vaša rezervacija za vožnju ${booking.ride.departureLocation} → ${booking.ride.arrivalLocation} je odbijena`,
        data: { bookingId: String(bookingId), rideId: String(booking.ride_id) }
      });

      res.json({ message: 'Rezervacija odbijena' });
    } catch (error) {
      console.error('Greška pri odbijanju:', error);
      res.status(500).json({ message: 'Greška pri odbijanju' });
    }
  }

  // Otkazivanje rezervacije (putnik)
  static async cancelBooking(req, res) {
    try {
      const { bookingId } = req.params;
      const passengerId = req.user.id;

      const booking = await Booking.findById(bookingId);

      if (!booking) {
        return res.status(404).json({ message: 'Rezervacija nije pronađena' });
      }

      if (booking.passenger_id !== passengerId) {
        return res.status(403).json({ message: 'Nemate pristup ovoj rezervaciji' });
      }

      // Provera da li je vožnja već počela
      const ride = await Ride.findById(booking.ride_id);
      if (new Date(ride.departure_time) < new Date()) {
        return res.status(400).json({ 
          message: 'Ne možete otkazati rezervaciju nakon početka vožnje' 
        });
      }

      await Booking.cancelBooking(bookingId, passengerId);

      // Notifikacija vozaču
      await Notification.create({
        userId: ride.driver.id,
        type: 'booking_cancelled',
        title: 'Rezervacija otkazana',
        message: `Putnik je otkazao rezervaciju za vožnju ${ride.departure_location} → ${ride.arrival_location}`,
        data: { bookingId: String(bookingId), rideId: String(booking.ride_id) }
      });

      res.json({ message: 'Rezervacija otkazana' });
    } catch (error) {
      console.error('Greška pri otkazivanju:', error);
      res.status(500).json({ message: 'Greška pri otkazivanju' });
    }
  }

  // Detalji rezervacije
  static async getBookingDetails(req, res) {
    try {
      const { bookingId } = req.params;
      const userId = req.user.id;

      const booking = await Booking.findById(bookingId);

      if (!booking) {
        return res.status(404).json({ message: 'Rezervacija nije pronađena' });
      }

      // Provera pristupa
      if (booking.passenger.id !== userId && booking.ride.driverId !== userId) {
        return res.status(403).json({ message: 'Nemate pristup ovoj rezervaciji' });
      }

      res.json(booking);
    } catch (error) {
      console.error('Greška pri učitavanju detalja:', error);
      res.status(500).json({ message: 'Greška pri učitavanju' });
    }
  }
}

export default BookingController;