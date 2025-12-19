import Foundation

struct FormatterHelper {
    // MARK: - Date Formatters
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "sr_RS")
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    // MARK: - Number Formatters
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RSD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    // MARK: - Helper Methods
    static func formatPrice(_ price: Double) -> String {
        "\(Int(price)) RSD"
    }
    
    static func formatRating(_ rating: Double) -> String {
        String(format: "%.1f", rating)
    }
    
    static func formatDistance(_ meters: Int) -> String {
        if meters < 1000 {
            return "\(meters)m"
        }
        let km = Double(meters) / 1000.0
        return String(format: "%.1fkm", km)
    }
    
    static func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        }
        return "\(minutes)min"
    }
}
