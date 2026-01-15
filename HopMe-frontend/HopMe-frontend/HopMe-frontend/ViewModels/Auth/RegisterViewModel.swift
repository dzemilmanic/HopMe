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
            errorMessage = "Populate all required fields"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if isDriver {
                print("🚗 Registering driver...")
                let imageData = vehicleImages.compactMap { $0.jpegData(compressionQuality: 0.7) }
                print("📸 Images count: \(imageData.count)")
                
                let response = try await AuthService.shared.registerDriver(
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
                
                print("✅ Driver registration successful: \(response.message)")
                
            } else {
                print("👤 Registering passenger...")
                
                let response = try await AuthService.shared.registerPassenger(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    phone: phone
                )
                
                print("✅ Passenger registration successful: \(response.message)")
            }
            
            successMessage = "Registration successful! Check your email."
            isLoading = false
            return true
            
        } catch let error as APIError {
            print("❌ APIError occurred: \(error)")
            print("❌ Error description: \(error.errorDescription ?? "No description")")
            errorMessage = error.errorDescription ?? "Error registering"
            isLoading = false
            return false
            
        } catch {
            print("❌ Unknown error occurred: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error localized: \(error.localizedDescription)")
            errorMessage = "Error registering: \(error.localizedDescription)"
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
