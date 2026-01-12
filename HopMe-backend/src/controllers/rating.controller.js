import Rating from '../models/Rating.js';
import Notification from '../models/Notification.js';
import pool from '../config/database.js';

class RatingController {
  // Ocenjivanje
  static async createRating(req, res) {
    try {
      const raterId = req.user.id;
      const { bookingId, rating, comment } = req.body;

      if (rating < 1 || rating > 5) {
        return res.status(400).json({ message: 'Ocena mora biti između 1 i 5' });
      }

      // Provera da li korisnik može oceniti
      const canRate = await Rating.canRate(bookingId, raterId);

      if (!canRate.canRate) {
        return res.status(400).json({ message: canRate.reason });
      }

      // Određivanje ko ocenjuje koga
      const ratedId = raterId === canRate.passengerId 
        ? canRate.driverId 
        : canRate.passengerId;

      const ratingRecord = await Rating.create({
        bookingId,
        rideId: req.body.rideId,
        raterId,
        ratedId,
        rating,
        comment
      });

      // Notifikacija ocenjenom korisniku
      await Notification.create({
        userId: ratedId,
        type: 'new_rating',
        title: 'Nova ocena',
        message: `Dobili ste ocenu ${rating}/5`,
        data: { ratingId: ratingRecord.id, bookingId }
      });

      res.status(201).json({
        message: 'Ocena uspešno dodata',
        rating: ratingRecord
      });
    } catch (error) {
      console.error('Greška pri ocenjivanju:', error);
      res.status(500).json({ message: 'Greška pri ocenjivanju' });
    }
  }

  // Ocene korisnika
  static async getUserRatings(req, res) {
    try {
      const { userId } = req.params;

      const ratings = await Rating.findByUserId(userId);
      const stats = await Rating.getUserStats(userId);

      res.json({
        ratings,
        stats: stats || {
          total_ratings: 0,
          average_rating: 0,
          five_star: 0,
          four_star: 0,
          three_star: 0,
          two_star: 0,
          one_star: 0
        }
      });
    } catch (error) {
      console.error('Greška pri učitavanju ocena:', error);
      res.status(500).json({ message: 'Greška pri učitavanju' });
    }
  }

  // Moje ocene (koje sam dao)
  static async getMyRatings(req, res) {
    try {
      const raterId = req.user.id;

      const result = await pool.query(
        `SELECT 
          r.*,
          json_build_object(
            'id', rated.id,
            'firstName', rated.first_name,
            'lastName', rated.last_name,
            'profileImage', rated.profile_image_url
          ) as rated_user
         FROM ratings r
         JOIN users rated ON r.rated_id = rated.id
         WHERE r.rater_id = $1
         ORDER BY r.created_at DESC`,
        [raterId]
      );

      res.json(result.rows);
    } catch (error) {
      console.error('Greška:', error);
      res.status(500).json({ message: 'Greška' });
    }
  }

  // Sve moje ocene (primljene i date)
  static async getAllMyRatings(req, res) {
    try {
      const userId = req.user.id;

      // Ocene koje sam dobio
      const receivedResult = await pool.query(
        `SELECT 
          r.id,
          r.booking_id AS "booking_id",
          r.ride_id AS "ride_id",
          r.rater_id AS "rater_id",
          r.rated_id AS "rated_id",
          r.rating,
          r.comment,
          r.created_at AS "created_at",
          json_build_object(
            'id', rater.id,
            'firstName', rater.first_name,
            'lastName', rater.last_name,
            'profileImage', rater.profile_image_url
          ) as rater
         FROM ratings r
         JOIN users rater ON r.rater_id = rater.id
         WHERE r.rated_id = $1
         ORDER BY r.created_at DESC`,
        [userId]
      );

      // Ocene koje sam dao
      const givenResult = await pool.query(
        `SELECT 
          r.id,
          r.booking_id AS "booking_id",
          r.ride_id AS "ride_id",
          r.rater_id AS "rater_id",
          r.rated_id AS "rated_id",
          r.rating,
          r.comment,
          r.created_at AS "created_at",
          json_build_object(
            'id', rated.id,
            'firstName', rated.first_name,
            'lastName', rated.last_name,
            'profileImage', rated.profile_image_url
          ) as rated
         FROM ratings r
         JOIN users rated ON r.rated_id = rated.id
         WHERE r.rater_id = $1
         ORDER BY r.created_at DESC`,
        [userId]
      );

      // Statistika
      const statsResult = await pool.query(
        `SELECT 
          COUNT(*) as total_received,
          COALESCE(AVG(rating), 0) as average_received
         FROM ratings
         WHERE rated_id = $1`,
        [userId]
      );

      const givenCountResult = await pool.query(
        `SELECT COUNT(*) as total_given
         FROM ratings
         WHERE rater_id = $1`,
        [userId]
      );

      res.json({
        receivedRatings: receivedResult.rows,
        givenRatings: givenResult.rows,
        stats: {
          total_received: parseInt(statsResult.rows[0].total_received),
          average_received: parseFloat(statsResult.rows[0].average_received),
          total_given: parseInt(givenCountResult.rows[0].total_given)
        }
      });
    } catch (error) {
      console.error('Greška:', error);
      res.status(500).json({ message: 'Greška pri učitavanju ocena' });
    }
  }
}

export default RatingController;