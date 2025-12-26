import Foundation

enum Environment {
    case development
    case staging
    case production
    
    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://hopme-backend.up.railway.app/api"
        case .staging:
            return "https://staging-api.hopme.rs/api"
        case .production:
            return "https://hopme-backend.up.railway.app/api"
        }
    }
    
    var websocketURL: String {
        switch self {
        case .development:
            return "ws://localhost:3000"
        case .staging:
            return "wss://staging-api.hopme.rs"
        case .production:
            return "wss://api.hopme.rs"
        }
    }
    
    var name: String {
        switch self {
        case .development: return "Development"
        case .staging: return "Staging"
        case .production: return "Production"
        }
    }
}
