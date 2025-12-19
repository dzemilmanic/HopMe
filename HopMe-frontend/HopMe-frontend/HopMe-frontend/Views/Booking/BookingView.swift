import SwiftUI

struct BookingView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: BookingViewModel
    @State private var showSuccess = false
    
    init(ride: Ride) {
        _viewModel = StateObject(wrappedValue: BookingViewModel(ride: ride))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Ride Summary Card
                    rideSummaryCard
                    
                    // Seats Selection
                    seatsSection
                    
                    // Pickup & Dropoff (Optional)
                    locationsSection
                    
                    // Message (Optional)
                    messageSection
                    
                    // Price Breakdown
                    priceBreakdown
                    
                    // Booking Button
                    bookingButton
                }
                .padding()
            }
            .navigationTitle("Rezervacija")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Otkaži") {
                        dismiss()
                    }
                }
            }
            .loading(viewModel.isLoading)
            .errorAlert(errorMessage: $viewModel.errorMessage)
            .alert("Uspešno rezervisano!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                if viewModel.ride.autoAcceptBookings {
                    Text("Vaša rezervacija je automatski prihvaćena. Srećan put!")
                } else {
                    Text("Vaša rezervacija je poslata. Vozač će je uskoro razmotriti.")
                }
            }
        }
    }
    
    // MARK: - Ride Summary Card
    private var rideSummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.ride.departureLocation)
                        .font(.headline)
                    
                    Text(viewModel.ride.departureTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.ride.arrivalLocation)
                        .font(.headline)
                    
                    if let arrivalTime = viewModel.ride.arrivalTime {
                        Text(arrivalTime.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Divider()
            
            HStack(spacing: 12) {
                // Driver
                if let profileImage = viewModel.ride.driver.profileImage {
                    AsyncImage(url: URL(string: profileImage)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .overlay(
                                Text(viewModel.ride.driver.initials)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            )
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(viewModel.ride.driver.initials)
                                .font(.caption)
                                .foregroundColor(.blue)
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.ride.driver.fullName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        Text(viewModel.ride.driver.formattedRating)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Seats Section
    private var seatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Broj mesta")
                .font(.headline)
            
            HStack {
                ForEach(1...min(viewModel.ride.remainingSeats, 4), id: \.self) { count in
                    Button(action: {
                        viewModel.seatsBooked = count
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: count == 1 ? "person.fill" : "person.2.fill")
                                .font(.title3)
                            
                            Text("\(count)")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.seatsBooked == count ? Color.blue : Color(.systemGray6))
                        .foregroundColor(viewModel.seatsBooked == count ? .white : .primary)
                        .cornerRadius(12)
                    }
                }
            }
            
            Text("\(viewModel.ride.remainingSeats) mesta dostupno")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Locations Section
    private var locationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dodatne informacije (opciono)")
                .font(.headline)
            
            CustomTextField(
                icon: "mappin.circle.fill",
                placeholder: "Tačno mesto polaska",
                text: $viewModel.pickupLocation
            )
            
            CustomTextField(
                icon: "mappin.and.ellipse",
                placeholder: "Tačno mesto dolaska",
                text: $viewModel.dropoffLocation
            )
        }
    }
    
    // MARK: - Message Section
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Poruka vozaču (opciono)")
                .font(.headline)
            
            TextEditor(text: $viewModel.message)
                .frame(height: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Price Breakdown
    private var priceBreakdown: some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack {
                Text("\(viewModel.seatsBooked) x \(Int(viewModel.ride.pricePerSeat)) RSD")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("\(viewModel.totalPrice) RSD")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("Ukupno")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(viewModel.totalPrice) RSD")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Booking Button
    private var bookingButton: some View {
        CustomButton(
            title: "Potvrdi rezervaciju",
            action: {
                Task {
                    let success = await viewModel.createBooking()
                    if success {
                        showSuccess = true
                    }
                }
            },
            style: .primary,
            isLoading: viewModel.isLoading,
            disabled: !viewModel.canBook
        )
    }
}
#Preview("Booking View") {
    // You'll need to create a mock Ride object for preview
    Text("Preview - Add mock data")
}
