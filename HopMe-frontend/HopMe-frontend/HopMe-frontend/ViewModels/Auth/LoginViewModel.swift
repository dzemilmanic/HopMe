import Foundation
import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var isFormValid: Bool {
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }
    
    func login() async -> Bool {
        guard isFormValid else {
            errorMessage = "Invalid data"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await AuthService.shared.login(email: email, password: password)
            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Error logging in"
            isLoading = false
            return false
        }
    }
}
