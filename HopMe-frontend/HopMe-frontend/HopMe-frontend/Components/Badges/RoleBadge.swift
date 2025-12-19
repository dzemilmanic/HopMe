import SwiftUI

struct RoleBadge: View {
    let role: UserRole
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: role.icon)
                .font(.caption2)
            Text(role.displayName)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color(role.color).opacity(0.2))
        .foregroundColor(Color(role.color))
        .cornerRadius(12)
    }
}
