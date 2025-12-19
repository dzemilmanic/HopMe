import Foundation

struct Vehicle: Codable, Identifiable {
    let id: Int
    let userId: Int
    let vehicleType: String
    let brand: String?
    let model: String?
    let year: Int?
    let licensePlate: String?
    let color: String?
    let seats: Int
    let isActive: Bool
    let images: [VehicleImage]?
    
    var displayName: String {
        if let brand = brand, let model = model {
            return "\(brand) \(model)"
        }
        return vehicleType
    }
    
    var fullDescription: String {
        var parts: [String] = [displayName]
        if let year = year {
            parts.append(String(year))
        }
        if let color = color {
            parts.append(color)
        }
        return parts.joined(separator: " • ")
    }
    
    var primaryImage: VehicleImage? {
        images?.first { $0.isPrimary } ?? images?.first
    }
    
    enum CodingKeys: String, CodingKey {
        case id, brand, model, year, color, seats, images
        case userId = "user_id"
        case vehicleType = "vehicle_type"
        case licensePlate = "license_plate"
        case isActive = "is_active"
    }
}
