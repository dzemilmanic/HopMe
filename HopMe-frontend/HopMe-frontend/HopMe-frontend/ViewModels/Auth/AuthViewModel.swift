import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        isAuthenticated = authService.isAuthenticated
        if isAuthenticated {
            loadCurrentUser()
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.login(email: email, password: password)
            currentUser = response.user
            isAuthenticated = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error logging in. Please try again."
        }
        
        isLoading = false
    }
    
    func logout() {
        authService.logout()
        currentUser = nil
        isAuthenticated = false
    }
    
    private func loadCurrentUser() {
        Task {
            do {
                let profile = try await UserService.shared.getProfile()
                currentUser = profile.user
            } catch {
                // Token expired, logout
                logout()
            }
        }
    }
}
