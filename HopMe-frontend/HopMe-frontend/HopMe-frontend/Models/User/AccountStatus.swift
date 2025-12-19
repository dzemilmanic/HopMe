enum AccountStatus: String, Codable {
    case pending
    case approved
    case rejected
    case suspended
    
    var displayName: String {
        switch self {
        case .pending: return "Na čekanju"
        case .approved: return "Odobren"
        case .rejected: return "Odbijen"
        case .suspended: return "Suspendovan"
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
