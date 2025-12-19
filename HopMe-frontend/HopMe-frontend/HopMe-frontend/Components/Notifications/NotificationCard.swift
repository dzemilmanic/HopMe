import SwiftUI

struct NotificationCard: View {
    let notification: NotificationModel
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: notification.type.icon)
                        .foregroundColor(iconColor)
                        .font(.title3)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.subheadline)
                            .fontWeight(notification.isRead ? .regular : .semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    Text(notification.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(notification.isRead ? Color(.systemBackground) : Color.blue.opacity(0.05))
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Obriši", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            if !notification.isRead {
                Button(action: {
                    // Mark as read
                    onTap()
                }) {
                    Label("Pročitano", systemImage: "envelope.open.fill")
                }
                .tint(.blue)
            }
        }
    }
    
    private var iconBackgroundColor: Color {
        Color(notification.type.color).opacity(0.2)
    }
    
    private var iconColor: Color {
        Color(notification.type.color)
    }
}
#Preview {
    NotificationCard(
        notification: NotificationModel(
            id: 1,
            userId: 1,
            type: .newBooking,
            title: "Nova rezervacija",
            message: "Imate novu rezervaciju",
            data: nil,
            isRead: false,
            createdAt: Date()
        ),
        onTap: {},
        onDelete: {}
    )
}
