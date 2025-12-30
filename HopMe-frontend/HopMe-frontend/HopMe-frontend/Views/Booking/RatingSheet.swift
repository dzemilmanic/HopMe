import SwiftUI

struct RatingSheet: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    let booking: Booking
    let onComplete: () -> Void
    let isDriverRatingPassenger: Bool
    
    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar and Name
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(getUserInitials())
                                    .font(.title)
                                    .foregroundColor(.blue)
                            )
                        
                        Text(getUserName())
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("\(booking.ride.departureLocation) → \(booking.ride.arrivalLocation)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // Rating Stars
                    VStack(spacing: 16) {
                        Text(getQuestionText())
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
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical)
                        
                        Text(getRatingText())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Comment
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
                    
                    // Error
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Submit Button
                    Button(action: {
                        submitRating()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Oceni")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoading ? Color.blue.opacity(0.6) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading)
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle(getNavigationTitle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Otkaži") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func getUserName() -> String {
        if isDriverRatingPassenger {
            return "\(booking.passenger.firstName) \(booking.passenger.lastName)"
        } else {
            return "\(booking.ride.driver.firstName) \(booking.ride.driver.lastName)"
        }
    }
    
    private func getUserInitials() -> String {
        if isDriverRatingPassenger {
            return String(booking.passenger.firstName.prefix(1))
        } else {
            return String(booking.ride.driver.firstName.prefix(1))
        }
    }
    
    private func getNavigationTitle() -> String {
        return isDriverRatingPassenger ? "Oceni putnika" : "Oceni vožnju"
    }
    
    private func getQuestionText() -> String {
        return isDriverRatingPassenger ? "Kako biste ocenili putnika?" : "Kako biste ocenili vožnju?"
    }
    
    private func getRatingText() -> String {
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
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let request = RatingRequest(
                    bookingId: booking.id,
                    rideId: booking.rideId,
                    rating: rating,
                    comment: comment.isEmpty ? nil : comment
                )
                
                try await RatingService.shared.createRating(request: request)
                
                await MainActor.run {
                    isLoading = false
                    onComplete()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Greška pri ocenjivanju. Pokušajte ponovo."
                }
            }
        }
    }
}
