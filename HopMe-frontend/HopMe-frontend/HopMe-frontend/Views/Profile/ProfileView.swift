import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showVehicles = false
    @State private var showSettings = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with Avatar and Name
                profileHeader
                
                // Stats Cards (if driver)
                if viewModel.user?.isDriver == true {
                    statsSection
                }
                
                // Account Info
                accountInfoSection
                
                // Actions Menu
                actionsSection
                
                // Vehicles (if driver)
                if viewModel.user?.isDriver == true {
                    vehiclesSection
                }
                
                // Settings
                settingsSection
                
                // Logout Button
                logoutButton
                
                // App Version
                appVersion
            }
            .padding()
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showEditProfile = true }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            if let user = viewModel.user {
                EditProfileView(user: user) {
                    Task {
                        await viewModel.refreshProfile()
                    }
                }
            }
        }
        .sheet(isPresented: $showVehicles) {
            VehiclesView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .alert("Odjava", isPresented: $showLogoutAlert) {
            Button("Otkaži", role: .cancel) { }
            Button("Odjavi se", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Da li ste sigurni da želite da se odjavite?")
        }
        .task {
            await viewModel.loadProfile()
        }
        .refreshable {
            await viewModel.refreshProfile()
        }
        .loading(viewModel.isLoading)
        .errorAlert(errorMessage: $viewModel.errorMessage)
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            if let profileImageUrl = viewModel.user?.profileImageUrl {
                AsyncImage(url: URL(string: profileImageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .overlay(
                            Text(viewModel.user?.initials ?? "")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        )
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(viewModel.user?.initials ?? "")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    )
            }
            
            // Name
            Text(viewModel.user?.fullName ?? "")
                .font(.title2)
                .fontWeight(.bold)
            
            // Email
            Text(viewModel.user?.email ?? "")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Roles Badges
            HStack(spacing: 8) {
                ForEach(viewModel.user?.roles ?? [], id: \.rawValue) { role in
                    RoleBadge(role: role)
                }
            }
            
            // Account Status
            if let status = viewModel.user?.accountStatus {
                StatusBadge(
                    status: status.displayName,
                    color: Color(status.color)
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 12) {
            if let stats = viewModel.stats {
                StatCard(
                    icon: "car.fill",
                    value: "\(stats.totalRides)",
                    label: "Vožnji"
                )
                
                StatCard(
                    icon: "star.fill",
                    value: String(format: "%.1f", stats.averageRating),
                    label: "Ocena"
                )
                
                StatCard(
                    icon: "person.2.fill",
                    value: "\(stats.totalRatings)",
                    label: "Recenzija"
                )
                
                if let earnings = stats.totalEarnings {
                    StatCard(
                        icon: "banknote.fill",
                        value: "\(Int(earnings))",
                        label: "RSD"
                    )
                }
            }
        }
    }
    
    // MARK: - Account Info Section
    private var accountInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informacije o nalogu")
                .font(.headline)
            
            VStack(spacing: 0) {
                InfoRow(
                    icon: "person.fill",
                    title: "Ime i prezime",
                    value: viewModel.user?.fullName ?? ""
                )
                
                Divider()
                    .padding(.leading, 40)
                
                InfoRow(
                    icon: "envelope.fill",
                    title: "Email",
                    value: viewModel.user?.email ?? ""
                )
                
                Divider()
                    .padding(.leading, 40)
                
                InfoRow(
                    icon: "phone.fill",
                    title: "Telefon",
                    value: viewModel.user?.phone ?? ""
                )
                
                if let createdAt = viewModel.user?.createdAt {
                    Divider()
                        .padding(.leading, 40)
                    
                    InfoRow(
                        icon: "calendar",
                        title: "Član od",
                        value: createdAt.formatted(date: .abbreviated, time: .omitted)
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Brze akcije")
                .font(.headline)
            
            VStack(spacing: 0) {
                ActionRow(
                    icon: "pencil",
                    title: "Izmeni profil",
                    color: .blue
                ) {
                    showEditProfile = true
                }
                
                if viewModel.user?.isDriver == true {
                    Divider()
                        .padding(.leading, 40)
                    
                    ActionRow(
                        icon: "car.fill",
                        title: "Moja vozila",
                        color: .green,
                        badge: "\(viewModel.vehicles.count)"
                    ) {
                        showVehicles = true
                    }
                }
                
                Divider()
                    .padding(.leading, 40)
                
                ActionRow(
                    icon: "star.fill",
                    title: "Moje ocene",
                    color: .orange
                ) {
                    // TODO: Navigate to ratings
                }
                
                Divider()
                    .padding(.leading, 40)
                
                ActionRow(
                    icon: "bell.fill",
                    title: "Notifikacije",
                    color: .purple
                ) {
                    // TODO: Navigate to notifications settings
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Vehicles Section
    private var vehiclesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Vozila")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showVehicles = true }) {
                    Text("Prikaži sve")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if viewModel.vehicles.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "car.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("Nemate dodato vozilo")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: { showVehicles = true }) {
                        Text("Dodaj vozilo")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.vehicles.prefix(3)) { vehicle in
                            VehicleSmallCard(vehicle: vehicle)
                        }
                        
                        if viewModel.vehicles.count > 3 {
                            Button(action: { showVehicles = true }) {
                                VStack {
                                    Image(systemName: "plus")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                    
                                    Text("+\(viewModel.vehicles.count - 3)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 120, height: 100)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Podešavanja")
                .font(.headline)
            
            VStack(spacing: 0) {
                ActionRow(
                    icon: "gear",
                    title: "Opšta podešavanja",
                    color: .gray
                ) {
                    showSettings = true
                }
                
                Divider()
                    .padding(.leading, 40)
                
                ActionRow(
                    icon: "lock.fill",
                    title: "Privatnost i bezbednost",
                    color: .orange
                ) {
                    // TODO: Navigate to privacy settings
                }
                
                Divider()
                    .padding(.leading, 40)
                
                ActionRow(
                    icon: "questionmark.circle.fill",
                    title: "Pomoć i podrška",
                    color: .blue
                ) {
                    // TODO: Navigate to help
                }
                
                Divider()
                    .padding(.leading, 40)
                
                ActionRow(
                    icon: "doc.text.fill",
                    title: "Uslovi korišćenja",
                    color: .green
                ) {
                    // TODO: Open terms
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Logout Button
    private var logoutButton: some View {
        Button(action: { showLogoutAlert = true }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Odjavi se")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - App Version
    private var appVersion: some View {
        Text("Verzija \(Constants.App.version) (\(Constants.App.build))")
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }
}
