enum BookingStatus: String, Codable {
    case pending
    case accepted
    case rejected
    case cancelled
    case completed
    case all
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .rejected: return "Rejected"
        case .cancelled: return "Cancelled"
        case .completed: return "Completed"
        case .all: return "All"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .accepted: return "green"
        case .rejected: return "red"
        case .cancelled: return "gray"
        case .completed: return "blue"
        case .all: return "blue"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .accepted: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .cancelled: return "xmark.octagon.fill"
        case .completed: return "flag.checkered"
        case .all: return ""
        }
    }
}
