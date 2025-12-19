import SwiftUI

struct RatingStats: Codable {
    let totalRatings: Int
    let averageRating: Double
    let fiveStar: Int
    let fourStar: Int
    let threeStar: Int
    let twoStar: Int
    let oneStar: Int
    
    var formattedAverage: String {
        String(format: "%.1f", averageRating)
    }
    
    func percentage(for stars: Int) -> Double {
        guard totalRatings > 0 else { return 0 }
        let count: Int
        switch stars {
        case 5: count = fiveStar
        case 4: count = fourStar
        case 3: count = threeStar
        case 2: count = twoStar
        case 1: count = oneStar
        default: return 0
        }
        return Double(count) / Double(totalRatings)
    }
    
    enum CodingKeys: String, CodingKey {
        case totalRatings = "total_ratings"
        case averageRating = "average_rating"
        case fiveStar = "five_star"
        case fourStar = "four_star"
        case threeStar = "three_star"
        case twoStar = "two_star"
        case oneStar = "one_star"
    }
}
