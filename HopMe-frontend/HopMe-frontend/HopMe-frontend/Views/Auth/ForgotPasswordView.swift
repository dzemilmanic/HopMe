import SwiftUI

struct ForgotPasswordView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 40)
                    
                    // Header
                    VStack(spacing: 8) {
                        Text("Forgot your password?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Enter your email and we'll send you a link to reset your password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Email Field
                    CustomTextField(
                        icon: "envelope.fill",
                        placeholder: "Email address",
                        text: $email,
                        keyboardType: .emailAddress
                    )
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Submit Button
                    CustomButton(
                        title: "Send link",
                        action: {
                            Task {
                                await sendResetLink()
                            }
                        },
                        style: .primary,
                        isLoading: isLoading,
                        disabled: email.isEmpty || !email.contains("@")
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Reset password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .errorAlert(errorMessage: $errorMessage)
            .alert("Email sent!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Check your email for further instructions.")
            }
        }
    }
    
    private func sendResetLink() async {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement password reset API call
        // For now, simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        isLoading = false
        showSuccess = true
    }
}
#Preview("Forgot Password View") {
    ForgotPasswordView()
}
