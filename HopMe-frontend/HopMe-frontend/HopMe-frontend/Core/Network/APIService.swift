import Foundation
import Combine

class APIService {
    static let shared = APIService()
    
    private let baseURL: String
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.baseURL = Environment.current.baseURL
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Generic Request
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        
        let url = URL(string: baseURL + endpoint.path)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization token
        if requiresAuth, let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        // Log request
        #if DEBUG
        print("🌐 Request: \(method.rawValue) \(endpoint.path)")
        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📦 Body: \(bodyString)")
        }
        #endif
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        #if DEBUG
        print("📥 Response: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📦 Data: \(responseString)")
        }
        #endif
        
        // Handle status codes
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
            
        case 401:
            TokenManager.shared.clearToken()
            throw APIError.unauthorized
            
        case 400...499:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.clientError(errorResponse.message)
            }
            throw APIError.badRequest
            
        case 500...599:
            throw APIError.serverError
            
        default:
            throw APIError.unknown
        }
    }
    
    // MARK: - Upload Image
    func uploadImage<T: Decodable>(
        endpoint: APIEndpoint,
        images: [Data],
        parameters: [String: Any] = [:],
        requiresAuth: Bool = true
    ) async throws -> T {
        
        let url = URL(string: baseURL + endpoint.path)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth, let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        
        // Add parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add images
        for (index, imageData) in images.enumerated() {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"vehicleImages\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        #if DEBUG
        print("📥 Upload Response: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📦 Data: \(responseString)")
        }
        #endif
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
            
        case 401:
            TokenManager.shared.clearToken()
            throw APIError.unauthorized
            
        case 400...499:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.clientError(errorResponse.message)
            }
            throw APIError.badRequest
            
        case 500...599:
            throw APIError.serverError
            
        default:
            throw APIError.uploadFailed
        }
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - API Error
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case badRequest
    case clientError(String)
    case serverError
    case uploadFailed
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Nevažeći URL"
        case .invalidResponse:
            return "Nevažeći odgovor servera"
        case .unauthorized:
            return "Niste autorizovani. Prijavite se ponovo."
        case .badRequest:
            return "Nevažeći zahtev"
        case .clientError(let message):
            return message
        case .serverError:
            return "Greška na serveru. Pokušajte ponovo."
        case .uploadFailed:
            return "Upload nije uspeo"
        case .decodingError:
            return "Greška pri parsiranju podataka"
        case .unknown:
            return "Nepoznata greška"
        }
    }
}

// MARK: - Error Response
struct ErrorResponse: Codable {
    let message: String
}
