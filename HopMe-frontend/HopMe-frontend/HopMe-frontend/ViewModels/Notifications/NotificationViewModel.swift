import Foundation
@MainActor
class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    @Published var unreadCount = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let notificationService = NotificationService.shared
    
    var unreadNotifications: [NotificationModel] {
        notifications.filter { !$0.isRead }
    }
    
    func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        
        do {
            notifications = try await notificationService.getNotifications()
            unreadCount = try await notificationService.getUnreadCount()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Greška pri učitavanju"
        }
        
        isLoading = false
    }
    
    func markAsRead(id: Int) async {
        do {
            try await notificationService.markAsRead(id: id)
            if let index = notifications.firstIndex(where: { $0.id == id }) {
                notifications[index] = NotificationModel(
                    id: notifications[index].id,
                    userId: notifications[index].userId,
                    type: notifications[index].type,
                    title: notifications[index].title,
                    message: notifications[index].message,
                    data: notifications[index].data,
                    isRead: true,
                    createdAt: notifications[index].createdAt
                )
            }
            unreadCount = max(0, unreadCount - 1)
        } catch {
            errorMessage = "Greška"
        }
    }
    
    func markAllAsRead() async {
        do {
            try await notificationService.markAllAsRead()
            notifications = notifications.map {
                NotificationModel(
                    id: $0.id,
                    userId: $0.userId,
                    type: $0.type,
                    title: $0.title,
                    message: $0.message,
                    data: $0.data,
                    isRead: true,
                    createdAt: $0.createdAt
                )
            }
            unreadCount = 0
        } catch {
            errorMessage = "Greška"
        }
    }
    
    func deleteNotification(id: Int) async {
        do {
            try await notificationService.deleteNotification(id: id)
            notifications.removeAll { $0.id == id }
        } catch {
            errorMessage = "Greška pri brisanju"
        }
    }
}
