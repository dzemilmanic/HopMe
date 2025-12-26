import Foundation

class VehicleService {
    static let shared = VehicleService()
    private init() {}
    
    private let api = APIService.shared
    
    func getMyVehicles() async throws -> [Vehicle] {
        return try await api.request(
            endpoint: .vehicles,
            requiresAuth: true
        )
    }
    
    func addVehicle(
        vehicleType: String,
        brand: String?,
        model: String?,
        year: Int?,
        color: String?,
        licensePlate: String?,
        images: [Data]
    ) async throws -> Vehicle {
        
        let parameters: [String: Any] = [
            "vehicleType": vehicleType,
            "brand": brand ?? "",
            "model": model ?? "",
            "year": year ?? 0,
            "color": color ?? "",
            "licensePlate": licensePlate ?? ""
        ]
        
        // Eksplicitno specifikuj tip koji očekuješ
        let response: VehicleResponse = try await api.uploadImage(
            endpoint: .vehicles,
            images: images,
            parameters: parameters,
            requiresAuth: true
        )
        
        return response.vehicle
    }
    
    func deleteVehicle(id: Int) async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .vehicle(id: id),
            method: .delete,
            requiresAuth: true
        )
    }
}
