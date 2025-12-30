import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var popularRoutes: [(from: String, to: String, price: Int)] = [
        ("Beograd", "Novi Sad", 500),
        ("Beograd", "Niš", 800),
        ("Novi Sad", "Subotica", 400),
        ("Beograd", "Kragujevac", 600),
        ("Niš", "Leskovac", 300),
    ]
    
    @Published var stats = (
        users: "15,000+",
        rides: "50,000+",
        rating: "4.8★"
    )
    
    @Published var testimonials: [Testimonial] = []
    @Published var userHasTestimonial: Bool = false
    
    private let testimonialService = TestimonialService.shared
    
    init() {
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        await loadTestimonials()
        await checkUserTestimonial()
    }
    
    func loadTestimonials() async {
        do {
            let items = try await testimonialService.getAllTestimonials()
            print("✅ Successfully loaded \(items.count) testimonials")
            testimonials = items
        } catch let error as DecodingError {
            print("❌ Decoding error loading testimonials: \(error)")
            switch error {
            case .keyNotFound(let key, let context):
                print("Missing key: \(key.stringValue), context: \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                print("Type mismatch for type: \(type), context: \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("Value not found for type: \(type), context: \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("Unknown decoding error")
            }
        } catch {
            print("❌ Error loading testimonials: \(error)")
        }
    }
    
    func checkUserTestimonial() async {
        do {
            let myTestimonial = try await testimonialService.getMyTestimonial()
            userHasTestimonial = myTestimonial != nil
        } catch {
            // User doesn't have testimonial or not authenticated
            userHasTestimonial = false
        }
    }
}
