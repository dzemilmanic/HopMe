import Foundation

extension Double {
    // MARK: - Currency Formatting
    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RSD"
        formatter.currencySymbol = "RSD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(Int(self)) RSD"
    }
    
    // MARK: - Decimal Formatting
    func formatted(decimals: Int = 2) -> String {
        String(format: "%.\(decimals)f", self)
    }
    
    // MARK: - Distance Formatting
    func toDistanceString() -> String {
        if self < 1 {
            return "\(Int(self * 1000))m"
        }
        return "\(self.formatted(decimals: 1))km"
    }
    
    // MARK: - Duration Formatting
    func toDuration() -> String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        }
        return "\(minutes)min"
    }
}
