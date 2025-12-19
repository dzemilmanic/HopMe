import CoreLocation

struct Coordinate: Codable {
    let lat: Double
    let lng: Double
    
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
