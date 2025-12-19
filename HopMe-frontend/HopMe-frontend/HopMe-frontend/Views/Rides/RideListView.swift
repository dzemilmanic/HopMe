import SwiftUI

struct RideListView: View {
    let rides: [Ride]
    let title: String
    var emptyMessage: String = "Nema dostupnih vožnji"
    
    var body: some View {
        ScrollView {
            if rides.isEmpty {
                EmptyStateView(
                    icon: "car.fill",
                    title: "Nema vožnji",
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
