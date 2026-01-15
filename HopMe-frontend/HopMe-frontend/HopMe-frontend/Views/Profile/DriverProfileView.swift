import SwiftUI
import Foundation

struct DriverProfileView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    let driver: Driver
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar
                    if let profileImage = driver.profileImage {
                        AsyncImage(url: URL(string: profileImage)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .overlay(
                                    Text(driver.initials)
                                        .font(.system(size: 50))
                                        .foregroundColor(.blue)
                                )
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Text(driver.initials)
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                            )
                    }
                    
                    // Name
                    Text(driver.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Stats
                    HStack(spacing: 20) {
                        VStack {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                Text(driver.formattedRating)
                                    .fontWeight(.bold)
                            }
                            Text("Rating")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack {
                            Text("\(driver.totalRatings)")
                                .fontWeight(.bold)
                            Text("Reviews")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        if let totalRides = driver.totalRides {
                            Divider()
                                .frame(height: 40)
                            
                            VStack {
                                Text("\(totalRides)")
                                    .fontWeight(.bold)
                                Text("Rides")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // Note
                    Text("More information about the driver will be available after the reservation")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Driver profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

