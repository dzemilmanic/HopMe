enum BookingStatus: String, Codable {
    case pending
    case accepted
    case rejected
    case cancelled
    case completed
    
    var displayName: String {
        switch self {
        case .pending: return "Na čekanju"
        case .accepted: return "Prihvaćeno"
        case .rejected: return "Odbijeno"
        case .cancelled: return "Otkazano"
        case .completed: return "Završeno"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .accepted: return "green"
        case .rejected: return "red"
        case .cancelled: return "gray"
        case .completed: return "blue"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .accepted: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .cancelled: return "xmark.octagon.fill"
        case .completed: return "flag.checkered"
        }
    }
}
