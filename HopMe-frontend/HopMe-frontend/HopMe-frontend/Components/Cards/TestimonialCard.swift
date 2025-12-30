import SwiftUI

struct TestimonialCard: View {
    let testimonial: Testimonial
    var onDelete: (() -> Void)? = nil
    
    // Check if current user is admin (this would normally come from AuthViewModel)
    // For now assuming we pass onDelete closure only if user has permission
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RatingStars(rating: Double(testimonial.rating))
            
            Text(testimonial.text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(3)
                .frame(height: 60, alignment: .topLeading)
            
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(testimonial.userName.prefix(1)))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(testimonial.userName)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    if !testimonial.formattedDate.isEmpty {
                        Text(testimonial.formattedDate)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .frame(width: 250)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
