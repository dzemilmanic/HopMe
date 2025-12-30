import SwiftUI

struct PrivacySecurityView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @AppStorage("location_sharing") private var locationSharing = true
    @AppStorage("profile_visibility") private var profileVisibility = true
    @AppStorage("phone_visibility") private var phoneVisibility = false
    @AppStorage("biometric_auth") private var biometricAuth = false
    @State private var showDeleteDataAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Privacy Settings
                    privacySettingsSection
                    
                    // Security Settings
                    securitySettingsSection
                    
                    // Data Management
                    dataManagementSection
                    
                    // Information
                    informationSection
                }
                .padding()
            }
            .navigationTitle("Privatnost i bezbednost")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Gotovo") {
                        dismiss()
                    }
                }
            }
            .alert("Brisanje podataka", isPresented: $showDeleteDataAlert) {
                Button("Otkaži", role: .cancel) { }
                Button("Obriši", role: .destructive) {
                    // TODO: Delete user data
                }
            } message: {
                Text("Da li ste sigurni da želite da obrišete sve svoje podatke? Ova radnja se ne može poništiti.")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Vaša privatnost je važna")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Kontrolišite svoje podatke i kako ih delite sa drugima")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Privacy Settings
    private var privacySettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Podešavanja privatnosti")
                .font(.headline)
            
            VStack(spacing: 0) {
                SettingToggleRow(
                    icon: "location.fill",
                    title: "Deljenje lokacije",
                    description: "Dozvoli deljenje lokacije sa vozačima",
                    isOn: $locationSharing,
                    color: .blue
                )
                
                Divider()
                    .padding(.leading, 40)
                
                SettingToggleRow(
                    icon: "person.fill",
                    title: "Vidljivost profila",
                    description: "Učini profil vidljivim drugim korisnicima",
                    isOn: $profileVisibility,
                    color: .green
                )
                
                Divider()
                    .padding(.leading, 40)
                
                SettingToggleRow(
                    icon: "phone.fill",
                    title: "Prikaži broj telefona",
                    description: "Drugi korisnici mogu videti vaš broj",
                    isOn: $phoneVisibility,
                    color: .orange
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Security Settings
    private var securitySettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Podešavanja bezbednosti")
                .font(.headline)
            
            VStack(spacing: 0) {
                SettingToggleRow(
                    icon: "faceid",
                    title: "Biometrijska autentifikacija",
                    description: "Koristi Face ID/Touch ID za prijavu",
                    isOn: $biometricAuth,
                    color: .purple
                )
                
                Divider()
                    .padding(.leading, 40)
                
                NavigationLink(destination: ChangePasswordView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Promena lozinke")
                                .foregroundColor(.primary)
                            
                            Text("Ažuriraj svoju lozinku")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding()
                }
                
                Divider()
                    .padding(.leading, 40)
                
                NavigationLink(destination: ActiveSessionsView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "laptopcomputer.and.iphone")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Aktivne sesije")
                                .foregroundColor(.primary)
                            
                            Text("Upravljaj prijavama na uređajima")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding()
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Data Management
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upravljanje podacima")
                .font(.headline)
            
            VStack(spacing: 0) {
                Button(action: {
                    // TODO: Export data
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.down.doc.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Preuzmi svoje podatke")
                                .foregroundColor(.primary)
                            
                            Text("Preuzmi kopiju svojih podataka")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding()
                }
                
                Divider()
                    .padding(.leading, 40)
                
                Button(action: {
                    showDeleteDataAlert = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Obriši sve podatke")
                                .foregroundColor(.red)
                            
                            Text("Trajno obriši sve svoje podatke")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding()
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Information Section
    private var informationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Informacije")
                    .font(.headline)
            }
            
            Text("HopMe prikuplja i koristi vaše podatke samo u svrhu pružanja usluga. Možete kontrolisati koje podatke delite i kako ih koristimo. Za više informacija, pogledajte našu Politiku privatnosti.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct SettingToggleRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
    }
}

// MARK: - Placeholder Views (To be implemented)

struct ChangePasswordView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    
    var body: some View {
        Form {
            Section("Trenutna lozinka") {
                SecureField("Unesite trenutnu lozinku", text: $currentPassword)
                    .textContentType(.password)
                    .autocapitalization(.none)
            }
            
            Section("Nova lozinka") {
                SecureField("Unesite novu lozinku", text: $newPassword)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
                
                SecureField("Potvrdite novu lozinku", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
                
                if !newPassword.isEmpty {
                    if newPassword.count < 6 {
                        Text("Lozinka mora imati najmanje 6 karaktera")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if !confirmPassword.isEmpty && newPassword != confirmPassword {
                    Text("Lozinke se ne podudaraju")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            if let errorMessage = errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.callout)
                }
            }
            
            Section {
                Button(action: {
                    Task {
                        await changePassword()
                    }
                }) {
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Sačuvaj")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                    }
                }
                .disabled(!isValid || isLoading)
            }
        }
        .navigationTitle("Promena lozinke")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Uspeh", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Lozinka je uspešno promenjena")
        }
    }
    
    private var isValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword
    }
    
    private func changePassword() async {
        errorMessage = nil
        isLoading = true
        
        do {
            try await UserService.shared.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            
            isLoading = false
            showSuccessAlert = true
        } catch let error as APIError {
            isLoading = false
            switch error {
            case .unauthorized:
                errorMessage = "Trenutna lozinka nije tačna"
            case . badRequest:
                errorMessage = "Nevalidni podaci. Proverite unos."
            default:
                errorMessage = "Greška pri promeni lozinke. Pokušajte ponovo."
            }
        } catch {
            isLoading = false
            errorMessage = "Greška pri promeni lozinke. Pokušajte ponovo."
        }
    }
}

struct ActiveSessionsView: View {
    var body: some View {
        List {
            Section("Trenutna sesija") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("iPhone 15 Pro")
                            .fontWeight(.medium)
                        Text("Novi Pazar, Srbija")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("Sada")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Section("Ostale sesije") {
                Text("Nema drugih aktivnih sesija")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Aktivne sesije")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Privacy & Security View") {
    PrivacySecurityView()
}
