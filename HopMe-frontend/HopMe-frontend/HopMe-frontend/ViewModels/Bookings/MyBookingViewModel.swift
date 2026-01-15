import Foundation
import SwiftUI
import Combine

@MainActor
class MyBookingsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let bookingService = BookingService.shared
    
    var upcomingBookings: [Booking] {
        bookings.filter {
            $0.ride.departureTime > Date() &&
            $0.status != .cancelled &&
            $0.status != .rejected
        }
    }
    
    var pastBookings: [Booking] {
        bookings.filter {
            $0.ride.departureTime <= Date() ||
            $0.status == .cancelled ||
            $0.status == .rejected
        }
    }
    
    func loadBookings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            bookings = try await bookingService.getMyBookings()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error loading bookings"
        }
        
        isLoading = false
    }
    
    func cancelBooking(id: Int) async {
        do {
            try await bookingService.cancelBooking(id: id)
            bookings.removeAll { $0.id == id }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error canceling booking"
        }
    }
    
    func refreshBookings() async {
        await loadBookings()
    }
}
