struct Route: Codable {
    let distance: String
    let distanceMeters: Int
    let duration: String
    let durationSeconds: Int
    let geometry: RouteGeometry
    let steps: [RouteStep]?
}

struct RouteGeometry: Codable {
    let coordinates: [[Double]]
    let type: String
}

struct RouteStep: Codable {
    let instruction: String
    let distance: Double
    let duration: Double
    let name: String?
}
