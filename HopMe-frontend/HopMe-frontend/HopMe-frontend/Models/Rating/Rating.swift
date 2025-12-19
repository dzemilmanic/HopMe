import Foundation

struct Rating: Codable, Identifiable {
    let id: Int
    let bookingId: Int
    let rideId: Int
    let raterId: Int
    let ratedId: Int
    let rating: Int
    let comment: String?
    let rater: UserInfo
    let createdAt: Date
    
    var formattedDate: String {
        createdAt.formatted(date: .abbreviated, time: .omitted)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, rating, comment, rater
        case bookingId = "booking_id"
        case rideId = "ride_id"
        case raterId = "rater_id"
        case ratedId = "rated_id"
        case createdAt = "created_at"
    }
}
