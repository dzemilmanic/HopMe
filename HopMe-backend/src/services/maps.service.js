import axios from 'axios';
import NodeGeocoder from 'node-geocoder';

const geocoder = NodeGeocoder({
  provider: 'openstreetmap'
});

class MapsService {
  // Geocoding - pretvara adresu u koordinate
  static async geocodeAddress(address) {
    try {
      const results = await geocoder.geocode(address);
      
      if (results.length > 0) {
        return {
          lat: results[0].latitude,
          lng: results[0].longitude,
          formattedAddress: results[0].formattedAddress,
        };
      }
      
      return null;
    } catch (error) {
      console.error('Geocoding error:', error);
      return null;
    }
  }

  // Reverse geocoding - koordinate u adresu
  static async reverseGeocode(lat, lng) {
    try {
      const results = await geocoder.reverse({ lat, lon: lng });
      
      if (results.length > 0) {
        return {
          address: results[0].formattedAddress,
          city: results[0].city,
          country: results[0].country,
        };
      }
      
      return null;
    } catch (error) {
      console.error('Reverse geocoding error:', error);
      return null;
    }
  }

  // Dobijanje rute između dve tačke (OpenRouteService ili OSRM)
  static async getRoute(startLat, startLng, endLat, endLng, waypoints = []) {
    try {
      // Koristimo OSRM (open-source routing engine)
      let coordinates = `${startLng},${startLat}`;
      
      // Dodaj waypoints
      waypoints.forEach(wp => {
        coordinates += `;${wp.lng},${wp.lat}`;
      });
      
      coordinates += `;${endLng},${endLat}`;
      
      const response = await axios.get(
        `https://router.project-osrm.org/route/v1/driving/${coordinates}`,
        {
          params: {
            overview: 'full',
            geometries: 'geojson',
            steps: true,
          }
        }
      );

      if (response.data.code === 'Ok') {
        const route = response.data.routes[0];
        
        return {
          distance: route.distance, // u metrima
          duration: route.duration, // u sekundama
          geometry: route.geometry, // GeoJSON format za Leaflet
          steps: route.legs[0].steps.map(step => ({
            instruction: step.maneuver.type,
            distance: step.distance,
            duration: step.duration,
            name: step.name,
          })),
        };
      }
      
      return null;
    } catch (error) {
      console.error('Routing error:', error);
      return null;
    }
  }

  // Kalkulacija distance između dve tačke (Haversine formula)
  static calculateDistance(lat1, lng1, lat2, lng2) {
    const R = 6371; // Radius Zemlje u km
    const dLat = this.toRad(lat2 - lat1);
    const dLng = this.toRad(lng2 - lng1);
    
    const a = 
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
      Math.sin(dLng / 2) * Math.sin(dLng / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;
    
    return Math.round(distance * 100) / 100; // Zaokruži na 2 decimale
  }

  static toRad(degrees) {
    return degrees * (Math.PI / 180);
  }

  // Formatiranje vremena trajanja
  static formatDuration(seconds) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    
    if (hours > 0) {
      return `${hours}h ${minutes}min`;
    }
    return `${minutes}min`;
  }

  // Formatiranje distance
  static formatDistance(meters) {
    const km = meters / 1000;
    if (km < 1) {
      return `${Math.round(meters)}m`;
    }
    return `${Math.round(km * 10) / 10}km`;
  }

  // Dobijanje nearby lokacija (gradovi, landmarks)
  static async getNearbyPlaces(lat, lng, radius = 5000) {
    try {
      // Koristi Overpass API za OSM data
      const query = `
        [out:json];
        (
          node["place"="city"](around:${radius},${lat},${lng});
          node["place"="town"](around:${radius},${lat},${lng});
        );
        out body;
      `;
      
      const response = await axios.post(
        'https://overpass-api.de/api/interpreter',
        query,
        { headers: { 'Content-Type': 'text/plain' } }
      );

      return response.data.elements.map(el => ({
        name: el.tags.name,
        type: el.tags.place,
        lat: el.lat,
        lng: el.lon,
      }));
    } catch (error) {
      console.error('Nearby places error:', error);
      return [];
    }
  }

  // Autocomplete za lokacije
  static async searchLocations(query, limit = 5) {
    try {
      const response = await axios.get(
        'https://nominatim.openstreetmap.org/search',
        {
          params: {
            q: query,
            format: 'json',
            limit: limit,
            countrycodes: 'rs', // Samo Srbija
            addressdetails: 1,
          },
          headers: {
            'User-Agent': 'HopMe-App',
          }
        }
      );

      return response.data.map(result => ({
        name: result.display_name,
        lat: parseFloat(result.lat),
        lng: parseFloat(result.lon),
        type: result.type,
        address: {
          city: result.address.city || result.address.town,
          road: result.address.road,
          postcode: result.address.postcode,
        }
      }));
    } catch (error) {
      console.error('Location search error:', error);
      return [];
    }
  }
}

export default MapsService;