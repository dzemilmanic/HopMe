import Foundation

struct Ride: Codable, Identifiable {
    let id: Int
    let driverId: Int
    let vehicleId: Int?
    let departureLocation: String
    let departureLat: Double?
    let departureLng: Double?
    let arrivalLocation: String
    let arrivalLat: Double?
    let arrivalLng: Double?
    let departureTime: Date
    let arrivalTime: Date?
    let availableSeats: Int
    let pricePerSeat: Double
    let currency: String
    let description: String?
    let status: RideStatus
    let autoAcceptBookings: Bool
    let allowSmoking: Bool
    let allowPets: Bool
    let maxTwoInBack: Bool
    let luggageSize: String?
    let driver: Driver
    let vehicle: Vehicle?
    let remainingSeats: Int
    let waypoints: [Waypoint]?
    let bookedSeats: Int?
    
    var formattedPrice: String {
        "\(Int(pricePerSeat)) \(currency)"
    }
    
    var formattedDepartureTime: String {
        departureTime.formatted(date: .abbreviated, time: .shortened)
    }
    
    var isAvailable: Bool {
        status == .scheduled && remainingSeats > 0
    }
    
    var totalPrice: Double {
        pricePerSeat * Double(availableSeats)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, currency, description, status, driver, vehicle, waypoints
        case driverId = "driver_id"
        case vehicleId = "vehicle_id"
        case departureLocation = "departure_location"
        case departureLat = "departure_lat"
        case departureLng = "departure_lng"
        case arrivalLocation = "arrival_location"
        case arrivalLat = "arrival_lat"
        case arrivalLng = "arrival_lng"
        case departureTime = "departure_time"
        case arrivalTime = "arrival_time"
        case availableSeats = "available_seats"
        case pricePerSeat = "price_per_seat"
        case autoAcceptBookings = "auto_accept_bookings"
        case allowSmoking = "allow_smoking"
        case allowPets = "allow_pets"
        case maxTwoInBack = "max_two_in_back"
        case luggageSize = "luggage_size"
        case remainingSeats = "remaining_seats"
        case bookedSeats = "booked_seats"
    }
}
