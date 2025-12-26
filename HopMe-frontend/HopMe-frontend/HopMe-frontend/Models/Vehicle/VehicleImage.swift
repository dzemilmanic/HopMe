struct VehicleImage: Codable, Identifiable {
    let id: Int
    let imageUrl: String
    let isPrimary: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl, isPrimary
        // snake_case alternatives
        case imageUrlSnake = "image_url"
        case isPrimarySnake = "is_primary"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        
        if let value = try container.decodeIfPresent(String.self, forKey: .imageUrl) {
            imageUrl = value
        } else {
            imageUrl = try container.decode(String.self, forKey: .imageUrlSnake)
        }
        
        if let value = try container.decodeIfPresent(Bool.self, forKey: .isPrimary) {
            isPrimary = value
        } else {
            isPrimary = try container.decodeIfPresent(Bool.self, forKey: .isPrimarySnake) ?? false
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(isPrimary, forKey: .isPrimary)
    }
}

