struct RidePreferences: Codable {
    var allowSmoking: Bool
    var allowPets: Bool
    var maxTwoInBack: Bool
    var luggageSize: LuggageSize
    var autoAcceptBookings: Bool
    
    enum LuggageSize: String, Codable, CaseIterable {
        case small = "Mali"
        case medium = "Srednji"
        case large = "Veliki"
        
        var icon: String {
            switch self {
            case .small: return "briefcase"
            case .medium: return "suitcase"
            case .large: return "suitcase.cart"
            }
        }
    }
}
