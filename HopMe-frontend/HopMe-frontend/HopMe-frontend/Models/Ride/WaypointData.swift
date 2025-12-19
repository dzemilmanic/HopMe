import Foundation

// Data model for waypoint input (used in CreateRideViewModel)
struct WaypointData: Identifiable {
    let id = UUID()
    var location: String
    var estimatedTime: Date?
}
