import Foundation

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    private let api = APIService.shared
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let request = LoginRequest(email: email, password: password)
        let response: LoginResponse = try await api.request(
            endpoint: .login,
            method: .post,
            body: request
        )
        
        // Save token
        TokenManager.shared.saveToken(response.token)
        
        return response
    }
    
    func registerPassenger(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        phone: String
    ) async throws -> [String: Any] {
        
        let request = RegisterRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            vehicleType: nil,
            brand: nil,
            model: nil
        )
        
        return try await api.request(
            endpoint: .registerPassenger,
            method: .post,
            body: request
        )
    }
    
    func registerDriver(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        phone: String,
        vehicleType: String,
        brand: String?,
        model: String?,
        vehicleImages: [Data]
    ) async throws -> [String: Any] {
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName,
            "phone": phone,
            "vehicleType": vehicleType,
            "brand": brand ?? "",
            "model": model ?? ""
        ]
        
        return try await api.uploadImage(
            endpoint: .registerDriver,
            images: vehicleImages,
            parameters: parameters,
            requiresAuth: false
        )
    }
    
    func logout() {
        TokenManager.shared.clearToken()
    }
    
    var isAuthenticated: Bool {
        TokenManager.shared.getToken() != nil
    }
}
