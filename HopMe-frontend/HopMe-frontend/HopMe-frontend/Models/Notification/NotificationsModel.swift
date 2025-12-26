import Foundation

struct NotificationModel: Codable, Identifiable {
    let id: Int
    let userId: Int
    let type: NotificationType
    let title: String
    let message: String
    let data: [String: String]?
    let isRead: Bool
    let createdAt: Date
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    enum CodingKeys: String, CodingKey {
        case id, type, title, message, data
        case userId = "user_id"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
    
    // Helper for dynamic keys
    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int?
        init?(intValue: Int) { return nil }
    }

    // Manual memberwise initializer
    init(id: Int, userId: Int, type: NotificationType, title: String, message: String, data: [String: String]? = nil, isRead: Bool, createdAt: Date) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.message = message
        self.data = data
        self.isRead = isRead
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        type = try container.decode(NotificationType.self, forKey: .type)
        title = try container.decode(String.self, forKey: .title)
        message = try container.decode(String.self, forKey: .message)
        isRead = try container.decode(Bool.self, forKey: .isRead)
        
        // Handle Date decoding (supports ISO8601 string or numeric timestamp)
        if let dateString = try? container.decode(String.self, forKey: .createdAt) {
             let formatter = ISO8601DateFormatter()
             formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
             if let date = formatter.date(from: dateString) {
                 createdAt = date
             } else {
                 // Fallback for standard ISO8601
                  let standardFormatter = ISO8601DateFormatter()
                  createdAt = standardFormatter.date(from: dateString) ?? Date()
             }
        } else if let timestamp = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        } else {
            createdAt = Date()
        }
        
        // Custom data decoding to handle non-string values
        if let dataContainer = try? container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .data) {
            var decodedData = [String: String]()
            for key in dataContainer.allKeys {
                if let stringValue = try? dataContainer.decode(String.self, forKey: key) {
                    decodedData[key.stringValue] = stringValue
                } else if let intValue = try? dataContainer.decode(Int.self, forKey: key) {
                    decodedData[key.stringValue] = String(intValue)
                } else if let doubleValue = try? dataContainer.decode(Double.self, forKey: key) {
                    decodedData[key.stringValue] = String(doubleValue)
                } else if let boolValue = try? dataContainer.decode(Bool.self, forKey: key) {
                    decodedData[key.stringValue] = String(boolValue)
                }
            }
            data = decodedData
        } else {
            data = nil
        }
    }
}
