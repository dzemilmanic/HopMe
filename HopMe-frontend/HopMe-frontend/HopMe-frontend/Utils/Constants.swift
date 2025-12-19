import Foundation

struct Constants {
    // MARK: - App Info
    struct App {
        static let name = "HopMe"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - API
    struct API {
        static let timeout: TimeInterval = 30
        static let maxRetries = 3
    }
    
    // MARK: - UI
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let animationDuration: Double = 0.3
        static let maxImageSize: Int = 5 * 1024 * 1024 // 5MB
    }
    
    // MARK: - Maps
    struct Maps {
        static let defaultZoom: Double = 12.0
        static let defaultLatitude: Double = 44.7866 // Beograd
        static let defaultLongitude: Double = 20.4489
    }
    
    // MARK: - Validation
    struct Validation {
        static let minPasswordLength = 6
        static let maxPasswordLength = 50
        static let minPhoneLength = 9
        static let maxPhoneLength = 15
    }
    
    // MARK: - Limits
    struct Limits {
        static let maxSeats = 8
        static let maxVehicleImages = 5
        static let maxWaypoints = 5
        static let minPrice = 100.0
        static let maxPrice = 10000.0
    }
    
    // MARK: - Keys
    struct Keys {
        static let userDefaultsPrefix = "hopme_"
        static let hasSeenOnboarding = "\(userDefaultsPrefix)has_seen_onboarding"
        static let preferredLanguage = "\(userDefaultsPrefix)preferred_language"
    }
}
