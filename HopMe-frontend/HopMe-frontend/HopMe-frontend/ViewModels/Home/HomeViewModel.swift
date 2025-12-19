import Foundation

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
    
    @Published var testimonials = [
        (name: "Marko P.", text: "Odlična aplikacija! Uštedio sam puno novca.", rating: 5),
        (name: "Ana M.", text: "Sigurno i brzo. Preporučujem!", rating: 5),
        (name: "Stefan J.", text: "Upoznao sam divne ljude.", rating: 4),
    ]
}
