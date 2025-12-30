import SwiftUI

struct RideBookingsListView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    let ride: Ride
    @StateObject private var viewModel: RideBookingsViewModel
    @State private var bookingToRate: Booking?
    
    init(ride: Ride) {
        self.ride = ride
        _viewModel = StateObject(wrappedValue: RideBookingsViewModel(rideId: ride.id))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Ride Summary Header
                rideSummaryHeader
                
                Divider()
                
                // Tabs for different booking statuses
                Picker("Status", selection: $viewModel.selectedStatus) {
                    Text("Na čekanju (\(viewModel.pendingCount))").tag(BookingStatus.pending)
                    Text("Prihvaćene (\(viewModel.acceptedCount))").tag(BookingStatus.accepted)
                    Text("Sve (\(viewModel.allBookingsCount))").tag(BookingStatus.all)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                if viewModel.isLoading {
                    LoadingView(message: "Učitavam rezervacije...")
                } else if let error = viewModel.errorMessage {
                    ErrorView(
                        message: error,
                        retryAction: {
                            Task {
                                await viewModel.loadBookings()
                            }
                        }
                    )
                } else if viewModel.filteredBookings.isEmpty {
                    EmptyStateView(
                        icon: "person.crop.circle.badge.xmark",
                        title: "Nema rezervacija",
                        description: emptyDescription
                    )
                } else {
                    bookingsList
                }
            }
            .navigationTitle("Rezervacije")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zatvori") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadBookings()
            }
            .refreshable {
                await viewModel.loadBookings()
            }
            .sheet(item: $bookingToRate) { booking in
                RatingSheet(booking: booking, onComplete: {
                    Task {
                        await viewModel.loadBookings()
                    }
                }, isDriverRatingPassenger: true)
            }
        }
    }
    
    // MARK: - Ride Summary Header
    private var rideSummaryHeader: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ride.departureLocation)
                        .font(.headline)
                    Text(ride.departureTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(ride.arrivalLocation)
                        .font(.headline)
                    if let arrivalTime = ride.arrivalTime {
                        Text(arrivalTime.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            HStack {
                Label("\(ride.remainingSeats) mesta", systemImage: "person.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(ride.formattedPrice)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // MARK: - Bookings List
    private var bookingsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredBookings) { booking in
                    BookingRowCard(
                        booking: booking,
                        onAccept: {
                            Task {
                                await viewModel.acceptBooking(id: booking.id, response: nil)  // ← Dodaj response: nil
                            }
                        },
                        onReject: {
                            Task {
                                await viewModel.rejectBooking(id: booking.id, response: nil)  // ← Dodaj response: nil
                            }
                        },
                        onRatePassenger: {
                            bookingToRate = booking
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    private var emptyDescription: String {
        switch viewModel.selectedStatus {
        case .pending:
            return "Trenutno nema rezervacija na čekanju"
        case .accepted:
            return "Trenutno nema prihvaćenih rezervacija"
        default:
            return "Još nema rezervacija za ovu vožnju"
        }
    }
}

// MARK: - Booking Row Card
struct BookingRowCard: View {
    let booking: Booking
    let onAccept: () -> Void
    let onReject: () -> Void
    let onRatePassenger: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Passenger Avatar
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(booking.passenger.firstName.prefix(1)))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.passenger.fullName)
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text(String(format: "%.1f", booking.passenger.averageRating))
                            .font(.subheadline)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(booking.seatsBooked) \(booking.seatsBooked == 1 ? "mesto" : "mesta")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(booking.formattedPrice)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            
            if let message = booking.message, !message.isEmpty {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            if booking.status == .pending {
                HStack(spacing: 12) {
                    Button(action: onReject) {
                        Text("Odbij")
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: onAccept) {
                        Text("Prihvati")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
            } else if booking.status == .completed {
                Button(action: onRatePassenger) {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Oceni putnika")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            } else {
                StatusBadge(
                    status: booking.status.displayName,
                    color: Color(booking.status.color)
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
