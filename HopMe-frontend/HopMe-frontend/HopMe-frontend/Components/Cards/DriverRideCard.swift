import SwiftUI
	
struct DriverRideCard: View {
    let ride: Ride
    let onViewBookings: () -> Void
    let onStart: () -> Void
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    @State private var showCancelAlert = false
    @State private var showActions = false
    
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
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text(ride.arrivalLocation)
                            .font(.headline)
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
            
            // Status and Info
            HStack {
                StatusBadge(
                    status: ride.status.displayName,
                    color: Color(ride.status.color)
                )
                
                Spacer()
                
                HStack(spacing: 16) {
                    Label("\(ride.availableSeats - ride.remainingSeats)/\(ride.availableSeats)", systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(ride.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                // View Bookings
                Button(action: onViewBookings) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("Bookings")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                // Status-specific actions
                if ride.status == .scheduled {
                    Menu {
                        Button(action: onStart) {
                            Label("Start ride", systemImage: "play.fill")
                        }
                        
                        Button(role: .destructive, action: {
                            showCancelAlert = true
                        }) {
                            Label("Cancel ride", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                } else if ride.status == .inProgress {
                    Button(action: onComplete) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Finish")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .alert("Cancel ride", isPresented: $showCancelAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm", role: .destructive, action: onCancel)
        } message: {
            Text("Are you sure you want to cancel this ride? All passengers will be notified.")
        }
    }
}
