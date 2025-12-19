import Foundation

class NotificationService {
    static let shared = NotificationService()
    private init() {}
    
    private let api = APIService.shared
    
    func getNotifications() async throws -> [NotificationModel] {
        return try await api.request(
            endpoint: .notifications,
            requiresAuth: true
        )
    }
    
    func getUnreadCount() async throws -> Int {
        let response: UnreadCountResponse = try await api.request(
            endpoint: .unreadCount,
            requiresAuth: true
        )
        return response.count
    }
    
    func markAsRead(id: Int) async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .markAsRead(id: id),
            method: .post,
            requiresAuth: true
        )
    }
    
    func markAllAsRead() async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .markAllAsRead,
            method: .post,
            requiresAuth: true
        )
    }
    
    func deleteNotification(id: Int) async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .deleteNotification(id: id),
            method: .delete,
            requiresAuth: true
        )
    }
}

struct UnreadCountResponse: Codable {
    let count: Int
}
