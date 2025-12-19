struct RatingRequest: Codable {
    let bookingId: Int
    let rideId: Int
    let rating: Int
    let comment: String?
}
