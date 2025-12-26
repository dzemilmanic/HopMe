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
    let passenger: PassengerInfo
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
        case id, status, message, ride, passenger
        case rideId, passengerId, seatsBooked, totalPrice, pickupLocation
        case dropoffLocation, driverResponse, createdAt, acceptedAt, completedAt
        
        // snake_case alternatives
        case rideIdSnake = "ride_id"
        case passengerIdSnake = "passenger_id"
        case seatsBookedSnake = "seats_booked"
        case totalPriceSnake = "total_price"
        case pickupLocationSnake = "pickup_location"
        case dropoffLocationSnake = "dropoff_location"
        case driverResponseSnake = "driver_response"
        case createdAtSnake = "created_at"
        case acceptedAtSnake = "accepted_at"
        case completedAtSnake = "completed_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        status = try container.decode(BookingStatus.self, forKey: .status)
        ride = try container.decode(RideInfo.self, forKey: .ride)
        passenger = try container.decode(PassengerInfo.self, forKey: .passenger)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        
        // Helper for dual format decoding
        func decode<T: Decodable>(_ type: T.Type, camel: CodingKeys, snake: CodingKeys) throws -> T {
            if let value = try container.decodeIfPresent(T.self, forKey: camel) {
                return value
            }
            return try container.decode(T.self, forKey: snake)
        }
        
        func decodeIfPresent<T: Decodable>(_ type: T.Type, camel: CodingKeys, snake: CodingKeys) throws -> T? {
            if let value = try container.decodeIfPresent(T.self, forKey: camel) {
                return value
            }
            return try container.decodeIfPresent(T.self, forKey: snake)
        }
        
        rideId = try decode(Int.self, camel: .rideId, snake: .rideIdSnake)
        passengerId = try decode(Int.self, camel: .passengerId, snake: .passengerIdSnake)
        seatsBooked = try decode(Int.self, camel: .seatsBooked, snake: .seatsBookedSnake)
        
        // Handle Price which can be Double or String
        if let priceDouble = try? container.decodeIfPresent(Double.self, forKey: .totalPrice) {
            totalPrice = priceDouble
        } else if let priceDouble = try? container.decodeIfPresent(Double.self, forKey: .totalPriceSnake) {
            totalPrice = priceDouble
        } else if let priceString = try? container.decodeIfPresent(String.self, forKey: .totalPrice) {
            totalPrice = Double(priceString) ?? 0.0
        } else if let priceString = try? container.decodeIfPresent(String.self, forKey: .totalPriceSnake) {
            totalPrice = Double(priceString) ?? 0.0
        } else {
            totalPrice = 0.0
        }
        
        pickupLocation = try decodeIfPresent(String.self, camel: .pickupLocation, snake: .pickupLocationSnake)
        dropoffLocation = try decodeIfPresent(String.self, camel: .dropoffLocation, snake: .dropoffLocationSnake)
        driverResponse = try decodeIfPresent(String.self, camel: .driverResponse, snake: .driverResponseSnake)
        createdAt = try decode(Date.self, camel: .createdAt, snake: .createdAtSnake)
        acceptedAt = try decodeIfPresent(Date.self, camel: .acceptedAt, snake: .acceptedAtSnake)
        completedAt = try decodeIfPresent(Date.self, camel: .completedAt, snake: .completedAtSnake)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(rideId, forKey: .rideIdSnake)
        try container.encode(passengerId, forKey: .passengerIdSnake)
        try container.encode(seatsBooked, forKey: .seatsBookedSnake)
        try container.encode(totalPrice, forKey: .totalPriceSnake)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(pickupLocation, forKey: .pickupLocationSnake)
        try container.encodeIfPresent(dropoffLocation, forKey: .dropoffLocationSnake)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(driverResponse, forKey: .driverResponseSnake)
        try container.encode(passenger, forKey: .passenger)
        try container.encode(ride, forKey: .ride)
        try container.encode(createdAt, forKey: .createdAtSnake)
        try container.encodeIfPresent(acceptedAt, forKey: .acceptedAtSnake)
        try container.encodeIfPresent(completedAt, forKey: .completedAtSnake)
    }
}

struct PassengerInfo: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let phone: String
    let profileImage: String?
    let averageRating: Double
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
