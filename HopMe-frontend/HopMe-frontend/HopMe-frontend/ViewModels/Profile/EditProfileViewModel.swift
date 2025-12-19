import Foundation
import SwiftUI
import Combine

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var phone: String
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userService = UserService.shared
    
    init(user: User) {
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.phone = user.phone
    }
    
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !phone.isEmpty
    }
    
    func saveProfile() async -> Bool {
        guard isFormValid else {
            errorMessage = "Popunite sva polja"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await userService.updateProfile(
                firstName: firstName,
                lastName: lastName,
                phone: phone
            )
            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Greška pri čuvanju"
            isLoading = false
            return false
        }
    }
}
