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
                    
                    Text("Welcome to HopMe")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("Login to your account")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
                
                // Login Form
                VStack(spacing: 16) {
                    CustomTextField(
                        icon: "envelope.fill",
                        placeholder: "Email address",
                        text: $viewModel.email,
                        keyboardType: .emailAddress
                    )
                    
                    CustomTextField(
                        icon: "lock.fill",
                        placeholder: "Password",
                        text: $viewModel.password,
                        isSecure: true
                    )
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        Button(action: { showForgotPassword = true }) {
                            Text("Forgot your password?")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, -8)
                }
                .padding(.horizontal)
                
                // Login Button
                CustomButton(
                    title: "Login",
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
                    
                    Text("or")
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
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Text("Register")
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
