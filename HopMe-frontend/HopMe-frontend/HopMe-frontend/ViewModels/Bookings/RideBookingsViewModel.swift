import Foundation
import SwiftUI
import Combine

@MainActor
class RideBookingsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let bookingService = BookingService.shared
    let rideId: Int
    
    init(rideId: Int) {
        self.rideId = rideId
    }
    
    var pendingBookings: [Booking] {
        bookings.filter { $0.status == .pending }
    }
    
    var acceptedBookings: [Booking] {
        bookings.filter { $0.status == .accepted }
    }
    
    var otherBookings: [Booking] {
        bookings.filter { $0.status != .pending && $0.status != .accepted }
    }
    
    func loadBookings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            bookings = try await bookingService.getRideBookings(rideId: rideId)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Greška pri učitavanju"
        }
        
        isLoading = false
    }
    
    func acceptBooking(id: Int, response: String?) async {
        do {
            try await bookingService.acceptBooking(id: id, response: response)
            await loadBookings()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Greška"
        }
    }
    
    func rejectBooking(id: Int, response: String?) async {
        do {
            try await bookingService.rejectBooking(id: id, response: response)
            await loadBookings()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Greška"
        }
    }
}
