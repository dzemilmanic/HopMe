import Foundation

struct RegisterResponse: Decodable {
    let message: String
    let userId: Int?
    let vehicleId: Int?

    enum CodingKeys: String, CodingKey {
        case message
        case userId
        case userIdSnake = "user_id"
        case vehicleId
        case vehicleIdSnake = "vehicle_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        message = try container.decode(String.self, forKey: .message)

        if let id = try container.decodeIfPresent(Int.self, forKey: .userId) {
            userId = id
        } else {
            userId = try container.decodeIfPresent(Int.self, forKey: .userIdSnake)
        }

        if let vId = try container.decodeIfPresent(Int.self, forKey: .vehicleId) {
            vehicleId = vId
        } else {
            vehicleId = try container.decodeIfPresent(Int.self, forKey: .vehicleIdSnake)
        }
    }
}
