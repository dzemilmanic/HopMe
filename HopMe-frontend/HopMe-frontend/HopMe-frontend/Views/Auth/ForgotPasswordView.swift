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
                        Text("Zaboravili ste lozinku?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Unesite svoj email i poslaćemo Vam link za resetovanje lozinke")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Email Field
                    CustomTextField(
                        icon: "envelope.fill",
                        placeholder: "Email adresa",
                        text: $email,
                        keyboardType: .emailAddress
                    )
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Submit Button
                    CustomButton(
                        title: "Pošalji link",
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
            .navigationTitle("Resetovanje lozinke")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zatvori") {
                        dismiss()
                    }
                }
            }
            .errorAlert(errorMessage: $errorMessage)
            .alert("Email poslat!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Proverite svoj email za daljna uputstva.")
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
