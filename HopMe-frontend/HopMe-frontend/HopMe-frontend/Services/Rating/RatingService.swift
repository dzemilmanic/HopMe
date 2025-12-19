import Foundation

class RatingService {
    static let shared = RatingService()
    private init() {}
    
    private let api = APIService.shared
    
    func createRating(request: RatingRequest) async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .createRating,
            method: .post,
            body: request,
            requiresAuth: true
        )
    }
    
    func getUserRatings(userId: Int) async throws -> (ratings: [Rating], stats: RatingStats) {
        let response: UserRatingsResponse = try await api.request(
            endpoint: .userRatings(userId: userId),
            requiresAuth: true
        )
        return (response.ratings, response.stats)
    }
    
    func getMyRatings() async throws -> [Rating] {
        return try await api.request(
            endpoint: .myRatings,
            requiresAuth: true
        )
    }
}

struct UserRatingsResponse: Codable {
    let ratings: [Rating]
    let stats: RatingStats
}
