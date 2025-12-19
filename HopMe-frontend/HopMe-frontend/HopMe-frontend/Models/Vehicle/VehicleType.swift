enum VehicleType: String, CaseIterable {
    case sedan = "Sedan"
    case suv = "SUV"
    case hatchback = "Hečbek"
    case wagon = "Karavan"
    case van = "Kombi"
    case minivan = "Minivan"
    
    var icon: String {
        switch self {
        case .sedan: return "car.fill"
        case .suv: return "car.fill"
        case .hatchback: return "car.fill"
        case .wagon: return "car.fill"
        case .van: return "car.2.fill"
        case .minivan: return "car.2.fill"
        }
    }
}
