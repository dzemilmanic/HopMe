import SwiftUI

extension View {
    // MARK: - Card Modifier
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Loading Overlay
    func loading(_ isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        }
    }
    
    // MARK: - Error Alert
    func errorAlert(errorMessage: Binding<String?>) -> some View {
        self.alert("Error", isPresented: .constant(errorMessage.wrappedValue != nil)) {
            Button("OK") {
                errorMessage.wrappedValue = nil
            }
        } message: {
            Text(errorMessage.wrappedValue ?? "")
        }
    }
    
    // MARK: - Hide Keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Conditional Modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    // MARK: - Corner Radius (Specific Corners)
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    // MARK: - Shimmer Effect
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// Custom Shape for specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
