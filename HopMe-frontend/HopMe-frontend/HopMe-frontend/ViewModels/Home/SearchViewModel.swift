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
    
    @Published var filters = SearchFilters()
    @Published var showFilters = false
    
    private let rideService = RideService.shared
    
    var canSearch: Bool {
        !searchFrom.isEmpty && !searchTo.isEmpty
    }
    
    func search() async {
        guard canSearch else {
            errorMessage = "Unesite polazište i destinaciju"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            searchResults = try await rideService.searchRides(
                from: searchFrom,
                to: searchTo,
                date: selectedDate,
                seats: passengers
            )
            
            // Apply filters
            applyFilters()
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Greška pri pretrazi"
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
        
        if filters.allowPetsOnly {
            filtered = filtered.filter { $0.allowPets }
        }
        
        if filters.noSmokingOnly {
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
    var allowPetsOnly = false
    var noSmokingOnly = false
    var vehicleTypes: Set<String> = []
}
