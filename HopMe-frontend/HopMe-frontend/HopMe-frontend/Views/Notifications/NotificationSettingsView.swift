import SwiftUI

struct NotificationSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("notifications_new_booking") private var newBooking = true
    @AppStorage("notifications_booking_accepted") private var bookingAccepted = true
    @AppStorage("notifications_booking_rejected") private var bookingRejected = true
    @AppStorage("notifications_booking_cancelled") private var bookingCancelled = true
    @AppStorage("notifications_ride_cancelled") private var rideCancelled = true
    @AppStorage("notifications_ride_completed") private var rideCompleted = true
    @AppStorage("notifications_new_rating") private var newRating = true
    @AppStorage("notifications_sound") private var soundEnabled = true
    @AppStorage("notifications_vibration") private var vibrationEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Tip notifikacija") {
                    Toggle("Nova rezervacija", isOn: $newBooking)
                    Toggle("Rezervacija prihvaćena", isOn: $bookingAccepted)
                    Toggle("Rezervacija odbijena", isOn: $bookingRejected)
                    Toggle("Rezervacija otkazana", isOn: $bookingCancelled)
                    Toggle("Vožnja otkazana", isOn: $rideCancelled)
                    Toggle("Vožnja završena", isOn: $rideCompleted)
                    Toggle("Nova ocena", isOn: $newRating)
                }
                
                Section("Zvuk i vibracija") {
                    Toggle("Zvuk", isOn: $soundEnabled)
                    Toggle("Vibracija", isOn: $vibrationEnabled)
                }
                
                Section {
                    Button("Obriši sve notifikacije") {
                        // TODO: Clear all notifications
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Podešavanja notifikacija")
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
struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
