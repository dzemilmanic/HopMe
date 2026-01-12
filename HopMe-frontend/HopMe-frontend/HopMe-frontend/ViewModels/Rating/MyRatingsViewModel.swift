import Foundation
import SwiftUI
import Combine

@MainActor
class MyRatingsViewModel: ObservableObject {
    @Published var receivedRatings: [Rating] = []
    @Published var givenRatings: [Rating] = []
    @Published var stats: MyRatingsStats?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let ratingService = RatingService.shared
    
    func loadRatings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await ratingService.getAllMyRatings()
            receivedRatings = response.receivedRatings
            givenRatings = response.givenRatings
            stats = response.stats
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Greška pri učitavanju ocena"
        }
        
        isLoading = false
    }
    
    func refreshRatings() async {
        await loadRatings()
    }
}
