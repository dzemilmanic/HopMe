import Foundation
import UIKit
import SwiftUI
import Combine

@MainActor
class EditVehicleViewModel: ObservableObject {
    private let vehicleId: Int
    
    @Published var vehicleType: String
    @Published var brand: String
    @Published var model: String
    @Published var year: String
    @Published var color: String
    @Published var licensePlate: String
    
    // Slike
    @Published var existingImages: [VehicleImage] = []
    @Published var newImages: [UIImage] = []
    
    // Za brisanje
    private var imagesToDelete: [Int] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let vehicleService = VehicleService.shared
    
    let vehicleTypes = ["Sedan", "SUV", "Hečbek", "Karavan", "Kombi", "Minivan"]
    
    var isFormValid: Bool {
        !vehicleType.isEmpty && (existingImages.count + newImages.count) > 0
    }
    
    init(vehicle: Vehicle) {
        self.vehicleId = vehicle.id
        self.vehicleType = vehicle.vehicleType
        self.brand = vehicle.brand ?? ""
        self.model = vehicle.model ?? ""
        self.year = vehicle.year != nil ? String(vehicle.year!) : ""
        self.color = vehicle.color ?? ""
        self.licensePlate = vehicle.licensePlate ?? ""
        self.existingImages = vehicle.images ?? []
    }
    
    func saveChanges() async -> Bool {
        guard isFormValid else {
            errorMessage = "Vozilo mora imati tip i bar jednu sliku"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Ažuriraj tekstualne podatke
            _ = try await vehicleService.updateVehicle(
                id: vehicleId,
                vehicleType: vehicleType,
                brand: brand.isEmpty ? nil : brand,
                model: model.isEmpty ? nil : model,
                year: Int(year),
                color: color.isEmpty ? nil : color,
                licensePlate: licensePlate.isEmpty ? nil : licensePlate
            )
            
            // 2. Obriši slike koje su uklonjene
            for imageId in imagesToDelete {
                try await vehicleService.deleteVehicleImage(vehicleId: vehicleId, imageId: imageId)
            }
            
            // 3. Dodaj nove slike
            if !newImages.isEmpty {
                let imageData = newImages.compactMap { $0.jpegData(compressionQuality: 0.7) }
                if !imageData.isEmpty {
                    _ = try await vehicleService.addVehicleImages(vehicleId: vehicleId, images: imageData)
                }
            }
            
            isLoading = false
            return true
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Greška pri ažuriranju vozila"
            isLoading = false
            return false
        }
    }
    
    func addNewImage(_ image: UIImage) {
        if (existingImages.count + newImages.count) < 5 {
            newImages.append(image)
        }
    }
    
    func removeNewImage(at index: Int) {
        newImages.remove(at: index)
    }
    
    func removeExistingImage(at index: Int) {
        let image = existingImages[index]
        existingImages.remove(at: index)
        imagesToDelete.append(image.id)
    }
}
