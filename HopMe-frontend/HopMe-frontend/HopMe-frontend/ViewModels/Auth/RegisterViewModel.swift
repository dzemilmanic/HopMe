import Foundation
import UIKit
import SwiftUI
import Combine

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phone = ""
    @Published var isDriver = false
    
    // Driver specific
    @Published var vehicleType = "Sedan"
    @Published var brand = ""
    @Published var model = ""
    @Published var year = ""
    @Published var color = ""
    @Published var licensePlate = ""
    @Published var vehicleImages: [UIImage] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    var isFormValid: Bool {
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword &&
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !phone.isEmpty &&
        (!isDriver || (!vehicleType.isEmpty && vehicleImages.count > 0))
    }
    
    var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    func register() async -> Bool {
        guard isFormValid else {
            errorMessage = "Popunite sva obavezna polja"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if isDriver {
                let imageData = vehicleImages.compactMap { $0.jpegData(compressionQuality: 0.7) }
                
                _ = try await AuthService.shared.registerDriver(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    phone: phone,
                    vehicleType: vehicleType,
                    brand: brand.isEmpty ? nil : brand,
                    model: model.isEmpty ? nil : model,
                    vehicleImages: imageData
                )
            } else {
                _ = try await AuthService.shared.registerPassenger(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    phone: phone
                )
            }
            
            successMessage = "Registracija uspešna! Proverite email."
            isLoading = false
            return true
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Greška pri registraciji"
            isLoading = false
            return false
        }
    }
    
    func addVehicleImage(_ image: UIImage) {
        if vehicleImages.count < 5 {
            vehicleImages.append(image)
        }
    }
    
    func removeVehicleImage(at index: Int) {
        vehicleImages.remove(at: index)
    }
}
