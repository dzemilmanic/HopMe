import Foundation
import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchFrom = ""
    @Published var searchTo = ""
    @Published var selectedDate = Date()
    @Published var passengers = 1
    
    @Published var searchResults: [Ride] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var filters = SearchFilters(
        maxPrice: nil,
        minRating: nil,
        autoAcceptOnly: false,
        allowSmoking: false,
        allowPets: false,
        luggageSize: nil,
        vehicleTypes: []
    )
    @Published var showFilters = false
    
    private let rideService = RideService.shared
    
    var canSearch: Bool {
        !searchFrom.isEmpty || !searchTo.isEmpty
    }
    
    func loadAllRides() async {
        isLoading = true
        errorMessage = nil
        
        do {
            searchResults = try await rideService.searchRides(
                from: nil,
                to: nil,
                date: nil,
                seats: 1
            )
            
            // Apply filters
            applyFilters()
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error loading rides"
        }
        
        isLoading = false
    }
    
    func search() async {
        guard canSearch else {
            // If no search criteria, load all rides
            await loadAllRides()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let from = searchFrom.isEmpty ? nil : searchFrom
            let to = searchTo.isEmpty ? nil : searchTo
            
            searchResults = try await rideService.searchRides(
                from: from,
                to: to,
                date: selectedDate,
                seats: passengers
            )
            
            // Apply filters
            applyFilters()
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error searching"
        }
        
        isLoading = false
    }
    
    func applyFilters() {
        var filtered = searchResults
        
        if let maxPrice = filters.maxPrice {
            filtered = filtered.filter { $0.pricePerSeat <= Double(maxPrice) }
        }
        
        if let minRating = filters.minRating {
            filtered = filtered.filter { $0.driver.averageRating >= Double(minRating) }
        }
        
        if filters.autoAcceptOnly {
            filtered = filtered.filter { $0.autoAcceptBookings }
        }
        
        if !filters.allowPets {
            filtered = filtered.filter { !$0.allowPets }
        }
        
        if !filters.allowSmoking {
            filtered = filtered.filter { !$0.allowSmoking }
        }
        
        searchResults = filtered
    }
    
    func clearFilters() {
        filters = SearchFilters()
    }
}

struct SearchFilters {
    var maxPrice: Int?
    var minRating: Int?
    var autoAcceptOnly = false
    var allowSmoking = false     // Use this
    var allowPets = false         // Use this
    var luggageSize: String?
    var vehicleTypes: Set<String> = []
}
