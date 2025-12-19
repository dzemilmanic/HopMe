import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
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
                Section("Lični podaci") {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        TextField("Ime", text: $viewModel.firstName)
                    }
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        TextField("Prezime", text: $viewModel.lastName)
                    }
                }
                
                Section("Kontakt") {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        TextField("Telefon", text: $viewModel.phone)
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
                            Text("Sačuvaj izmene")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(viewModel.isFormValid ? Color.blue : Color.gray)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
            }
            .navigationTitle("Izmeni profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Otkaži") {
                        dismiss()
                    }
                }
            }
            .alert("Profil ažuriran!", isPresented: $showSuccess) {
                Button("OK") {
                    onUpdate()
                    dismiss()
                }
            } message: {
                Text("Vaš profil je uspešno ažuriran.")
            }
            .errorAlert(errorMessage: $viewModel.errorMessage)
        }
    }
}
#Preview("Edit Profile View") {
    // Mock user needed
    Text("Preview - Add mock user")
}
