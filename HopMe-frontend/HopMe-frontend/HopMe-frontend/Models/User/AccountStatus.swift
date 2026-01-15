enum AccountStatus: String, Codable {
    case pending
    case approved
    case rejected
    case suspended
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .suspended: return "Suspended"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .approved: return "green"
        case .rejected: return "red"
        case .suspended: return "gray"
        }
    }
}
