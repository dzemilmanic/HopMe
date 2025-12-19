import SwiftUI

struct VehicleSmallCard: View {
    let vehicle: Vehicle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let primaryImage = vehicle.primaryImage {
                AsyncImage(url: URL(string: primaryImage.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 120, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Image(systemName: "car.fill")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if let color = vehicle.color {
                    Text(color)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
