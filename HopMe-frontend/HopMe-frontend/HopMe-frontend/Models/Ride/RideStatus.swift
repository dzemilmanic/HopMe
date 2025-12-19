enum RideStatus: String, Codable {
    case scheduled
    case inProgress = "in_progress"
    case completed
    case cancelled
    
    var displayName: String {
        switch self {
        case .scheduled: return "Planirana"
        case .inProgress: return "U toku"
        case .completed: return "Završena"
        case .cancelled: return "Otkazana"
        }
    }
    
    var color: String {
        switch self {
        case .scheduled: return "green"
        case .inProgress: return "orange"
        case .completed: return "blue"
        case .cancelled: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .scheduled: return "calendar"
        case .inProgress: return "car.fill"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
}
