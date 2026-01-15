import Foundation
import SwiftUI
import Combine

@MainActor
class UserRatingsViewModel: ObservableObject {
    @Published var ratings: [Rating] = []
    @Published var stats: RatingStats?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let ratingService = RatingService.shared
    
    func loadRatings(userId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await ratingService.getUserRatings(userId: userId)
            ratings = result.ratings
            stats = result.stats
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error loading ratings"
        }
        
        isLoading = false
    }
}
