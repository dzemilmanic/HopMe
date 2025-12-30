import Foundation

struct Testimonial: Codable, Identifiable {
    let id: Int
    let userId: Int
    let rating: Int
    let text: String
    let isApproved: Bool
    let createdAt: String? // Backend šalje string timestamp - made optional
    let updatedAt: String? // Možda backend šalje i updated_at
    let firstName: String?
    let lastName: String?
    let userProfileImage: String?
    
    // Za prikaz
    var userName: String {
        if let first = firstName, let last = lastName {
            return "\(first) \(last.prefix(1))."
        }
        return "Korisnik"
    }
    
    var formattedDate: String {
        guard let createdAt = createdAt else { return "" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .none
            displayFormatter.locale = Locale(identifier: "sr_Latn_RS")
            return displayFormatter.string(from: date)
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId // Backend vraća camelCase zbog responseTransformer middleware
        case rating
        case text
        case isApproved
        case createdAt
        case updatedAt
        case firstName
        case lastName
        case userProfileImage = "profileImageUrl" // Backend vraća kao profileImageUrl
    }
}

struct TestimonialResponse: Codable {
    let success: Bool
    let count: Int?
    let testimonials: [Testimonial]?
    let testimonial: Testimonial?
    let message: String?
}
