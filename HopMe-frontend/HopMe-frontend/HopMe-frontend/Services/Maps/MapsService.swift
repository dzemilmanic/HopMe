import Foundation
import CoreLocation

class MapsService {
    static let shared = MapsService()
    private init() {}
    
    private let api = APIService.shared
    
    func geocode(address: String) async throws -> Location {
        return try await api.request(
            endpoint: .geocode(address: address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? address)
        )
    }
    
    func reverseGeocode(lat: Double, lng: Double) async throws -> Location {
        return try await api.request(
            endpoint: .reverseGeocode(lat: lat, lng: lng)
        )
    }
    
    func getRoute(
        startLat: Double,
        startLng: Double,
        endLat: Double,
        endLng: Double,
        waypoints: [Coordinate]? = nil
    ) async throws -> Route {
        
        let body = RouteRequest(
            startLat: startLat,
            startLng: startLng,
            endLat: endLat,
            endLng: endLng,
            waypoints: waypoints?.map {
                RouteWaypoint(lat: $0.lat, lng: $0.lng)
            } ?? []
        )
        
        return try await api.request(
            endpoint: .route,
            method: .post,
            body: body
        )
    }


    
    func calculateDistance(
        lat1: Double,
        lng1: Double,
        lat2: Double,
        lng2: Double
    ) async throws -> Double {
        
        let response: DistanceResponse = try await api.request(
            endpoint: .distance(lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
        )
        
        return response.distanceKm
    }
    
    func searchLocations(query: String, limit: Int = 5) async throws -> [Location] {
        return try await api.request(
            endpoint: .searchLocations(
                query: query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query,
                limit: limit
            )
        )
    }
}

struct DistanceResponse: Codable {
    let distance: String
    let distanceKm: Double
}

struct RouteRequest: Encodable {
    let startLat: Double
    let startLng: Double
    let endLat: Double
    let endLng: Double
    let waypoints: [RouteWaypoint]
}

struct RouteWaypoint: Encodable {
    let lat: Double
    let lng: Double
}

