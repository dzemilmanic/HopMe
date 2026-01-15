import Foundation
import UIKit
import SwiftUI
import Combine

@MainActor
class AddVehicleViewModel: ObservableObject {
    @Published var vehicleType = "Sedan"
    @Published var brand = ""
    @Published var model = ""
    @Published var year = ""
    @Published var color = ""
    @Published var licensePlate = ""
    @Published var images: [UIImage] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let vehicleService = VehicleService.shared
    
    let vehicleTypes = ["Sedan", "SUV", "Hatchbak", "Pickup", "Minivan"]
    
    var isFormValid: Bool {
        !vehicleType.isEmpty && images.count > 0
    }
    
    func addVehicle() async -> Bool {
        guard isFormValid else {
            errorMessage = "Select vehicle type and add images"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        let imageData = images.compactMap { $0.jpegData(compressionQuality: 0.7) }
        
        do {
            _ = try await vehicleService.addVehicle(
                vehicleType: vehicleType,
                brand: brand.isEmpty ? nil : brand,
                model: model.isEmpty ? nil : model,
                year: Int(year),
                color: color.isEmpty ? nil : color,
                licensePlate: licensePlate.isEmpty ? nil : licensePlate,
                images: imageData
            )
            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Error adding vehicle"
            isLoading = false
            return false
        }
    }
    
    func addImage(_ image: UIImage) {
        if images.count < 5 {
            images.append(image)
        }
    }
    func removeImage(at index: Int) {
        images.remove(at: index)
    }
}
