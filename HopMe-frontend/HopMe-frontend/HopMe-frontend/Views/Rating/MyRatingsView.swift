import SwiftUI

struct MyRatingsView: View {
    @StateObject private var viewModel = MyRatingsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Stats Header
            if let stats = viewModel.stats {
                statsHeader(stats: stats)
                    .padding()
                    .background(Color(.systemBackground))
            }
            
            // Tab Selector
            Picker("", selection: $selectedTab) {
                Text("Dobijene (\(viewModel.receivedRatings.count))")
                    .tag(0)
                Text("Date (\(viewModel.givenRatings.count))")
                    .tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            TabView(selection: $selectedTab) {
                // Received Ratings Tab
                receivedRatingsTab
                    .tag(0)
                
                // Given Ratings Tab
                givenRatingsTab
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Moje ocene")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadRatings()
        }
        .refreshable {
            await viewModel.refreshRatings()
        }
        .loading(viewModel.isLoading)
        .errorAlert(errorMessage: $viewModel.errorMessage)
    }
    
    // MARK: - Stats Header
    private func statsHeader(stats: MyRatingsStats) -> some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(stats.totalReceived)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Primljeno")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text(String(format: "%.1f", stats.averageReceived))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Text("Prosek")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack(spacing: 4) {
                Text("\(stats.totalGiven)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Dato")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Received Ratings Tab
    private var receivedRatingsTab: some View {
        Group {
            if viewModel.receivedRatings.isEmpty {
                emptyState(
                    icon: "star.slash",
                    title: "Nemate primljenih ocena",
                    message: "Kada vas neko oceni, ocene će se pojaviti ovde"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.receivedRatings) { rating in
                            RatingCard(
                                rating: rating,
                                showRater: true,
                                showRated: false
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Given Ratings Tab
    private var givenRatingsTab: some View {
        Group {
            if viewModel.givenRatings.isEmpty {
                emptyState(
                    icon: "star",
                    title: "Nemate datih ocena",
                    message: "Kada ocenite nekoga, ocene će se pojaviti ovde"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.givenRatings) { rating in
                            RatingCard(
                                rating: rating,
                                showRater: false,
                                showRated: true
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Empty State
    private func emptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Rating Card Component
struct RatingCard: View {
    let rating: Rating
    let showRater: Bool
    let showRated: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // User Info
                if showRater {
                    UserInfoRow(user: rating.rater, label: "Ocenio")
                } else if showRated, let rated = rating.rated {
                    UserInfoRow(user: rated, label: "Ocenjen")
                }
                
                Spacer()
                
                // Rating Stars
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating.rating ? "star.fill" : "star")
                            .foregroundColor(star <= rating.rating ? .orange : .gray.opacity(0.3))
                            .font(.caption)
                    }
                }
            }
            
            // Comment
            if let comment = rating.comment, !comment.isEmpty {
                Text(comment)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Date
            HStack {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(rating.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - User Info Row
struct UserInfoRow: View {
    let user: UserInfo
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            // Avatar
            if let profileImage = user.profileImage {
                AsyncImage(url: URL(string: profileImage)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .overlay(
                            Text(user.initials)
                                .font(.caption)
                                .foregroundColor(.blue)
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(user.initials)
                            .font(.caption)
                            .foregroundColor(.blue)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.fullName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview("My Ratings View") {
    NavigationView {
        MyRatingsView()
    }
}
