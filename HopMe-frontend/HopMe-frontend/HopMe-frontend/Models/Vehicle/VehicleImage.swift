struct VehicleImage: Codable, Identifiable {
    let id: Int
    let imageUrl: String
    let isPrimary: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "image_url"
        case isPrimary = "is_primary"
    }
}
