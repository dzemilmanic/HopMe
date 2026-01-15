import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    @StateObject private var notificationViewModel = NotificationViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // Rides Tab (different for drivers and passengers)
            NavigationView {
                if authViewModel.currentUser?.isDriver == true {
                    MyRidesView()
                } else {
                    SearchView()
                }
            }
            .tabItem {
                Label(
                    authViewModel.currentUser?.isDriver == true ? "My rides" : "Search",
                    systemImage: authViewModel.currentUser?.isDriver == true ? "car.fill" : "magnifyingglass"
                )
            }
            .tag(1)
            
            // Bookings Tab
            NavigationView {
                MyBookingsView()
            }
            .tabItem {
                Label("Bookings", systemImage: "list.bullet")
            }
            .tag(2)
            
            // Notifications Tab
            NavigationView {
                NotificationsView()
            }
            .tabItem {
                Label("Notifications", systemImage: "bell.fill")
            }
            .badge(notificationViewModel.unreadCount > 0 ? "\(notificationViewModel.unreadCount)" : "")            .tag(3)
            
            // Profile Tab
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(4)
        }
        .accentColor(.blue)
        .onAppear {
            Task {
                await notificationViewModel.loadNotifications()
            }
        }
    }
}
#Preview("Main Tab View") {
    MainTabView()
        .environmentObject(AuthViewModel())
}
