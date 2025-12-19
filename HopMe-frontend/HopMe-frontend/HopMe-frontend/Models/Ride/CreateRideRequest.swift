struct CreateRideRequest: Codable {
    let vehicleId: Int
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
    let description: String?
    let autoAcceptBookings: Bool
    let allowSmoking: Bool
    let allowPets: Bool
    let maxTwoInBack: Bool
    let luggageSize: String?
    let waypoints: [WaypointRequest]?
    
    enum CodingKeys: String, CodingKey {
        case vehicleId, departureLocation, departureLat, departureLng
        case arrivalLocation, arrivalLat, arrivalLng
        case departureTime, arrivalTime, availableSeats, pricePerSeat
        case description, autoAcceptBookings, allowSmoking, allowPets
        case maxTwoInBack, luggageSize, waypoints
    }
}

struct WaypointRequest: Codable {
    let location: String
    let lat: Double?
    let lng: Double?
    let estimatedTime: Date?
}
