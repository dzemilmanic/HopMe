import Foundation

class BookingService {
    static let shared = BookingService()
    private init() {}
    
    private let api = APIService.shared
    
    func createBooking(request: BookingRequest) async throws -> Booking {
        let response: CreateBookingResponse = try await api.request(
            endpoint: .createBooking,
            method: .post,
            body: request,
            requiresAuth: true
        )
        return response.booking
    }
    
    func getMyBookings() async throws -> [Booking] {
        return try await api.request(
            endpoint: .myBookings,
            requiresAuth: true
        )
    }
    
    func getBookingDetails(id: Int) async throws -> Booking {
        return try await api.request(
            endpoint: .booking(id: id),
            requiresAuth: true
        )
    }
    
    func cancelBooking(id: Int) async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .cancelBooking(id: id),
            method: .post,
            requiresAuth: true
        )
    }
    
    func getRideBookings(rideId: Int) async throws -> [Booking] {
        return try await api.request(
            endpoint: .rideBookings(rideId: rideId),
            requiresAuth: true
        )
    }
    
    func acceptBooking(id: Int, response: String?) async throws {
        let body = ["response": response ?? ""]
        let _: EmptyResponse = try await api.request(
            endpoint: .acceptBooking(id: id),
            method: .post,
            body: body,
            requiresAuth: true
        )
    }
    
    func rejectBooking(id: Int, response: String?) async throws {
        let body = ["response": response ?? ""]
        let _: EmptyResponse = try await api.request(
            endpoint: .rejectBooking(id: id),
            method: .post,
            body: body,
            requiresAuth: true
        )
    }
}

struct CreateBookingResponse: Codable {
    let message: String
    let booking: Booking
}
