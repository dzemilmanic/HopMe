import SwiftUI

struct RatingSheet: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    let booking: Booking
    let onComplete: () -> Void
    let isDriverRatingPassenger: Bool
    
    @StateObject private var viewModel = RatingViewModel()
    @State private var rating: Int = 5
    @State private var comment: String = ""
    
    // Computed properties to determine who is being rated
    private var ratedUserName: String {
        isDriverRatingPassenger ? booking.passenger.fullName : booking.ride.driver.fullName
    }
    
    private var ratedUserInitials: String {
        if isDriverRatingPassenger {
            return String(booking.passenger.firstName.prefix(1))
        } else {
            return booking.ride.driver.initials
        }
    }
    
    private var ratedUserProfileImage: String? {
        isDriverRatingPassenger ? booking.passenger.profileImage : booking.ride.driver.profileImage
    }
    
    private var navigationTitle: String {
        isDriverRatingPassenger ? "Oceni putnika" : "Oceni vožnju"
    }
    
    private var questionText: String {
        isDriverRatingPassenger ? "Kako biste ocenili putnika?" : "Kako biste ocenili vožnju?"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // User Info (Driver or Passenger being rated)
                    VStack(spacing: 12) {
                        // Avatar
                        if let profileImage = ratedUserProfileImage {
                            AsyncImage(url: URL(string: profileImage)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .overlay(
                                        Text(ratedUserInitials)
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
                                    Text(ratedUserInitials)
                                        .font(.title)
                                        .foregroundColor(.blue)
                                )
                        }
                        
                        Text(ratedUserName)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("\(booking.ride.departureLocation) → \(booking.ride.arrivalLocation)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // Rating Section
                    VStack(spacing: 16) {
                        Text(questionText)
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    rating = star
                                }) {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.system(size: 36))
                                        .foregroundColor(star <= rating ? .orange : .gray.opacity(0.3))
                                }
                            }
                        }
                        .padding(.vertical)
                        
                        Text(ratingText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Comment Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Komentar (opciono)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextEditor(text: $comment)
                            .frame(height: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Submit Button
                    CustomButton(
                        title: "Oceni",
                        action: submitRating,
                        style: .primary,
                        isLoading: viewModel.isLoading
                    )
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Otkaži") {
                        dismiss()
                    }
                }
            }
            .errorAlert(errorMessage: $viewModel.errorMessage)
        }
    }
    
    private var ratingText: String {
        switch rating {
        case 1: return "Loše"
        case 2: return "Nije dobro"
        case 3: return "Okej"
        case 4: return "Dobro"
        case 5: return "Odlično"
        default: return ""
        }
    }
    
    private func submitRating() {
        // PRVO postavi rating i comment u viewModel
        viewModel.rating = rating
        viewModel.comment = comment
        
        Task {
            let success = await viewModel.submitRating(
                bookingId: booking.id,
                rideId: booking.rideId
            )
            
            if success {
                onComplete()
                dismiss()
            }
        }
    }
}
