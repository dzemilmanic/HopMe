import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                if authViewModel.isAuthenticated {
                    MainTabView()
                        .transition(.opacity)
                } else {
                    NavigationView {
                        LoginView()
                    }
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            // Show splash for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}
#Preview("Content View") {
    ContentView()
        .environmentObject(AuthViewModel())
}
