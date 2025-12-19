import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.blue,
                    Color.blue.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App Icon/Logo
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                
                // App Name
                VStack(spacing: 8) {
                    Text("HopMe")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Deli vožnju, uštedi novac")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
            }
            
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                opacity = 1.0
            }
        }
    }
}

#Preview("Splash View") {
    SplashView()
}
