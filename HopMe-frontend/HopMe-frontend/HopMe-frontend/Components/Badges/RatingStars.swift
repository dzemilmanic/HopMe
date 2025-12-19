import SwiftUI

struct RatingStars: View {
    let rating: Double
    let maxRating: Int = 5
    let size: CGFloat = 16
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: starType(for: index))
                    .foregroundColor(.orange)
                    .font(.system(size: size))
            }
        }
    }
    
    private func starType(for index: Int) -> String {
        let value = rating - Double(index)
        if value >= 1.0 {
            return "star.fill"
        } else if value >= 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}
