import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showVehicles = false
    @State private var showMyRatings = false
    @State private var showSettings = false
    @State private var showPrivacySecurity = false
    @State private var showHelpSupport = false
    @State private var showTermsOfService = false
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
        .navigationTitle("Profile")
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
        .sheet(isPresented: $showMyRatings) {
            NavigationView {
                MyRatingsView()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showPrivacySecurity) {
            PrivacySecurityView()
        }
        .sheet(isPresented: $showHelpSupport) {
            HelpSupportView()
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
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
                    label: "Rides"
                )
                
                StatCard(
                    icon: "star.fill",
                    value: String(format: "%.1f", stats.averageRating),
                    label: "Rating"
                )
                
                StatCard(
                    icon: "person.2.fill",
                    value: "\(stats.totalRatings)",
                    label: "Ratings"
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
            Text("Account Information")
                .font(.headline)
            
            VStack(spacing: 0) {
                InfoRow(
                    icon: "person.fill",
                    title: "Name and surname",
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
                    title: "Phone",
                    value: viewModel.user?.phone ?? ""
                )
                
                if let createdAt = viewModel.user?.createdAt {
                    Divider()
                        .padding(.leading, 40)
                    
                    InfoRow(
                        icon: "calendar",
                        title: "Member since",
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
            Text("Quick actions")
                .font(.headline)
            
            VStack(spacing: 0) {
                ActionRow(
                    icon: "pencil",
                    title: "Edit profile",
                    color: .blue
                ) {
                    showEditProfile = true
                }
                
                if viewModel.user?.isDriver == true {
                    Divider()
                        .padding(.leading, 40)
                    
                    ActionRow(
                        icon: "car.fill",
                        title: "My vehicles",
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
                    title: "My ratings",
                    color: .orange
                ) {
                    showMyRatings = true
                }
                
                // MARK: - Hidden for future use
                // Divider()
                //     .padding(.leading, 40)
                // 
                // ActionRow(
                //     icon: "bell.fill",
                //     title: "Notifikacije",
                //     color: .purple
                // ) {
                //     // TODO: Navigate to notifications settings
                // }
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
                Text("Vehicles")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showVehicles = true }) {
                    Text("Show all")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if viewModel.vehicles.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "car.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("You have no vehicles")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: { showVehicles = true }) {
                        Text("Add vehicle")
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
            Text("Settings")
                .font(.headline)
            
            VStack(spacing: 0) {
                ActionRow(
                    icon: "gear",
                    title: "General settings",
                    color: .gray
                ) {
                    showSettings = true
                }
                
                Divider()
                    .padding(.leading, 40)
                
                ActionRow(
                    icon: "lock.fill",
                    title: "Privacy and security",
                    color: .orange
                ) {
                    showPrivacySecurity = true
                }
                
                Divider()
                    .padding(.leading, 40)
                
                ActionRow(
                    icon: "questionmark.circle.fill",
                    title: "Help and support",
                    color: .blue
                ) {
                    showHelpSupport = true
                }
                
                Divider()
                    .padding(.leading, 40)
                
                ActionRow(
                    icon: "doc.text.fill",
                    title: "Terms of service",
                    color: .green
                ) {
                    showTermsOfService = true
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
                Text("Logout")
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
        Text("Version \(Constants.App.version) (\(Constants.App.build))")
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }
}
#Preview("Profile View") {
    NavigationView {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
