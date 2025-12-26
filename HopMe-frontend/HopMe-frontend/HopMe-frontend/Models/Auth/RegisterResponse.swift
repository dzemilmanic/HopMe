import Foundation

struct RegisterResponse: Codable {
    let message: String
    let userId: Int?
    let vehicleId: Int?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        // Try both camelCase and snake_case for userId
        userId = try container.decodeIfPresent(Int.self, forKey: .userId) ?? 
                 try container.decodeIfPresent(Int.self, forKey: .userIdSnake)
        vehicleId = try container.decodeIfPresent(Int.self, forKey: .vehicleId) ??
                    try container.decodeIfPresent(Int.self, forKey: .vehicleIdSnake)
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case userId
        case userIdSnake = "user_id"
        case vehicleId
        case vehicleIdSnake = "vehicle_id"
    }
}
