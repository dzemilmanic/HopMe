enum TabItem: String, CaseIterable {
    case home = "Početna"
    case rides = "Vožnje"
    case bookings = "Rezervacije"
    case notifications = "Poruke"
    case profile = "Profil"
    
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
