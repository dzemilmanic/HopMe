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
                Text("Upcoming (\(viewModel.upcomingBookings.count))").tag(0)
                Text("Past (\(viewModel.pastBookings.count))").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            if viewModel.isLoading {
                LoadingView(message: "Loading bookings...")
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
        .navigationTitle("My bookings")
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
                    actionTitle: selectedSegment == 0 ? "Find a ride" : nil,
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
        selectedSegment == 0 ? "You have no upcoming bookings" : "You have no past bookings"
    }
    
    private var emptyDescription: String {
        selectedSegment == 0 ? "Search for rides and book a seat" : "Past bookings will appear here"
    }
}
#Preview("My Bookings View") {
    NavigationView {
        MyBookingsView()
    }
}
