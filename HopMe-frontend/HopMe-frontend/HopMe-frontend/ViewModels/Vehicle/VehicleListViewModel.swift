import Foundation
import SwiftUI
import Combine

@MainActor
class VehicleListViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let vehicleService = VehicleService.shared
    
    func loadVehicles() async {
        isLoading = true
        errorMessage = nil
        
        do {
            vehicles = try await vehicleService.getMyVehicles()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error loading vehicles"
        }
        
        isLoading = false
    }
    
    func deleteVehicle(id: Int) async {
        do {
            try await vehicleService.deleteVehicle(id: id)
            vehicles.removeAll { $0.id == id }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error deleting vehicle"
        }
    }
}
