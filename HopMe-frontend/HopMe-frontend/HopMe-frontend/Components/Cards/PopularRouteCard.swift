import SwiftUI
	
struct PopularRouteCard: View {
    let from: String
    let to: String
    let price: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(from)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(to)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("for \(price) RSD")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(width: 200)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
