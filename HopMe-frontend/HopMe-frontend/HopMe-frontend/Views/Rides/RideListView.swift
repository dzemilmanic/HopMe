import SwiftUI

struct RideListView: View {
    let rides: [Ride]
    let title: String
    var emptyMessage: String = "No available rides"
    
    var body: some View {
        ScrollView {
            if rides.isEmpty {
                EmptyStateView(
                    icon: "car.fill",
                    title: "No rides",
                    description: emptyMessage
                )
                .frame(height: 400)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(rides) { ride in
                        NavigationLink(destination: RideDetailView(ride: ride)) {
                            RideCard(ride: ride)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview("Ride List View") {
    NavigationView {
        RideListView(
            rides: [],
            title: "Search results"
        )
    }
}
