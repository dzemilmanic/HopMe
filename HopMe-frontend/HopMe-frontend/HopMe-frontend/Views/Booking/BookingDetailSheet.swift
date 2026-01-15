import SwiftUI

struct BookingDetailSheet: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: BookingDetailViewModel
    let onUpdate: () -> Void
    
    @State private var showCancelAlert = false
    @State private var showRating = false
    
    init(booking: Booking, onUpdate: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: BookingDetailViewModel(booking: booking))
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Card
                    statusCard
                    
                    // Trip Details
                    tripDetailsSection
                    
                    // Driver Info
                    driverInfoSection
                    
                    // Booking Details
                    bookingDetailsSection
                    
                    // Price Breakdown
                    priceSection
                    
                    // Actions
                    if viewModel.booking.canCancel {
                        cancelButton
                    }
                    
                    if viewModel.booking.canRate {
                        rateButton
                    }
                }
                .padding()
            }
            .navigationTitle("Booking details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Cancel booking", isPresented: $showCancelAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Confirm", role: .destructive) {
                    Task {
                        let success = await viewModel.cancelBooking()
                        if success {
                            onUpdate()
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to cancel this booking?")
            }
            .sheet(isPresented: $showRating) {
                RatingSheet(booking: viewModel.booking, onComplete: {
                    onUpdate()
                }, isDriverRatingPassenger: false)
            }
        }
    }
    
    // MARK: - Status Card
    private var statusCard: some View {
        VStack(spacing: 12) {
            // Status Badge
            HStack {
                StatusBadge(
                    status: viewModel.booking.status.displayName,
                    color: Color(viewModel.booking.status.color)
                )
                
                Spacer()
                
                if viewModel.booking.status == .pending {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Waiting for approval")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Trip Summary
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.booking.ride.departureLocation)
                        .font(.headline)
                    
                    Text(viewModel.booking.ride.departureTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.booking.ride.arrivalLocation)
                        .font(.headline)
                    
                    Text(viewModel.booking.ride.departureTime.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Trip Details Section
    private var tripDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trip details")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Date
                DetailRow(
                    icon: "calendar",
                    title: "Date",
                    value: viewModel.booking.ride.departureTime.formatted(date: .long, time: .omitted)
                )
                
                // Time
                DetailRow(
                    icon: "clock",
                    title: "Departure time",
                    value: viewModel.booking.ride.departureTime.formatted(date: .long, time: .shortened)
                )
                
                // Seats
                DetailRow(
                    icon: "person.fill",
                    title: "Number of seats",
                    value: "\(viewModel.booking.seatsBooked)"
                )
                
                // Pickup Location
                if let pickup = viewModel.booking.pickupLocation {
                    DetailRow(
                        icon: "mappin.circle",
                        title: "Pickup location",
                        value: pickup
                    )
                }
                
                // Dropoff Location
                if let dropoff = viewModel.booking.dropoffLocation {
                    DetailRow(
                        icon: "mappin.and.ellipse",
                        title: "Dropoff location",
                        value: dropoff
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Driver Info Section
    private var driverInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Driver")
                .font(.headline)
            
            HStack(spacing: 16) {
                // Driver Avatar
                if let profileImage = viewModel.booking.ride.driver.profileImage {
                    AsyncImage(url: URL(string: profileImage)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .overlay(
                                Text(String(viewModel.booking.ride.driver.firstName.prefix(1)))
                                    .font(.title)
                                    .foregroundColor(.blue)
                            )
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(String(viewModel.booking.ride.driver.firstName.prefix(1)))
                                .font(.title)
                                .foregroundColor(.blue)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.booking.ride.driver.fullName)
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text("\(viewModel.booking.ride.driver.averageRating, specifier: "%.1f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    if viewModel.booking.status == .accepted {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                                .font(.caption)
                            Text(viewModel.booking.ride.driver.phone)
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                if let vehicle = viewModel.booking.ride.vehicle {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(vehicle.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if let color = vehicle.color {
                            Text(color)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Booking Details Section
    private var bookingDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional information")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Booking Date
                DetailRow(
                    icon: "calendar.badge.clock",
                    title: "Booked at",
                    value: viewModel.booking.createdAt.formatted(date: .abbreviated, time: .shortened)
                )
                
                // Accepted Date
                if let acceptedAt = viewModel.booking.acceptedAt {
                    DetailRow(
                        icon: "checkmark.circle",
                        title: "Accepted at",
                        value: acceptedAt.formatted(date: .abbreviated, time: .shortened)
                    )
                }
                
                // Message
                if let message = viewModel.booking.message, !message.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "text.bubble")
                                .foregroundColor(.blue)
                            Text("Your message")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                
                // Driver Response
                if let response = viewModel.booking.driverResponse, !response.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "text.bubble.fill")
                                .foregroundColor(.green)
                            Text("Driver response")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Text(response)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Price Section
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text("\(viewModel.booking.seatsBooked) x \(Int(viewModel.booking.totalPrice / Double(viewModel.booking.seatsBooked))) RSD")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.booking.totalPrice)) RSD")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(viewModel.booking.formattedPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Cancel Button
    private var cancelButton: some View {
        Button(action: { showCancelAlert = true }) {
            Text("Cancel booking")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Rate Button
    private var rateButton: some View {
        Button(action: { showRating = true }) {
            HStack {
                Image(systemName: "star.fill")
                Text("Rate trip")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .cornerRadius(12)
        }
    }
}
