import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userService = UserService.shared
    
    var user: User? {
        profile?.user
    }
    
    var vehicles: [Vehicle] {
        profile?.vehicles ?? []
    }
    
    var stats: UserStats? {
        profile?.stats
    }
    
    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await userService.getProfile()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error loading profile"
        }
        
        isLoading = false
    }
    
    func refreshProfile() async {
        await loadProfile()
    }
}
