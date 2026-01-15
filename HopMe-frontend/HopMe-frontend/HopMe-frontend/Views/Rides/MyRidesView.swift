import SwiftUI

struct MyRidesView: View {
    @StateObject private var viewModel = DriverRidesViewModel()
    @State private var selectedSegment = 0
    @State private var showCreateRide = false
    @State private var showRideBookings = false
    @State private var selectedRide: Ride?
    
    var body: some View {
        VStack(spacing: 0) {
            // Segment Control
            Picker("", selection: $selectedSegment) {
                Text("Upcoming (\(viewModel.upcomingRides.count))").tag(0)
                Text("Active (\(viewModel.activeRides.count))").tag(1)
                Text("Past (\(viewModel.pastRides.count))").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            if viewModel.isLoading {
                LoadingView(message: "Loading rides...")
            } else if let error = viewModel.errorMessage {
                ErrorView(
                    message: error,
                    retryAction: {
                        Task {
                            await viewModel.loadMyRides()
                        }
                    }
                )
            } else {
                ridesListView
            }
        }
        .navigationTitle("My rides")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showCreateRide = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showCreateRide) {
            CreateRideView()
        }
        .sheet(item: $selectedRide) { ride in
            RideBookingsListView(ride: ride)
        }
        .task {
            await viewModel.loadMyRides()
        }
        .refreshable {
            await viewModel.loadMyRides()
        }
    }
    
    // MARK: - Rides List View
    private var ridesListView: some View {
        ScrollView {
            let rides = selectedSegment == 0 ? viewModel.upcomingRides :
                       selectedSegment == 1 ? viewModel.activeRides :
                       viewModel.pastRides
            
            if rides.isEmpty {
                EmptyStateView(
                    icon: "car.fill",
                    title: emptyTitle,
                    description: emptyDescription,
                    actionTitle: selectedSegment == 0 ? "Create ride" : nil,
                    action: selectedSegment == 0 ? { showCreateRide = true } : nil
                )
                .frame(height: 400)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(rides) { ride in
                        DriverRideCard(
                            ride: ride,
                            onViewBookings: {
                                selectedRide = ride
                            },
                            onStart: {
                                Task {
                                    await viewModel.startRide(id: ride.id)
                                }
                            },
                            onComplete: {
                                Task {
                                    await viewModel.completeRide(id: ride.id)
                                }
                            },
                            onCancel: {
                                Task {
                                    await viewModel.cancelRide(id: ride.id)
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
        switch selectedSegment {
        case 0: return "You don't have any upcoming rides"
        case 1: return "You don't have any active rides"
        case 2: return "You don't have any past rides"
        default: return "No rides"
        }
    }
    
    private var emptyDescription: String {
        switch selectedSegment {
        case 0: return "Create a new ride and start earning"
        case 1: return "Rides you have started will appear here"
        case 2: return "Completed and cancelled rides will appear here"
        default: return ""
        }
    }
}
#Preview("My Rides View") {
    NavigationView {
        MyRidesView()
    }
}
