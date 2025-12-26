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
    let seats: Int?
    let isActive: Bool?
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
        case userId, vehicleType, licensePlate, isActive
        // snake_case alternatives
        case userIdSnake = "user_id"
        case vehicleTypeSnake = "vehicle_type"
        case licensePlateSnake = "license_plate"
        case isActiveSnake = "is_active"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        brand = try container.decodeIfPresent(String.self, forKey: .brand)
        model = try container.decodeIfPresent(String.self, forKey: .model)
        year = try container.decodeIfPresent(Int.self, forKey: .year)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        seats = try container.decodeIfPresent(Int.self, forKey: .seats)
        images = try container.decodeIfPresent([VehicleImage].self, forKey: .images)
        
        // Handle both camelCase and snake_case
        if let value = try container.decodeIfPresent(Int.self, forKey: .userId) {
            userId = value
        } else {
            userId = try container.decode(Int.self, forKey: .userIdSnake)
        }
        
        if let value = try container.decodeIfPresent(String.self, forKey: .vehicleType) {
            vehicleType = value
        } else {
            vehicleType = try container.decode(String.self, forKey: .vehicleTypeSnake)
        }
        
        licensePlate = try container.decodeIfPresent(String.self, forKey: .licensePlate) ??
                       container.decodeIfPresent(String.self, forKey: .licensePlateSnake)
        
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ??
                   container.decodeIfPresent(Bool.self, forKey: .isActiveSnake)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(vehicleType, forKey: .vehicleType)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encodeIfPresent(model, forKey: .model)
        try container.encodeIfPresent(year, forKey: .year)
        try container.encodeIfPresent(licensePlate, forKey: .licensePlate)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(seats, forKey: .seats)
        try container.encodeIfPresent(isActive, forKey: .isActive)
        try container.encodeIfPresent(images, forKey: .images)
    }
}

struct VehicleResponse: Codable {
    let vehicle: Vehicle
    let message: String?
}

