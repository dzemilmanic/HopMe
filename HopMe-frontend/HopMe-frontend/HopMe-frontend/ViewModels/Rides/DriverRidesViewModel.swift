import Foundation
import SwiftUI
import Combine

@MainActor
class DriverRidesViewModel: ObservableObject {
    @Published var rides: [Ride] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedRide: Ride?
    
    private let rideService = RideService.shared
    
    var upcomingRides: [Ride] {
        rides.filter { $0.status == .scheduled && $0.departureTime > Date() }
    }
    
    var activeRides: [Ride] {
        rides.filter { $0.status == .inProgress }
    }
    
    var pastRides: [Ride] {
        rides.filter { $0.status == .completed || $0.departureTime < Date() }
    }
    
    func loadMyRides() async {
        isLoading = true
        errorMessage = nil
        
        do {
            rides = try await rideService.getMyRides()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error loading rides"
        }
        
        isLoading = false
    }
    
    func cancelRide(id: Int) async {
        do {
            try await rideService.cancelRide(id: id)
            rides.removeAll { $0.id == id }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error canceling ride"
        }
    }
    
    func startRide(id: Int) async {
        do {
            try await rideService.startRide(id: id)
            await loadMyRides()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error starting ride"
        }
    }
    
    func completeRide(id: Int) async {
        do {
            try await rideService.completeRide(id: id)
            await loadMyRides()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error completing ride"
        }
    }
}
