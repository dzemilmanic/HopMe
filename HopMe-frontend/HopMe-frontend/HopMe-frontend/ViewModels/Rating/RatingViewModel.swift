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
            errorMessage = "Ocena mora biti između 1 i 5"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = RatingRequest(
            bookingId: bookingId,
            rideId: rideId,
            rating: rating,
            comment: comment.isEmpty ? nil : comment
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
            errorMessage = "Greška pri ocenjivanju"
            isLoading = false
            return false
        }
    }
}
