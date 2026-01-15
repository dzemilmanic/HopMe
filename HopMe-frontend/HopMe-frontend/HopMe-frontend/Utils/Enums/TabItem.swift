enum TabItem: String, CaseIterable {
    case home = "Home"
    case rides = "Rides"
    case bookings = "Bookings"
    case notifications = "Notifications"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .rides: return "car.fill"
        case .bookings: return "list.bullet"
        case .notifications: return "bell.fill"
        case .profile: return "person.fill"
        }
    }
    
    var index: Int {
        TabItem.allCases.firstIndex(of: self) ?? 0
    }
}
