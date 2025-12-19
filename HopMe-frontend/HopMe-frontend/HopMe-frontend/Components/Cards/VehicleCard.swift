import SwiftUI

struct VehicleCard: View {
    let vehicle: Vehicle
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Images
            if let images = vehicle.images, !images.isEmpty {
                TabView {
                    ForEach(images) { image in
                        AsyncImage(url: URL(string: image.imageUrl)) { img in
                            img
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                        }
                        .frame(height: 200)
                        .clipped()
                    }
                }
                .frame(height: 200)
                .tabViewStyle(.page)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        Image(systemName: "car.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vehicle.displayName)
                            .font(.headline)
                        
                        if let year = vehicle.year {
                            Text("\(year)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    if vehicle.isActive {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("Aktivno")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                if let color = vehicle.color {
                    HStack {
                        Image(systemName: "paintpalette.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(color)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                if let licensePlate = vehicle.licensePlate {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(licensePlate)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("\(vehicle.seats) sedišta")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Actions
            HStack(spacing: 12) {
                Button(action: {
                    // TODO: Edit vehicle
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Izmeni")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                Button(action: onDelete) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Obriši")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
