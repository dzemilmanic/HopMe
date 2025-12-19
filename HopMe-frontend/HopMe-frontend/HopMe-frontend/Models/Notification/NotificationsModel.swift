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
}
