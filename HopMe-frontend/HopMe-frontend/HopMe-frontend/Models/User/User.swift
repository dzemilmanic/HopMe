import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let phone: String
    let profileImageUrl: String?
    let roles: [UserRole]
    let accountStatus: AccountStatus?
    let isEmailVerified: Bool?
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
        case firstName, lastName, profileImageUrl, accountStatus, isEmailVerified, createdAt
        // snake_case alternatives
        case firstNameSnake = "first_name"
        case lastNameSnake = "last_name"
        case profileImageUrlSnake = "profile_image_url"
        case accountStatusSnake = "account_status"
        case isEmailVerifiedSnake = "is_email_verified"
        case createdAtSnake = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decode(String.self, forKey: .phone)
        roles = try container.decode([UserRole].self, forKey: .roles)
        
        // Handle both camelCase and snake_case for firstName
        if let value = try container.decodeIfPresent(String.self, forKey: .firstName) {
            firstName = value
        } else {
            firstName = try container.decode(String.self, forKey: .firstNameSnake)
        }
        
        // Handle both camelCase and snake_case for lastName
        if let value = try container.decodeIfPresent(String.self, forKey: .lastName) {
            lastName = value
        } else {
            lastName = try container.decode(String.self, forKey: .lastNameSnake)
        }
        
        // Optional fields - try camelCase first, then snake_case
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl) ??
                          container.decodeIfPresent(String.self, forKey: .profileImageUrlSnake)
        
        accountStatus = try container.decodeIfPresent(AccountStatus.self, forKey: .accountStatus) ??
                        container.decodeIfPresent(AccountStatus.self, forKey: .accountStatusSnake)
        
        isEmailVerified = try container.decodeIfPresent(Bool.self, forKey: .isEmailVerified) ??
                          container.decodeIfPresent(Bool.self, forKey: .isEmailVerifiedSnake)
        
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ??
                    container.decodeIfPresent(Date.self, forKey: .createdAtSnake)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(roles, forKey: .roles)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encodeIfPresent(profileImageUrl, forKey: .profileImageUrl)
        try container.encodeIfPresent(accountStatus, forKey: .accountStatus)
        try container.encodeIfPresent(isEmailVerified, forKey: .isEmailVerified)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}

