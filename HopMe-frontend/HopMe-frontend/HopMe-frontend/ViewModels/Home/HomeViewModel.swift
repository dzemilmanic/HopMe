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
    
    private let testimonialService = TestimonialService.shared
    
    init() {
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        await loadTestimonials()
        // Other data loading logic...
    }
    
    func loadTestimonials() async {
        do {
            let items = try await testimonialService.getAllTestimonials()
            testimonials = items
        } catch {
            print("Error loading testimonials: \(error)")
        }
    }
}
