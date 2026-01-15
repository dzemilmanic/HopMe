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
            .navigationTitle("Privacy and Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Data", isPresented: $showDeleteDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // TODO: Delete user data
                }
            } message: {
                Text("Are you sure you want to delete all your data? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Your privacy is important")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Control your data and how you share it with others")
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
            Text("Privacy Settings")
                .font(.headline)
            
            VStack(spacing: 0) {
                SettingToggleRow(
                    icon: "location.fill",
                    title: "Share location",
                    description: "Allow sharing location with drivers",
                    isOn: $locationSharing,
                    color: .blue
                )
                
                Divider()
                    .padding(.leading, 40)
                
                SettingToggleRow(
                    icon: "person.fill",
                    title: "Profile visibility",
                    description: "Make profile visible to other users",
                    isOn: $profileVisibility,
                    color: .green
                )
                
                Divider()
                    .padding(.leading, 40)
                
                SettingToggleRow(
                    icon: "phone.fill",
                    title: "Show phone number",
                    description: "Other users can see your phone number",
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
            Text("Security Settings")
                .font(.headline)
            
            VStack(spacing: 0) {
                SettingToggleRow(
                    icon: "faceid",
                    title: "Biometric authentication",
                    description: "Use Face ID/Touch ID for login",
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
                            Text("Change password")
                                .foregroundColor(.primary)
                            
                            Text("Update your password")
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
                            Text("Active sessions")
                                .foregroundColor(.primary)
                            
                            Text("Manage logins on devices")
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
            Text("Data Management")
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
                            Text("Export data")
                                .foregroundColor(.primary)
                            
                            Text("Download a copy of your data")
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
                            Text("Delete all data")
                                .foregroundColor(.red)
                            
                            Text("Permanently delete all your data")
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
                Text("Information")
                    .font(.headline)
            }
            
            Text("HopMe collects and uses your data only for the purpose of providing services. You can control which data you share and how we use it. For more information, please read our Privacy Policy.")
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
            Section("Current password") {
                SecureField("Enter current password", text: $currentPassword)
                    .textContentType(.password)
                    .autocapitalization(.none)
            }
            
            Section("New password") {
                SecureField("Enter new password", text: $newPassword)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
                
                SecureField("Confirm new password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
                
                if !newPassword.isEmpty {
                    if newPassword.count < 6 {
                        Text("Password must have at least 6 characters")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if !confirmPassword.isEmpty && newPassword != confirmPassword {
                    Text("Passwords do not match")
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
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                    }
                }
                .disabled(!isValid || isLoading)
            }
        }
        .navigationTitle("Change password")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Password changed successfully")
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
                errorMessage = "Current password is incorrect"
            case . badRequest:
                errorMessage = "Invalid data. Please check your input."
            default:
                errorMessage = "Error changing password. Please try again."
            }
        } catch {
            isLoading = false
            errorMessage = "Error changing password. Please try again."
        }
    }
}

struct ActiveSessionsView: View {
    var body: some View {
        List {
            Section("Current session") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("iPhone 15 Pro")
                            .fontWeight(.medium)
                        Text("Novi Pazar, Srbija")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("Now")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Section("Other sessions") {
                Text("No other active sessions")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Active sessions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Privacy & Security View") {
    PrivacySecurityView()
}
