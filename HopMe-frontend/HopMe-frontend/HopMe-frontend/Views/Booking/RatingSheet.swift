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
    
    init(booking: Booking, onComplete: @escaping () -> Void, isDriverRatingPassenger: Bool) {
        self.booking = booking
        self.onComplete = onComplete
        self.isDriverRatingPassenger = isDriverRatingPassenger
        
        print("🔵 RatingSheet INIT")
        print("   Booking ID: \(booking.id)")
        print("   isDriverRatingPassenger: \(isDriverRatingPassenger)")
        print("   Passenger: \(booking.passenger.firstName) \(booking.passenger.lastName)")
        print("   Driver: \(booking.ride.driver.firstName) \(booking.ride.driver.lastName)")
    }
    
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
                        Text("Comment (optional)")
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
                                Text("Rate")
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
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                print("🟢 RatingSheet APPEARED")
                print("   User being rated: \(getUserName())")
            }
        }
        .onAppear {
            print("🟡 NavigationView APPEARED")
        }
    }
    
    // MARK: - Helper Functions
    
    private func getUserName() -> String {
        let name: String
        if isDriverRatingPassenger {
            name = "\(booking.passenger.firstName) \(booking.passenger.lastName)"
        } else {
            name = "\(booking.ride.driver.firstName) \(booking.ride.driver.lastName)"
        }
        print("🔸 getUserName() = \(name)")
        return name
    }
    
    private func getUserInitials() -> String {
        let initials: String
        if isDriverRatingPassenger {
            initials = String(booking.passenger.firstName.prefix(1))
        } else {
            initials = String(booking.ride.driver.firstName.prefix(1))
        }
        print("🔸 getUserInitials() = \(initials)")
        return initials
    }
    
    private func getNavigationTitle() -> String {
        return isDriverRatingPassenger ? "Rate passenger" : "Rate ride"
    }
    
    private func getQuestionText() -> String {
        return isDriverRatingPassenger ? "How would you rate the passenger?" : "How would you rate the ride?"
    }
    
    private func getRatingText() -> String {
        switch rating {
        case 1: return "Bad"
        case 2: return "Not good"
        case 3: return "OK"
        case 4: return "Good"
        case 5: return "Excellent"
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
                    errorMessage = "Error rating. Please try again."
                }
            }
        }
    }
}
