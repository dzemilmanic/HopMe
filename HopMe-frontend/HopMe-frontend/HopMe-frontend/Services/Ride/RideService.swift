import Foundation

class RideService {
    static let shared = RideService()
    private init() {}
    
    private let api = APIService.shared
    
    func searchRides(
        from: String? = nil,
        to: String? = nil,
        date: Date? = nil,
        seats: Int = 1,
        page: Int = 1
    ) async throws -> [Ride] {
        
        let dateString = date?.formatted(.iso8601.year().month().day())
        
        let response: SearchRidesResponse = try await api.request(
            endpoint: .searchRides(
                from: from,
                to: to,
                date: dateString,
                seats: seats,
                page: page
            )
        )
        
        return response.rides
    }
    
    func getRideDetails(id: Int) async throws -> Ride {
        return try await api.request(endpoint: .ride(id: id))
    }
    
    func createRide(request: CreateRideRequest) async throws -> Ride {
        let response: CreateRideResponse = try await api.request(
            endpoint: .createRide,
            method: .post,
            body: request,
            requiresAuth: true
        )
        return response.ride
    }
    
    func getMyRides() async throws -> [Ride] {
        return try await api.request(
            endpoint: .myRides,
            requiresAuth: true
        )
    }
    
    func cancelRide(id: Int) async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .cancelRide(id: id),
            method: .post,
            requiresAuth: true
        )
    }
    
    func startRide(id: Int) async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .startRide(id: id),
            method: .post,
            requiresAuth: true
        )
    }
    
    func completeRide(id: Int) async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .completeRide(id: id),
            method: .post,
            requiresAuth: true
        )
    }
}

struct SearchRidesResponse: Codable {
    let rides: [Ride]
    let count: Int
    let page: Int
}

struct CreateRideResponse: Codable {
    let message: String
    let ride: Ride
}

struct EmptyResponse: Codable {
    let message: String?
}
