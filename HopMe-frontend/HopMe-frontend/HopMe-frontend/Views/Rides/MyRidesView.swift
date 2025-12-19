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
                Text("Nadolazeće (\(viewModel.upcomingRides.count))").tag(0)
                Text("Aktivne (\(viewModel.activeRides.count))").tag(1)
                Text("Prošle (\(viewModel.pastRides.count))").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            if viewModel.isLoading {
                LoadingView(message: "Učitavanje vožnji...")
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
        .navigationTitle("Moje vožnje")
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
                    actionTitle: selectedSegment == 0 ? "Kreiraj vožnju" : nil,
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
        case 0: return "Nemate nadolazećih vožnji"
        case 1: return "Nemate aktivnih vožnji"
        case 2: return "Nemate prošlih vožnji"
        default: return "Nema vožnji"
        }
    }
    
    private var emptyDescription: String {
        switch selectedSegment {
        case 0: return "Kreirajte novu vožnju i počnite da zarađujete"
        case 1: return "Vožnje koje ste započeli će se pojaviti ovde"
        case 2: return "Završene i otkazane vožnje će se pojaviti ovde"
        default: return ""
        }
    }
}
