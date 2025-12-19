import Foundation
import SwiftUI
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
            errorMessage = "Unesite validne podatke"
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
            errorMessage = "Greška pri prijavi"
            isLoading = false
            return false
        }
    }
}
