struct BookingRequest: Codable {
    let rideId: Int
    let seatsBooked: Int
    let pickupLocation: String?
    let dropoffLocation: String?
    let message: String?
}
