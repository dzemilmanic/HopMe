import SwiftUI

struct PassengerBookingCard: View {
    let booking: Booking
    let onTap: () -> Void
    let onRate: () -> Void
    let onCancel: () -> Void
    
    @State private var showCancelAlert = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Status and Date
                HStack {
                    StatusBadge(
                        status: booking.status.displayName,
                        color: Color(booking.status.color)
                    )
                    
                    Spacer()
                    
                    Text(booking.ride.departureTime.formattedDate())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Route
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text(booking.ride.departureLocation)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text(booking.ride.arrivalLocation)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    Text(booking.ride.departureTime.formattedTime())
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Divider()
                
                // Driver and Info
                HStack(spacing: 12) {
                    // Driver Avatar
                    if let profileImage = booking.ride.driver.profileImage {
                        AsyncImage(url: URL(string: profileImage)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .overlay(
                                    Text(String(booking.ride.driver.firstName.prefix(1)))
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
                                Text(String(booking.ride.driver.firstName.prefix(1)))
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(booking.ride.driver.fullName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text("\(booking.ride.driver.averageRating, specifier: "%.1f")")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(booking.formattedPrice)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("\(booking.seatsBooked) mesto\(booking.seatsBooked > 1 ? "a" : "")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Quick Actions
                if booking.canRate || booking.canCancel {
                    HStack(spacing: 12) {
                        if booking.canRate {
                            Button(action: onRate) {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("Oceni")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                            }
                        }
                        
                        if booking.canCancel {
                            Button(action: { showCancelAlert = true }) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("Otkaži")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Otkazivanje rezervacije", isPresented: $showCancelAlert) {
            Button("Otkaži", role: .cancel) { }
            Button("Potvrdi", role: .destructive, action: onCancel)
        } message: {
            Text("Da li ste sigurni da želite da otkažete ovu rezervaciju?")
        }
    }
}
