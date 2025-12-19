import Foundation

@MainActor
class BookingDetailViewModel: ObservableObject {
    @Published var booking: Booking
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let bookingService = BookingService.shared
    
    init(booking: Booking) {
        self.booking = booking
    }
    
    func cancelBooking() async -> Bool {
        isLoading = true
        
        do {
            try await bookingService.cancelBooking(id: booking.id)
            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Greška"
            isLoading = false
            return false
        }
    }
}
