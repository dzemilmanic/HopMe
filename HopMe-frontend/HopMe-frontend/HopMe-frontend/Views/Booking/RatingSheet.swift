import SwiftUI

struct RatingSheet: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    let booking: Booking
    let onComplete: () -> Void
    
    @StateObject private var viewModel = RatingViewModel()
    @State private var rating: Int = 5
    @State private var comment: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Driver Info
                    VStack(spacing: 12) {
                        // Avatar
                        if let profileImage = booking.ride.driver.profileImage {
                            AsyncImage(url: URL(string: profileImage)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .overlay(
                                        Text(booking.ride.driver.initials)
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
                                    Text(booking.ride.driver.initials)
                                        .font(.title)
                                        .foregroundColor(.blue)
                                )
                        }
                        
                        Text(booking.ride.driver.fullName)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("\(booking.ride.departureLocation) → \(booking.ride.arrivalLocation)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // Rating Section
                    VStack(spacing: 16) {
                        Text("Kako biste ocenili vožnju?")
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
            .navigationTitle("Oceni vožnju")
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
