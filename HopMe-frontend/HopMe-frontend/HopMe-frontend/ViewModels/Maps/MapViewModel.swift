import Foundation
import CoreLocation
import SwiftUI
import Combine

@MainActor
class MapViewModel: ObservableObject {
    @Published var route: Route?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchResults: [Location] = []
    private let mapsService = MapsService.shared
    
    func getRoute(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D,
        waypoints: [CLLocationCoordinate2D] = []
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            route = try await mapsService.getRoute(
                startLat: from.latitude,
                startLng: from.longitude,
                endLat: to.latitude,
                endLng: to.longitude,
                waypoints: waypoints.map { Coordinate(lat: $0.latitude, lng: $0.longitude) }
            )
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Greška pri rutiranju"
        }
        
        isLoading = false
    }
    
    func searchLocations(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        do {
            searchResults = try await mapsService.searchLocations(query: query, limit: 5)
        } catch {
            searchResults = []
        }
    }
    
    func geocode(address: String) async -> CLLocationCoordinate2D? {
        do {
            let location = try await mapsService.geocode(address: address)
            return location.coordinate
        } catch {
            return nil
        }
    }
}
