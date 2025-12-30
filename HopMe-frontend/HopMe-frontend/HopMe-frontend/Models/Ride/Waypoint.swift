import SwiftUI

struct Waypoint: Codable, Identifiable {
    let id: Int
    let rideId: Int
    let location: String
    let lat: Double?
    let lng: Double?
    let orderIndex: Int
    let estimatedTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, location, lat, lng, rideId, orderIndex, estimatedTime
    }
}
