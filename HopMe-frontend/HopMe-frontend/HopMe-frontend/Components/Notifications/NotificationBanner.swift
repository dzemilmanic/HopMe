import SwiftUI

struct NotificationBanner: View {
    let notification: NotificationModel
    let onTap: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(notification.type.color).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: notification.type.icon)
                    .foregroundColor(Color(notification.type.color))
                    .font(.body)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Close Button
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .onTapGesture(perform: onTap)
    }
}
#Preview("Notification Banner") {
    VStack {
        Spacer()
        
        // Mock notification banner
        NotificationBanner(
            notification: NotificationModel(
                id: 1,
                userId: 1,
                type: .bookingAccepted,
                title: "Rezervacija prihvaćena",
                message: "Vaša rezervacija za vožnju Beograd → Niš je prihvaćena",
                data: nil,
                isRead: false,
                createdAt: Date()
            ),
            onTap: {},
            onDismiss: {}
        )
        .padding(.bottom, 50)
    }
    .background(Color.gray.opacity(0.3))
}
