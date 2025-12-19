import SwiftUI
import MapKit

struct RideMapView: View {
    @Environment(\.dismiss) var dismiss
    let ride: Ride
    
    @State private var region: MKCoordinateRegion
    @State private var annotations: [MapAnnotation] = []
    
    init(ride: Ride) {
        self.ride = ride
        
        // Initialize region with default values
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 44.0, longitude: 21.0),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map
                Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
                    MapMarker(coordinate: annotation.coordinate, tint: annotation.color)
                }
                .ignoresSafeArea()
                
                // Route Info Overlay
                VStack {
                    Spacer()
                    
                    routeInfoCard
                        .padding()
                }
            }
            .navigationTitle("Ruta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zatvori") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                setupMapAnnotations()
            }
        }
    }
    
    // MARK: - Route Info Card
    private var routeInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                        Text(ride.departureLocation)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text(ride.departureTime.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(ride.arrivalLocation)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                    }
                    
                    if let arrivalTime = ride.arrivalTime {
                        Text(arrivalTime.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Waypoints
            if let waypoints = ride.waypoints?.sorted(by: { $0.orderIndex < $1.orderIndex }), !waypoints.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Usputne stanice:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    ForEach(waypoints) { waypoint in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                            
                            Text(waypoint.location)
                                .font(.caption)
                            
                            if let time = waypoint.estimatedTime {
                                Spacer()
                                Text(time.formatted(time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Map Setup
    private func setupMapAnnotations() {
        var allAnnotations: [MapAnnotation] = []
        var coordinates: [CLLocationCoordinate2D] = []
        
        // Add departure location
        if let depLat = ride.departureLat, let depLng = ride.departureLng {
            let depCoord = CLLocationCoordinate2D(latitude: depLat, longitude: depLng)
            allAnnotations.append(MapAnnotation(
                id: "departure",
                coordinate: depCoord,
                title: ride.departureLocation,
                color: .green
            ))
            coordinates.append(depCoord)
        }
        
        // Add waypoints
        if let waypoints = ride.waypoints?.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            for waypoint in waypoints {
                if let lat = waypoint.lat, let lng = waypoint.lng {
                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    allAnnotations.append(MapAnnotation(
                        id: "waypoint-\(waypoint.id)",
                        coordinate: coord,
                        title: waypoint.location,
                        color: .blue
                    ))
                    coordinates.append(coord)
                }
            }
        }
        
        // Add arrival location
        if let arrLat = ride.arrivalLat, let arrLng = ride.arrivalLng {
            let arrCoord = CLLocationCoordinate2D(latitude: arrLat, longitude: arrLng)
            allAnnotations.append(MapAnnotation(
                id: "arrival",
                coordinate: arrCoord,
                title: ride.arrivalLocation,
                color: .red
            ))
            coordinates.append(arrCoord)
        }
        
        annotations = allAnnotations
        
        // Calculate region to fit all points
        if !coordinates.isEmpty {
            let region = calculateRegion(for: coordinates)
            self.region = region
        }
    }
    
    private func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 44.0, longitude: 21.0),
                span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
            )
        }
        
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude
        
        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - Map Annotation Model
struct MapAnnotation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let title: String
    let color: Color
}
