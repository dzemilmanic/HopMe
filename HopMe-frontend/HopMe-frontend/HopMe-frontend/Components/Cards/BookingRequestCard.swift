import SwiftUI
	
struct BookingRequestCard: View {
    let booking: Booking
    let onAccept: (String?) -> Void
    let onReject: (String?) -> Void
    
    @State private var showAcceptDialog = false
    @State private var showRejectDialog = false
    @State private var response = ""
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Passenger Avatar (placeholder)
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("P")
                            .font(.title3)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Passenger ID: \(booking.passengerId)")
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.caption)
                        Text("\(booking.seatsBooked) place\(booking.seatsBooked > 1 ? "s" : "")")
                            .font(.caption)
                        
                        Text("•")
                            .foregroundColor(.gray)
                        
                        Text(booking.totalPrice.toCurrency())
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                StatusBadge(
                    status: booking.status.displayName,
                    color: Color(booking.status.color)
                )
            }
            
            if let message = booking.message, !message.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Message:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(message)
                        .font(.subheadline)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            
            if let pickup = booking.pickupLocation {
                HStack {
                    Image(systemName: "mappin.circle")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text(pickup)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let dropoff = booking.dropoffLocation {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(dropoff)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Action Buttons (only for pending bookings)
            if booking.status == .pending {
                HStack(spacing: 12) {
                    Button(action: { showRejectDialog = true }) {
                        Text("Reject")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { showAcceptDialog = true }) {
                        Text("Accept")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .alert("Accept booking", isPresented: $showAcceptDialog) {
            TextField("Message (optional)", text: $response)
            Button("Cancel", role: .cancel) {
                response = ""
            }
            Button("Accept") {
                onAccept(response.isEmpty ? nil : response)
                response = ""
            }
        } message: {
            Text("You can send a message to the passenger")
        }
        .alert("Reject booking", isPresented: $showRejectDialog) {
            TextField("Reason (optional)", text: $response)
            Button("Cancel", role: .cancel) {
                response = ""
            }
            Button("Reject", role: .destructive) {
                onReject(response.isEmpty ? nil : response)
                response = ""
            }
        } message: {
            Text("You can explain the reason for rejection")
        }
    }
}
