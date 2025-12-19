import SwiftUI
	
struct TestimonialCard: View {
    let name: String
    let text: String
    let rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RatingStars(rating: Double(rating), size: 14)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .frame(width: 250)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
