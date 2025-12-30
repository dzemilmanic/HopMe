import SwiftUI

struct MyBookingsView: View {
    @StateObject private var viewModel = MyBookingsViewModel()
    @State private var selectedSegment = 0
    @State private var selectedBooking: Booking?

    @State private var bookingToRate: Booking?
    
    var body: some View {
        VStack(spacing: 0) {
            // Segment Control
            Picker("", selection: $selectedSegment) {
                Text("Nadolazeće (\(viewModel.upcomingBookings.count))").tag(0)
                Text("Prošle (\(viewModel.pastBookings.count))").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            if viewModel.isLoading {
                LoadingView(message: "Učitavanje rezervacija...")
            } else if let error = viewModel.errorMessage {
                ErrorView(
                    message: error,
                    retryAction: {
                        Task {
                            await viewModel.loadBookings()
                        }
                    }
                )
            } else {
                bookingsListView
            }
        }
        .navigationTitle("Moje rezervacije")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedBooking) { booking in
            BookingDetailSheet(booking: booking) {
                Task {
                    await viewModel.refreshBookings()
                }
            }
        }
        .sheet(item: $bookingToRate) { booking in
            RatingSheet(booking: booking, onComplete: {
                Task {
                    await viewModel.refreshBookings()
                }
            }, isDriverRatingPassenger: false)
        }
        .task {
            await viewModel.loadBookings()
        }
        .refreshable {
            await viewModel.refreshBookings()
        }
    }
    
    // MARK: - Bookings List View
    private var bookingsListView: some View {
        ScrollView {
            let bookings = selectedSegment == 0 ? viewModel.upcomingBookings : viewModel.pastBookings
            
            if bookings.isEmpty {
                EmptyStateView(
                    icon: "list.bullet",
                    title: emptyTitle,
                    description: emptyDescription,
                    actionTitle: selectedSegment == 0 ? "Pronađi vožnju" : nil,
                    action: selectedSegment == 0 ? {
                        // TODO: Navigate to search
                    } : nil
                )
                .frame(height: 400)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(bookings) { booking in
                        PassengerBookingCard(
                            booking: booking,
                            onTap: {
                                selectedBooking = booking
                            },
                            onRate: {
                                bookingToRate = booking
                            },
                            onCancel: {
                                Task {
                                    await viewModel.cancelBooking(id: booking.id)
                                }
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    private var emptyTitle: String {
        selectedSegment == 0 ? "Nemate nadolazećih rezervacija" : "Nemate prošlih rezervacija"
    }
    
    private var emptyDescription: String {
        selectedSegment == 0 ? "Pretražite vožnje i rezervišite mesto" : "Završene rezervacije će se pojaviti ovde"
    }
}
#Preview("My Bookings View") {
    NavigationView {
        MyBookingsView()
    }
}
