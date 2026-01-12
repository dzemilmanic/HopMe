import Foundation

struct MyRatingsResponse: Codable {
    let receivedRatings: [Rating]
    let givenRatings: [Rating]
    let stats: MyRatingsStats
    
    enum CodingKeys: String, CodingKey {
        case receivedRatings, givenRatings, stats
    }
}

struct MyRatingsStats: Codable {
    let totalReceived: Int
    let averageReceived: Double
    let totalGiven: Int
    
    enum CodingKeys: String, CodingKey {
        case totalReceived = "total_received"
        case averageReceived = "average_received"
        case totalGiven = "total_given"
    }
}
