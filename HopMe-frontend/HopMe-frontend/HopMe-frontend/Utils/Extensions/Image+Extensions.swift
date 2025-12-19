import SwiftUI

extension Image {
    func profileImageStyle(size: CGFloat = 50) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
    
    func vehicleImageStyle() -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .cornerRadius(12)
    }
}
