import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationViewModel()
    @State private var selectedFilter: NotificationFilter = .all
    @State private var showFilterMenu = false
    @State private var notificationToDelete: NotificationModel?
    @State private var showDeleteAlert = false
    
    enum NotificationFilter: String, CaseIterable {
        case all = "Sve"
        case unread = "Nepročitane"
        case bookings = "Rezervacije"
        case rides = "Vožnje"
        case ratings = "Ocene"
        
        var icon: String {
            switch self {
            case .all: return "tray.fill"
            case .unread: return "envelope.badge.fill"
            case .bookings: return "list.bullet"
            case .rides: return "car.fill"
            case .ratings: return "star.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Bar
            if !viewModel.notifications.isEmpty {
                filterBar
            }
            
            // Content
            if viewModel.isLoading {
                LoadingView(message: "Učitavanje notifikacija...")
            } else if let error = viewModel.errorMessage {
                ErrorView(
                    message: error,
                    retryAction: {
                        Task {
                            await viewModel.loadNotifications()
                        }
                    }
                )
            } else {
                notificationsList
            }
        }
        .navigationTitle("Notifikacije")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        Task {
                            await viewModel.markAllAsRead()
                        }
                    }) {
                        Label("Označi sve kao pročitano", systemImage: "envelope.open.fill")
                    }
                    .disabled(viewModel.unreadNotifications.isEmpty)
                    
                    Divider()
                    
                    ForEach(NotificationFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                        }) {
                            Label(filter.rawValue, systemImage: filter.icon)
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Brisanje notifikacije", isPresented: $showDeleteAlert) {
            Button("Otkaži", role: .cancel) {
                notificationToDelete = nil
            }
            Button("Obriši", role: .destructive) {
                if let notification = notificationToDelete {
                    Task {
                        await viewModel.deleteNotification(id: notification.id)
                    }
                }
                notificationToDelete = nil
            }
        } message: {
            Text("Da li ste sigurni da želite da obrišete ovu notifikaciju?")
        }
        .task {
            await viewModel.loadNotifications()
        }
        .refreshable {
            await viewModel.loadNotifications()
        }
    }
    
    // MARK: - Filter Bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(NotificationFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        icon: filter.icon,
                        isSelected: selectedFilter == filter,
                        count: countForFilter(filter)
                    ) {
                        withAnimation {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // MARK: - Notifications List
    private var notificationsList: some View {
        ScrollView {
            let filteredNotifications = filterNotifications()
            
            if filteredNotifications.isEmpty {
                EmptyStateView(
                    icon: "bell.slash.fill",
                    title: emptyTitle,
                    description: emptyDescription
                )
                .frame(height: 400)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(filteredNotifications) { notification in
                        NotificationCard(
                            notification: notification,
                            onTap: {
                                handleNotificationTap(notification)
                            },
                            onDelete: {
                                notificationToDelete = notification
                                showDeleteAlert = true
                            }
                        )
                        
                        Divider()
                            .padding(.leading, 72)
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func filterNotifications() -> [NotificationModel] {
        let notifications = viewModel.notifications
        
        switch selectedFilter {
        case .all:
            return notifications
        case .unread:
            return notifications.filter { !$0.isRead }
        case .bookings:
            return notifications.filter {
                $0.type == .newBooking ||
                $0.type == .bookingAccepted ||
                $0.type == .bookingRejected ||
                $0.type == .bookingCancelled
            }
        case .rides:
            return notifications.filter {
                $0.type == .rideCancelled ||
                $0.type == .rideCompleted
            }
        case .ratings:
            return notifications.filter { $0.type == .newRating }
        }
    }
    
    private func countForFilter(_ filter: NotificationFilter) -> Int? {
        switch filter {
        case .all:
            return viewModel.notifications.count
        case .unread:
            let count = viewModel.unreadNotifications.count
            return count > 0 ? count : nil
        default:
            return nil
        }
    }
    
    private var emptyTitle: String {
        switch selectedFilter {
        case .all: return "Nema notifikacija"
        case .unread: return "Nema nepročitanih"
        case .bookings: return "Nema notifikacija o rezervacijama"
        case .rides: return "Nema notifikacija o vožnjama"
        case .ratings: return "Nema notifikacija o ocenama"
        }
    }
    
    private var emptyDescription: String {
        switch selectedFilter {
        case .all: return "Biće prikazane ovde kada ih dobijete"
        case .unread: return "Sve notifikacije su pročitane"
        case .bookings: return "Notifikacije o rezervacijama će se pojaviti ovde"
        case .rides: return "Notifikacije o vožnjama će se pojaviti ovde"
        case .ratings: return "Notifikacije o ocenama će se pojaviti ovde"
        }
    }
    
    private func handleNotificationTap(_ notification: NotificationModel) {
        // Mark as read
        if !notification.isRead {
            Task {
                await viewModel.markAsRead(id: notification.id)
            }
        }
        
        // TODO: Navigate based on notification type and data
        // Example:
        // if let rideId = notification.data?["rideId"] {
        //     navigate to RideDetailView(rideId: rideId)
        // }
    }
}
