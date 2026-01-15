import Foundation
import SwiftUI
import Combine

@MainActor
class RatingViewModel: ObservableObject {
    @Published var rating = 5
    @Published var comment = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let ratingService = RatingService.shared
    
    func submitRating(bookingId: Int, rideId: Int) async -> Bool {
        guard rating >= 1 && rating <= 5 else {
            errorMessage = "Rating must be between 1 and 5"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = RatingRequest(
            bookingId: bookingId,
            rideId: rideId,
            rating: self.rating,
            comment: self.comment.isEmpty ? nil : self.comment
        )
        
        do {
            try await ratingService.createRating(request: request)
            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Error rating"
            isLoading = false
            return false
        }
    }
}
