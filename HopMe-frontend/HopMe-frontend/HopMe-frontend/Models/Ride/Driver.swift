import SwiftUI

struct Driver: Codable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let profileImage: String?
    let averageRating: Double
    let totalRatings: Int
    let totalRides: Int?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        return "\(first)\(last)".uppercased()
    }
    
    var formattedRating: String {
        String(format: "%.1f", averageRating)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "firstName"
        case lastName = "lastName"
        case profileImage = "profileImage"
        case averageRating = "averageRating"
        case totalRatings = "totalRatings"
        case totalRides = "totalRides"
    }
}
