struct UserProfile: Codable {
    let user: User
    let vehicles: [Vehicle]?
    let stats: UserStats?
}

struct UserStats: Codable {
    let totalRides: Int
    let averageRating: Double
    let totalRatings: Int
    let totalEarnings: Double?
    
    enum CodingKeys: String, CodingKey {
        case totalRides = "total_rides"
        case averageRating = "average_rating"
        case totalRatings = "total_ratings"
        case totalEarnings = "total_earnings"
    }
}
