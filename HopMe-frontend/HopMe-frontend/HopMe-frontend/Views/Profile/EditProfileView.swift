import SwiftUI

struct EditProfileView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: EditProfileViewModel
    let onUpdate: () -> Void
    
    @State private var showSuccess = false
    
    init(user: User, onUpdate: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal data") {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        TextField("First name", text: $viewModel.firstName)
                    }
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        TextField("Last name", text: $viewModel.lastName)
                    }
                }
                
                Section("Contact") {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        TextField("Phone", text: $viewModel.phone)
                            .keyboardType(.phonePad)
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            let success = await viewModel.saveProfile()
                            if success {
                                showSuccess = true
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Save changes")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(viewModel.isFormValid ? Color.blue : Color.gray)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
            }
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Profile updated!", isPresented: $showSuccess) {
                Button("OK") {
                    onUpdate()
                    dismiss()
                }
            } message: {
                Text("Your profile has been successfully updated.")
            }
            .errorAlert(errorMessage: $viewModel.errorMessage)
        }
    }
}
#Preview("Edit Profile View") {
    // Mock user needed
    Text("Preview - Add mock user")
}
