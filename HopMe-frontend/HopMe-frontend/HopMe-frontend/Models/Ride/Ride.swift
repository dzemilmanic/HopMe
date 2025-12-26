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
        case driverId, vehicleId, departureLocation, departureLat, departureLng
        case arrivalLocation, arrivalLat, arrivalLng, departureTime, arrivalTime
        case availableSeats, pricePerSeat, autoAcceptBookings, allowSmoking
        case allowPets, maxTwoInBack, luggageSize, remainingSeats, bookedSeats
        
        // snake_case alternatives
        case driverIdSnake = "driver_id"
        case vehicleIdSnake = "vehicle_id"
        case departureLocationSnake = "departure_location"
        case departureLatSnake = "departure_lat"
        case departureLngSnake = "departure_lng"
        case arrivalLocationSnake = "arrival_location"
        case arrivalLatSnake = "arrival_lat"
        case arrivalLngSnake = "arrival_lng"
        case departureTimeSnake = "departure_time"
        case arrivalTimeSnake = "arrival_time"
        case availableSeatsSnake = "available_seats"
        case pricePerSeatSnake = "price_per_seat"
        case autoAcceptBookingsSnake = "auto_accept_bookings"
        case allowSmokingSnake = "allow_smoking"
        case allowPetsSnake = "allow_pets"
        case maxTwoInBackSnake = "max_two_in_back"
        case luggageSizeSnake = "luggage_size"
        case remainingSeatsSnake = "remaining_seats"
        case bookedSeatsSnake = "booked_seats"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        currency = try container.decode(String.self, forKey: .currency)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        status = try container.decode(RideStatus.self, forKey: .status)
        driver = try container.decode(Driver.self, forKey: .driver)
        vehicle = try container.decodeIfPresent(Vehicle.self, forKey: .vehicle)
        waypoints = try container.decodeIfPresent([Waypoint].self, forKey: .waypoints)
        
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
        
        driverId = try decode(Int.self, camel: .driverId, snake: .driverIdSnake)
        vehicleId = try decodeIfPresent(Int.self, camel: .vehicleId, snake: .vehicleIdSnake)
        departureLocation = try decode(String.self, camel: .departureLocation, snake: .departureLocationSnake)
        departureLat = try decodeIfPresent(Double.self, camel: .departureLat, snake: .departureLatSnake)
        departureLng = try decodeIfPresent(Double.self, camel: .departureLng, snake: .departureLngSnake)
        arrivalLocation = try decode(String.self, camel: .arrivalLocation, snake: .arrivalLocationSnake)
        arrivalLat = try decodeIfPresent(Double.self, camel: .arrivalLat, snake: .arrivalLatSnake)
        arrivalLng = try decodeIfPresent(Double.self, camel: .arrivalLng, snake: .arrivalLngSnake)
        departureTime = try decode(Date.self, camel: .departureTime, snake: .departureTimeSnake)
        arrivalTime = try decodeIfPresent(Date.self, camel: .arrivalTime, snake: .arrivalTimeSnake)
        availableSeats = try decode(Int.self, camel: .availableSeats, snake: .availableSeatsSnake)
        
        // Handle Price Per Seat which can be Double or String
        if let priceDouble = try? container.decodeIfPresent(Double.self, forKey: .pricePerSeat) {
            pricePerSeat = priceDouble
        } else if let priceDouble = try? container.decodeIfPresent(Double.self, forKey: .pricePerSeatSnake) {
            pricePerSeat = priceDouble
        } else if let priceString = try? container.decodeIfPresent(String.self, forKey: .pricePerSeat) {
            pricePerSeat = Double(priceString) ?? 0.0
        } else if let priceString = try? container.decodeIfPresent(String.self, forKey: .pricePerSeatSnake) {
            pricePerSeat = Double(priceString) ?? 0.0
        } else {
            pricePerSeat = 0.0
        }
        
        autoAcceptBookings = try decodeIfPresent(Bool.self, camel: .autoAcceptBookings, snake: .autoAcceptBookingsSnake) ?? false
        allowSmoking = try decodeIfPresent(Bool.self, camel: .allowSmoking, snake: .allowSmokingSnake) ?? false
        allowPets = try decodeIfPresent(Bool.self, camel: .allowPets, snake: .allowPetsSnake) ?? false
        maxTwoInBack = try decodeIfPresent(Bool.self, camel: .maxTwoInBack, snake: .maxTwoInBackSnake) ?? false
        luggageSize = try decodeIfPresent(String.self, camel: .luggageSize, snake: .luggageSizeSnake)
        
        // Remaining seats handling: try to decode from remainingSeats, otherwise calc from available - booked
        if let remaining = try? decodeIfPresent(Int.self, camel: .remainingSeats, snake: .remainingSeatsSnake) {
            remainingSeats = remaining
        } else if let booked = try? decodeIfPresent(Int.self, camel: .bookedSeats, snake: .bookedSeatsSnake) {
            remainingSeats = availableSeats - booked
        } else {
             // Fallback if remainingSeats is returned as string from some older endpoints
             if let remainingString = try? container.decodeIfPresent(String.self, forKey: .remainingSeats), let val = Int(remainingString) {
                 remainingSeats = val
             } else {
                 remainingSeats = availableSeats // Fallback
             }
        }
        
        if let booked = try? decodeIfPresent(Int.self, camel: .bookedSeats, snake: .bookedSeatsSnake) {
            bookedSeats = booked
        } else if let bookedString = try? container.decodeIfPresent(String.self, forKey: .bookedSeats) {
            bookedSeats = Int(bookedString)
        } else {
            bookedSeats = 0
        }
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(driverId, forKey: .driverIdSnake)
        try container.encodeIfPresent(vehicleId, forKey: .vehicleIdSnake)
        try container.encode(departureLocation, forKey: .departureLocationSnake)
        try container.encodeIfPresent(departureLat, forKey: .departureLatSnake)
        try container.encodeIfPresent(departureLng, forKey: .departureLngSnake)
        try container.encode(arrivalLocation, forKey: .arrivalLocationSnake)
        try container.encodeIfPresent(arrivalLat, forKey: .arrivalLatSnake)
        try container.encodeIfPresent(arrivalLng, forKey: .arrivalLngSnake)
        try container.encode(departureTime, forKey: .departureTimeSnake)
        try container.encodeIfPresent(arrivalTime, forKey: .arrivalTimeSnake)
        try container.encode(availableSeats, forKey: .availableSeatsSnake)
        try container.encode(pricePerSeat, forKey: .pricePerSeatSnake)
        try container.encode(currency, forKey: .currency)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(status, forKey: .status)
        try container.encode(autoAcceptBookings, forKey: .autoAcceptBookingsSnake)
        try container.encode(allowSmoking, forKey: .allowSmokingSnake)
        try container.encode(allowPets, forKey: .allowPetsSnake)
        try container.encode(maxTwoInBack, forKey: .maxTwoInBackSnake)
        try container.encodeIfPresent(luggageSize, forKey: .luggageSizeSnake)
        try container.encode(driver, forKey: .driver)
        try container.encodeIfPresent(vehicle, forKey: .vehicle)
        try container.encodeIfPresent(waypoints, forKey: .waypoints)
        try container.encodeIfPresent(remainingSeats, forKey: .remainingSeatsSnake)
        try container.encodeIfPresent(bookedSeats, forKey: .bookedSeatsSnake)
    }
}
