import MapsService from '../services/maps.service.js';

class MapsController {
  // GET /api/maps/geocode?address=Beograd
  static async geocode(req, res) {
    try {
      const { address } = req.query;
      
      if (!address) {
        return res.status(400).json({ message: 'Adresa je obavezna' });
      }

      const result = await MapsService.geocodeAddress(address);
      
      if (!result) {
        return res.status(404).json({ message: 'Lokacija nije pronađena' });
      }

      res.json(result);
    } catch (error) {
      console.error('Geocode error:', error);
      res.status(500).json({ message: 'Greška pri geocoding-u' });
    }
  }

  // GET /api/maps/reverse?lat=44.7866&lng=20.4489
  static async reverseGeocode(req, res) {
    try {
      const { lat, lng } = req.query;
      
      if (!lat || !lng) {
        return res.status(400).json({ message: 'Koordinate su obavezne' });
      }

      const result = await MapsService.reverseGeocode(
        parseFloat(lat),
        parseFloat(lng)
      );
      
      if (!result) {
        return res.status(404).json({ message: 'Adresa nije pronađena' });
      }

      res.json(result);
    } catch (error) {
      console.error('Reverse geocode error:', error);
      res.status(500).json({ message: 'Greška pri reverse geocoding-u' });
    }
  }

  // POST /api/maps/route
  static async getRoute(req, res) {
    try {
      const { startLat, startLng, endLat, endLng, waypoints } = req.body;
      
      if (!startLat || !startLng || !endLat || !endLng) {
        return res.status(400).json({ 
          message: 'Start i end koordinate su obavezne' 
        });
      }

      const route = await MapsService.getRoute(
        parseFloat(startLat),
        parseFloat(startLng),
        parseFloat(endLat),
        parseFloat(endLng),
        waypoints || []
      );
      
      if (!route) {
        return res.status(404).json({ message: 'Ruta nije pronađena' });
      }

      res.json({
        distance: MapsService.formatDistance(route.distance),
        distanceMeters: route.distance,
        duration: MapsService.formatDuration(route.duration),
        durationSeconds: route.duration,
        geometry: route.geometry,
        steps: route.steps,
      });
    } catch (error) {
      console.error('Route error:', error);
      res.status(500).json({ message: 'Greška pri rutiranju' });
    }
  }

  // GET /api/maps/distance?lat1=44.7866&lng1=20.4489&lat2=45.2671&lng2=19.8335
  static async calculateDistance(req, res) {
    try {
      const { lat1, lng1, lat2, lng2 } = req.query;
      
      if (!lat1 || !lng1 || !lat2 || !lng2) {
        return res.status(400).json({ message: 'Sve koordinate su obavezne' });
      }

      const distance = MapsService.calculateDistance(
        parseFloat(lat1),
        parseFloat(lng1),
        parseFloat(lat2),
        parseFloat(lng2)
      );

      res.json({
        distance: `${distance}km`,
        distanceKm: distance,
      });
    } catch (error) {
      console.error('Distance calculation error:', error);
      res.status(500).json({ message: 'Greška pri kalkulaciji' });
    }
  }

  // GET /api/maps/search?query=Beograd
  static async searchLocations(req, res) {
    try {
      const { query, limit } = req.query;
      
      if (!query) {
        return res.status(400).json({ message: 'Query je obavezan' });
      }

      const results = await MapsService.searchLocations(
        query,
        limit ? parseInt(limit) : 5
      );

      res.json(results);
    } catch (error) {
      console.error('Search error:', error);
      res.status(500).json({ message: 'Greška pri pretrazi' });
    }
  }

  // GET /api/maps/nearby?lat=44.7866&lng=20.4489&radius=5000
  static async getNearbyPlaces(req, res) {
    try {
      const { lat, lng, radius } = req.query;
      
      if (!lat || !lng) {
        return res.status(400).json({ message: 'Koordinate su obavezne' });
      }

      const places = await MapsService.getNearbyPlaces(
        parseFloat(lat),
        parseFloat(lng),
        radius ? parseInt(radius) : 5000
      );

      res.json(places);
    } catch (error) {
      console.error('Nearby places error:', error);
      res.status(500).json({ message: 'Greška pri pretrazi' });
    }
  }
}

export default MapsController;