import CoreLocation

struct Location: Codable {
    let name: String
    let lat: Double
    let lng: Double
    let address: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
