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
        
        let result = try await api.uploadImage(
            endpoint: .vehicles,
            images: images,
            parameters: parameters,
            requiresAuth: true
        )
        
        // Parse vehicle from result
        let data = try JSONSerialization.data(withJSONObject: result["vehicle"] ?? [:])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Vehicle.self, from: data)
    }
    
    func deleteVehicle(id: Int) async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .vehicle(id: id),
            method: .delete,
            requiresAuth: true
        )
    }
}
