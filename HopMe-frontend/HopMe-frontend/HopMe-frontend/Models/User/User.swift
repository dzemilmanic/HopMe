import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let phone: String
    let profileImageUrl: String?
    let roles: [UserRole]
    let accountStatus: AccountStatus
    let isEmailVerified: Bool
    let createdAt: Date?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        return "\(first)\(last)".uppercased()
    }
    
    var isDriver: Bool {
        roles.contains(.driver)
    }
    
    var isPassenger: Bool {
        roles.contains(.passenger)
    }
    
    var isAdmin: Bool {
        roles.contains(.admin)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, phone, roles
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImageUrl = "profile_image_url"
        case accountStatus = "account_status"
        case isEmailVerified = "is_email_verified"
        case createdAt = "created_at"
    }
}
