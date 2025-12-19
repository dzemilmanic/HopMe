enum UserRole: String, Codable, CaseIterable {
    case passenger = "putnik"
    case driver = "vozac"
    case admin = "admin"
    
    var displayName: String {
        switch self {
        case .passenger: return "Putnik"
        case .driver: return "Vozač"
        case .admin: return "Admin"
        }
    }
    
    var icon: String {
        switch self {
        case .passenger: return "person.fill"
        case .driver: return "car.fill"
        case .admin: return "crown.fill"
        }
    }
    
    var color: String {
        switch self {
        case .passenger: return "green"
        case .driver: return "blue"
        case .admin: return "purple"
        }
    }
}
