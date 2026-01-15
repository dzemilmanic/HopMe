import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
    
    var previewIcon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.stars.fill"
        case .system: return "iphone"
        }
    }
    
    var description: String {
        switch self {
        case .light: return "Always use light mode"
        case .dark: return "Always use dark mode"
        case .system: return "Follow system settings"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
