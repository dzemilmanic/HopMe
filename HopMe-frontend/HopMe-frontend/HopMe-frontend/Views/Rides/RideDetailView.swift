import SwiftUI
import MapKit

struct RideDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: RideDetailViewModel
    @State private var showBooking = false
    @State private var showDriverProfile = false
    @State private var showMap = false
    @State private var selectedTab = 0
    
    init(ride: Ride) {
        _viewModel = StateObject(wrappedValue: RideDetailViewModel(ride: ride))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Route Header Card
                routeHeaderCard
                
                // Tab Selector
                tabSelector
                
                // Tab Content
                switch selectedTab {
                case 0:
                    rideDetailsTab
                case 1:
                    driverInfoTab
                case 2:
                    if let waypoints = viewModel.ride.waypoints, !waypoints.isEmpty {
                        waypointsTab
                    } else {
                        Text("Nema usputnih stanica")
                            .foregroundColor(.gray)
                            .padding()
                    }
                default:
                    EmptyView()
                }
            }
        }
        .navigationTitle("Detalji vožnje")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showMap = true }) {
                    Image(systemName: "map.fill")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.ride.isAvailable && !isOwnRide {
                bookingButton
            }
        }
        .sheet(isPresented: $showBooking) {
            BookingView(ride: viewModel.ride)
        }
        .sheet(isPresented: $showDriverProfile) {
            DriverProfileView(driver: viewModel.ride.driver)
        }
        .sheet(isPresented: $showMap) {
            RideMapView(ride: viewModel.ride)
        }
        .task {
            await viewModel.loadRideDetails()
        }
        .refreshable {
            await viewModel.refreshRide()
        }
        .loading(viewModel.isLoading)
        .errorAlert(errorMessage: $viewModel.errorMessage)
    }
    
    // MARK: - Route Header Card
    private var routeHeaderCard: some View {
        VStack(spacing: 16) {
            // Route
            HStack(alignment: .center, spacing: 16) {
                // From
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text(viewModel.ride.departureLocation)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(viewModel.ride.departureTime.formatted(time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Arrow
                VStack(spacing: 4) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)
                    
                    if let duration = calculateDuration() {
                        Text(duration)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // To
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                    
                    Text(viewModel.ride.arrivalLocation)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if let arrivalTime = viewModel.ride.arrivalTime {
                        Text(arrivalTime.formatted(time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Divider()
            
            // Date and Quick Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.ride.departureTime.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 12) {
                        Label("\(viewModel.ride.remainingSeats) mesta", systemImage: "person.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if viewModel.ride.autoAcceptBookings {
                            Label("Auto prihvat", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing) {
                    Text(viewModel.ride.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("po mestu")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        .padding()
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Detalji", isSelected: selectedTab == 0) {
                withAnimation { selectedTab = 0 }
            }
            
            TabButton(title: "Vozač", isSelected: selectedTab == 1) {
                withAnimation { selectedTab = 1 }
            }
            
            if let waypoints = viewModel.ride.waypoints, !waypoints.isEmpty {
                TabButton(title: "Ruta", isSelected: selectedTab == 2) {
                    withAnimation { selectedTab = 2 }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Ride Details Tab
    private var rideDetailsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Vehicle Info
            if let vehicle = viewModel.ride.vehicle {
                DetailSection(title: "Vozilo") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                            
                            Text(vehicle.displayName)
                                .font(.headline)
                            
                            Spacer()
                            
                            if let color = vehicle.color {
                                Text(color)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if let images = vehicle.images, !images.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(images) { image in
                                        AsyncImage(url: URL(string: image.imageUrl)) { img in
                                            img
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                        }
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Ride Preferences
            DetailSection(title: "Preferencije") {
                VStack(spacing: 12) {
                    PreferenceRow(
                        icon: "checkmark.circle.fill",
                        title: "Automatski prihvat",
                        value: viewModel.ride.autoAcceptBookings,
                        activeColor: .green
                    )
                    
                    PreferenceRow(
                        icon: "smoke.fill",
                        title: "Dozvoljeno pušenje",
                        value: viewModel.ride.allowSmoking,
                        activeColor: .orange
                    )
                    
                    PreferenceRow(
                        icon: "pawprint.fill",
                        title: "Dozvoljeni kućni ljubimci",
                        value: viewModel.ride.allowPets,
                        activeColor: .brown
                    )
                    
                    PreferenceRow(
                        icon: "person.2.fill",
                        title: "Maksimalno dvoje pozadi",
                        value: viewModel.ride.maxTwoInBack,
                        activeColor: .blue
                    )
                }
            }
            
            // Luggage Size
            if let luggageSize = viewModel.ride.luggageSize {
                DetailSection(title: "Prtljag") {
                    HStack {
                        Image(systemName: "suitcase.fill")
                            .foregroundColor(.purple)
                        
                        Text(luggageSize)
                            .font(.subheadline)
                        
                        Spacer()
                    }
                }
            }
            
            // Description
            if let description = viewModel.ride.description, !description.isEmpty {
                DetailSection(title: "Opis") {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Status Badge
            DetailSection(title: "Status") {
                HStack {
                    StatusBadge(
                        status: viewModel.ride.status.displayName,
                        color: Color(viewModel.ride.status.color)
                    )
                    
                    Spacer()
                }
            }
        }
        .padding()
    }
    
    // MARK: - Driver Info Tab
    private var driverInfoTab: some View {
        VStack(spacing: 16) {
            // Driver Card
            Button(action: { showDriverProfile = true }) {
                HStack(spacing: 16) {
                    // Avatar
                    if let profileImage = viewModel.ride.driver.profileImage {
                        AsyncImage(url: URL(string: profileImage)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .overlay(
                                    Text(viewModel.ride.driver.initials)
                                        .font(.title)
                                        .foregroundColor(.blue)
                                )
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(viewModel.ride.driver.initials)
                                    .font(.title)
                                    .foregroundColor(.blue)
                            )
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.ride.driver.fullName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                    .font(.subheadline)
                                
                                Text(viewModel.ride.driver.formattedRating)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("(\(viewModel.ride.driver.totalRatings))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            if let totalRides = viewModel.ride.driver.totalRides {
                                HStack(spacing: 4) {
                                    Image(systemName: "car.fill")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    
                                    Text("\(totalRides) vožnji")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        HStack {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("Pogledaj profil")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Stats
            HStack(spacing: 12) {
                DriverStatCard(
                    icon: "star.fill",
                    value: viewModel.ride.driver.formattedRating,
                    label: "Ocena"
                )
                
                DriverStatCard(
                    icon: "person.fill",
                    value: "\(viewModel.ride.driver.totalRatings)",
                    label: "Recenzije"
                )
                
                if let totalRides = viewModel.ride.driver.totalRides {
                    DriverStatCard(
                        icon: "car.fill",
                        value: "\(totalRides)",
                        label: "Vožnje"
                    )
                }
            }
        }
        .padding()
    }
    
    // MARK: - Waypoints Tab
    private var waypointsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let waypoints = viewModel.ride.waypoints?.sorted(by: { $0.orderIndex < $1.orderIndex }) {
                ForEach(Array(waypoints.enumerated()), id: \.element.id) { index, waypoint in
                    WaypointRow(
                        waypoint: waypoint,
                        isFirst: index == 0,
                        isLast: index == waypoints.count - 1
                    )
                }
            }
        }
        .padding()
    }
    
    // MARK: - Booking Button
    private var bookingButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ukupno")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(viewModel.ride.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: { showBooking = true }) {
                    Text("Rezerviši")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Helpers
    private var isOwnRide: Bool {
        viewModel.ride.driverId == authViewModel.currentUser?.id
    }
    
    private func calculateDuration() -> String? {
        guard let arrivalTime = viewModel.ride.arrivalTime else { return nil }
        let duration = arrivalTime.timeIntervalSince(viewModel.ride.departureTime)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        }
        return "\(minutes)min"
    }
}
