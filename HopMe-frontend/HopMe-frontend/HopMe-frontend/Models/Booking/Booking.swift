import Foundation

struct Booking: Codable, Identifiable {
    let id: Int
    let rideId: Int
    let passengerId: Int
    let seatsBooked: Int
    let totalPrice: Double
    let status: BookingStatus
    let pickupLocation: String?
    let dropoffLocation: String?
    let message: String?
    let driverResponse: String?
    let ride: RideInfo
    let createdAt: Date
    let acceptedAt: Date?
    let completedAt: Date?
    
    var formattedPrice: String {
        "\(Int(totalPrice)) RSD"
    }
    
    var canCancel: Bool {
        status == .pending || status == .accepted
    }
    
    var canRate: Bool {
        status == .completed
    }
    
    var isPast: Bool {
        ride.departureTime < Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, status, message, ride
        case rideId = "ride_id"
        case passengerId = "passenger_id"
        case seatsBooked = "seats_booked"
        case totalPrice = "total_price"
        case pickupLocation = "pickup_location"
        case dropoffLocation = "dropoff_location"
        case driverResponse = "driver_response"
        case createdAt = "created_at"
        case acceptedAt = "accepted_at"
        case completedAt = "completed_at"
    }
}
