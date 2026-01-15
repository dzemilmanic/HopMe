import SwiftUI

struct RideInfo: Codable {
    let id: Int
    let departureLocation: String
    let arrivalLocation: String
    let departureTime: Date
    let status: String
    let driver: DriverInfo
    let vehicle: VehicleInfo?
    
    enum CodingKeys: String, CodingKey {
        case id, status, driver, vehicle
        case departureLocation = "departureLocation"
        case arrivalLocation = "arrivalLocation"
        case departureTime = "departureTime"
    }
}

struct DriverInfo: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let phone: String
    let profileImage: String?
    let averageRating: Double
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let first = String(firstName.prefix(1))
        let last = String(lastName.prefix(1))
        return "\(first)\(last)".uppercased()
    }
}

struct VehicleInfo: Codable {
    let type: String
    let brand: String?
    let model: String?
    let color: String?
    
    var displayName: String {
        if let brand = brand, let model = model {
            return "\(brand) \(model)"
        }
        return type
    }
}
