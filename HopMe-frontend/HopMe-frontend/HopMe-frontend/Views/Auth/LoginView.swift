import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = LoginViewModel()
    @State private var showRegister = false
    @State private var showForgotPassword = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.blue)
                        .padding(.top, 60)
                    
                    Text("Dobrodošli u HopMe")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("Prijavite se na svoj nalog")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
                
                // Login Form
                VStack(spacing: 16) {
                    CustomTextField(
                        icon: "envelope.fill",
                        placeholder: "Email adresa",
                        text: $viewModel.email,
                        keyboardType: .emailAddress
                    )
                    
                    CustomTextField(
                        icon: "lock.fill",
                        placeholder: "Lozinka",
                        text: $viewModel.password,
                        isSecure: true
                    )
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        Button(action: { showForgotPassword = true }) {
                            Text("Zaboravili ste lozinku?")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, -8)
                }
                .padding(.horizontal)
                
                // Login Button
                CustomButton(
                    title: "Prijavi se",
                    action: {
                        Task {
                            let success = await viewModel.login()
                            if success {
                                await authViewModel.checkAuthenticationStatus()
                            }
                        }
                    },
                    style: .primary,
                    isLoading: viewModel.isLoading,
                    disabled: !viewModel.isFormValid
                )
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    
                    Text("ili")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Register Button
                Button(action: { showRegister = true }) {
                    HStack {
                        Text("Nemate nalog?")
                            .foregroundColor(.gray)
                        Text("Registrujte se")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .errorAlert(errorMessage: $viewModel.errorMessage)
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}
#Preview("Login View") {
    NavigationView {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
