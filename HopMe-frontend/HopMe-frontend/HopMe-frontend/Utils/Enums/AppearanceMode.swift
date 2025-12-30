import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .light: return "Svetla"
        case .dark: return "Tamna"
        case .system: return "Automatski"
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
        case .light: return "Uvek koristi svetlu temu"
        case .dark: return "Uvek koristi tamnu temu"
        case .system: return "Prati sistemska podešavanja uređaja"
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
