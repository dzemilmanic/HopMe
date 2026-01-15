import Foundation
import SwiftUI
import Combine

@MainActor
class RideListViewModel: ObservableObject {
    @Published var rides: [Ride] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let rideService = RideService.shared
    
    func loadRides(from: String, to: String, date: Date, seats: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            rides = try await rideService.searchRides(
                from: from,
                to: to,
                date: date,
                seats: seats
            )
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error loading rides"
        }
        
        isLoading = false
    }
}
