import Foundation

class UserService {
    static let shared = UserService()
    private init() {}
    
    private let api = APIService.shared
    
    func getProfile() async throws -> UserProfile {
        return try await api.request(
            endpoint: .profile,
            requiresAuth: true
        )
    }
    
    func updateProfile(
        firstName: String,
        lastName: String,
        phone: String
    ) async throws -> User {
        
        let body: [String: String] = [
            "firstName": firstName,
            "lastName": lastName,
            "phone": phone
        ]
        
        let response: UpdateProfileResponse = try await api.request(
            endpoint: .updateProfile,
            method: .put,
            body: body,
            requiresAuth: true
        )
        
        return response.user
    }
    
    func changePassword(currentPassword: String, newPassword: String) async throws {
        struct ChangePasswordRequest: Encodable {
            let currentPassword: String
            let newPassword: String
        }
        
        let requestBody = ChangePasswordRequest(
            currentPassword: currentPassword,
            newPassword: newPassword
        )
        
        let _: EmptyResponse = try await api.request(
            endpoint: .changePassword,
            method: .post,
            body: requestBody,
            requiresAuth: true
        )
    }
}

struct UpdateProfileResponse: Codable {
    let message: String
    let user: User
}
