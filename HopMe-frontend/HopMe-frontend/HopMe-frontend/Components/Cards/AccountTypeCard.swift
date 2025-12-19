import SwiftUI

struct AccountTypeCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    )
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? .blue.opacity(0.2) : .black.opacity(0.05), radius: isSelected ? 8 : 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("Account Type Card - Selected") {
    VStack(spacing: 16) {
        AccountTypeCard(
            icon: "person.fill",
            title: "Putnik",
            description: "Pronađite vožnje i putujte jeftinije",
            isSelected: true,
            action: {}
        )
        
        AccountTypeCard(
            icon: "car.fill",
            title: "Vozač",
            description: "Delite vožnje i zaradite novac",
            isSelected: false,
            action: {}
        )
    }
    .padding()
}
