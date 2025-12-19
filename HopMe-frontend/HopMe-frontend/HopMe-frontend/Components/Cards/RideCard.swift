import SwiftUI
		
struct RideCard: View {
    let ride: Ride
    
    var body: some View {
        VStack(spacing: 12) {
            // Route and Time
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text(ride.departureLocation)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text(ride.arrivalLocation)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(ride.departureTime.formatted(date: .omitted, time: .shortened))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(ride.departureTime.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            // Driver and Vehicle Info
            HStack(spacing: 12) {
                // Driver Avatar
                if let profileImage = ride.driver.profileImage {
                    AsyncImage(url: URL(string: profileImage)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .overlay(
                                Text(ride.driver.initials)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            )
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(ride.driver.initials)
                                .font(.caption)
                                .foregroundColor(.blue)
                        )
                }
                
                // Driver Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(ride.driver.fullName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        Text(ride.driver.formattedRating)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("(\(ride.driver.totalRatings))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Vehicle
                if let vehicle = ride.vehicle {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(vehicle.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        if let color = vehicle.color {
                            Text(color)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            Divider()
            
            // Price and Seats
            HStack {
                // Seats
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(ride.remainingSeats) mesta")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Preferences
                HStack(spacing: 8) {
                    if ride.autoAcceptBookings {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    if !ride.allowSmoking {
                        Image(systemName: "nosign")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    
                    if ride.allowPets {
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(.brown)
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                // Price
                Text(ride.formattedPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
