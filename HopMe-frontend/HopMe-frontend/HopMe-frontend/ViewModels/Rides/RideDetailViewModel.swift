import Foundation
import SwiftUI
import Combine

@MainActor
class RideDetailViewModel: ObservableObject {
    @Published var ride: Ride
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let rideService = RideService.shared
    
    init(ride: Ride) {
        self.ride = ride
    }
    
    func loadRideDetails() async {
        isLoading = true
        
        do {
            ride = try await rideService.getRideDetails(id: ride.id)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Greška pri učitavanju"
        }
        
        isLoading = false
    }
    
    func refreshRide() async {
        await loadRideDetails()
    }
}
