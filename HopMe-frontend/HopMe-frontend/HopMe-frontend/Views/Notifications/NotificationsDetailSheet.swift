import SwiftUI

struct NotificationDetailSheet: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    let notification: NotificationModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Icon Header
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color(notification.type.color).opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: notification.type.icon)
                                .font(.system(size: 40))
                                .foregroundColor(Color(notification.type.color))
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    // Title
                    Text(notification.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    // Message
                    Text(notification.message)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    // Metadata
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            Text(notification.createdAt.formatted(date: .long, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: notification.type.icon)
                                .foregroundColor(.gray)
                            Text(notification.type.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Additional Data (if any)
                    if let data = notification.data, !data.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dodatne informacije")
                                .font(.headline)
                            
                            ForEach(Array(data.keys.sorted()), id: \.self) { key in
                                HStack {
                                    Text(key.capitalized)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Text(data[key] ?? "")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Action Buttons
                    if let rideId = notification.data?["rideId"] {
                        Button(action: {
                            // TODO: Navigate to ride
                            dismiss()
                        }) {
                            Text("Prikaži vožnju")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    
                    if let bookingId = notification.data?["bookingId"] {
                        Button(action: {
                            // TODO: Navigate to booking
                            dismiss()
                        }) {
                            Text("Prikaži rezervaciju")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Detalji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zatvori") {
                        dismiss()
                    }
                }
            }
        }
    }
}
