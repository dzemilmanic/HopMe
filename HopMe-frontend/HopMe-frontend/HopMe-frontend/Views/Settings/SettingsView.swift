import SwiftUI

struct SettingsView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @AppStorage("notifications_enabled") private var notificationsEnabled = true
    @AppStorage("email_notifications") private var emailNotifications = true
    @AppStorage("push_notifications") private var pushNotifications = true
    @AppStorage("booking_notifications") private var bookingNotifications = true
    @AppStorage("ride_notifications") private var rideNotifications = true
    @AppStorage("appearance_mode") private var appearanceMode: AppearanceMode = .system
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Enable notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        Toggle("Email notifications", isOn: $emailNotifications)
                        Toggle("Push notifications", isOn: $pushNotifications)
                        
                        Divider()
                        
                        Toggle("Bookings", isOn: $bookingNotifications)
                            .disabled(!notificationsEnabled)
                        
                        Toggle("Rides", isOn: $rideNotifications)
                            .disabled(!notificationsEnabled)
                    }
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            HStack {
                                Image(systemName: mode.icon)
                                Text(mode.displayName)
                            }
                            .tag(mode)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    // Visual preview
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: appearanceMode.previewIcon)
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                            Text(appearanceMode.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Constants.App.version)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Constants.App.build)
                            .foregroundColor(.gray)
                    }
                    
                    Button("Check for updates") {
                        // TODO: Check for updates
                    }
                }
                
                Section("Support") {
                    Button("Contact support") {
                        // TODO: Open email
                    }
                    
                    Button("Rate app") {
                        // TODO: Open App Store rating
                    }
                    
                    Button("Share app") {
                        // TODO: Share sheet
                    }
                }
                
                Section {
                    Button("Clear cache") {
                        // TODO: Clear cache
                    }
                    .foregroundColor(.orange)
                    
                    Button("Delete account") {
                        // TODO: Delete account
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
#Preview("Settings View") {
    SettingsView()
}
