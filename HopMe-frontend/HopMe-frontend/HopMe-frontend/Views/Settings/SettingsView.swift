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
                Section("Notifikacije") {
                    Toggle("Omogući notifikacije", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        Toggle("Email notifikacije", isOn: $emailNotifications)
                        Toggle("Push notifikacije", isOn: $pushNotifications)
                        
                        Divider()
                        
                        Toggle("Rezervacije", isOn: $bookingNotifications)
                            .disabled(!notificationsEnabled)
                        
                        Toggle("Vožnje", isOn: $rideNotifications)
                            .disabled(!notificationsEnabled)
                    }
                }
                
                Section("Izgled") {
                    Picker("Tema", selection: $appearanceMode) {
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
                
                Section("O aplikaciji") {
                    HStack {
                        Text("Verzija")
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
                    
                    Button("Proveri ažuriranja") {
                        // TODO: Check for updates
                    }
                }
                
                Section("Podrška") {
                    Button("Kontaktiraj podršku") {
                        // TODO: Open email
                    }
                    
                    Button("Oceni aplikaciju") {
                        // TODO: Open App Store rating
                    }
                    
                    Button("Deli aplikaciju") {
                        // TODO: Share sheet
                    }
                }
                
                Section {
                    Button("Obriši keš") {
                        // TODO: Clear cache
                    }
                    .foregroundColor(.orange)
                    
                    Button("Obriši nalog") {
                        // TODO: Delete account
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Podešavanja")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Gotovo") {
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
