import Foundation
import SwiftUI
import Combine

@MainActor
class BookingViewModel: ObservableObject {
    @Published var ride: Ride
    @Published var seatsBooked = 1
    @Published var pickupLocation = ""
    @Published var dropoffLocation = ""
    @Published var message = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let bookingService = BookingService.shared
    
    init(ride: Ride) {
        self.ride = ride
    }
    
    var totalPrice: Int {
        Int(ride.pricePerSeat) * seatsBooked
    }
    
    var canBook: Bool {
        seatsBooked > 0 && seatsBooked <= ride.remainingSeats
    }
    
    func createBooking() async -> Bool {
        guard canBook else {
            errorMessage = "Nevažeći broj mesta"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = BookingRequest(
            rideId: ride.id,
            seatsBooked: seatsBooked,
            pickupLocation: pickupLocation.isEmpty ? nil : pickupLocation,
            dropoffLocation: dropoffLocation.isEmpty ? nil : dropoffLocation,
            message: message.isEmpty ? nil : message
        )
        
        do {
            _ = try await bookingService.createBooking(request: request)
            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Greška pri rezervaciji"
            isLoading = false
            return false
        }
    }
}
