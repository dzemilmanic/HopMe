import Foundation
import SwiftUI
import Combine

@MainActor
class CreateRideViewModel: ObservableObject {
    @Published var selectedVehicleId: Int?
    @Published var departureLocation = ""
    @Published var arrivalLocation = ""
    @Published var departureDate = Date()
    @Published var departureTime = Date()
    @Published var arrivalTime: Date?
    @Published var availableSeats = 3
    @Published var pricePerSeat = ""
    @Published var description = ""
    
    // Preferences
    @Published var autoAccept = false
    @Published var allowSmoking = false
    @Published var allowPets = false
    @Published var maxTwoInBack = false
    @Published var selectedLuggage = "Srednji"
    
    // Waypoints
    @Published var waypoints: [WaypointInput] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let rideService = RideService.shared
    
    var isFormValid: Bool {
        !departureLocation.isEmpty &&
        !arrivalLocation.isEmpty &&
        !pricePerSeat.isEmpty &&
        Double(pricePerSeat) != nil &&
        selectedVehicleId != nil
    }
    
    func createRide() async -> Bool {
        guard isFormValid else {
            errorMessage = "Popunite sva obavezna polja"
            return false
        }
        
        guard let price = Double(pricePerSeat),
              let vehicleId = selectedVehicleId else {
            errorMessage = "Nevažeći podaci"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        // Combine date and time
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: departureDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: departureTime)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        guard let combinedDateTime = calendar.date(from: dateComponents) else {
            errorMessage = "Nevažeći datum"
            isLoading = false
            return false
        }
        
        let request = CreateRideRequest(
            vehicleId: vehicleId,
            departureLocation: departureLocation,
            departureLat: nil,
            departureLng: nil,
            arrivalLocation: arrivalLocation,
            arrivalLat: nil,
            arrivalLng: nil,
            departureTime: combinedDateTime,
            arrivalTime: arrivalTime,
            availableSeats: availableSeats,
            pricePerSeat: price,
            description: description.isEmpty ? nil : description,
            autoAcceptBookings: autoAccept,
            allowSmoking: allowSmoking,
            allowPets: allowPets,
            maxTwoInBack: maxTwoInBack,
            luggageSize: selectedLuggage,
            waypoints: waypoints.isEmpty ? nil : waypoints.map {
                WaypointRequest(
                    location: $0.location,
                    lat: nil,
                    lng: nil,
                    estimatedTime: $0.estimatedTime
                )
            }
        )
        
        do {
            _ = try await rideService.createRide(request: request)
            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Greška pri kreiranju vožnje"
            isLoading = false
            return false
        }
    }
    
    func addWaypoint() {
        waypoints.append(WaypointInput(location: "", estimatedTime: nil))
    }
    
    func removeWaypoint(at index: Int) {
        waypoints.remove(at: index)
    }
}

struct WaypointInput: Identifiable {
    let id = UUID()
    var location: String
    var estimatedTime: Date?
}
