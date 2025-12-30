import Foundation

class TestimonialService {
    static let shared = TestimonialService()
    private init() {}
    
    private let api = APIService.shared
    
    func getAllTestimonials() async throws -> [Testimonial] {
        let response: TestimonialResponse = try await api.request(
            endpoint: .testimonials
        )
        return response.testimonials ?? []
    }
    
    func createTestimonial(rating: Int, text: String) async throws -> Testimonial {
        let textData = ["rating": rating, "text": text] as [String : Any]
        
        let response: TestimonialResponse = try await api.request(
            endpoint: .testimonials,
            method: .post,
            body: textData,
            requiresAuth: true
        )
        
        if let testimonial = response.testimonial {
            return testimonial
        }
        
        throw APIError.decodingError
    }
    
    func getMyTestimonial() async throws -> Testimonial? {
        let response: TestimonialResponse = try await api.request(
            endpoint: .myTestimonial,
            requiresAuth: true
        )
        return response.testimonial
    }
    
    func deleteTestimonial(id: Int) async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .deleteTestimonial(id: id),
            method: .delete,
            requiresAuth: true
        )
    }
    
    func deleteMyTestimonial() async throws {
        let _: EmptyResponse = try await api.request(
            endpoint: .myTestimonial,
            method: .delete,
            requiresAuth: true
        )
    }
}
