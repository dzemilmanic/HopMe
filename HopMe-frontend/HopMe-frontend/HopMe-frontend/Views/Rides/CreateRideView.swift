import SwiftUI

struct CreateRideView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CreateRideViewModel()
    @StateObject private var vehicleViewModel = VehicleListViewModel()
    @State private var currentStep = 1
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Indicator
                ProgressSteps(currentStep: currentStep, totalSteps: 4)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Step Content
                        switch currentStep {
                        case 1:
                            basicInfoStep
                        case 2:
                            dateTimeStep
                        case 3:
                            preferencesStep
                        case 4:
                            waypointsStep
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
                
                // Navigation Buttons
                navigationButtons
            }
            .navigationTitle("Nova vožnja")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Otkaži") {
                        dismiss()
                    }
                }
            }
            .task {
                await vehicleViewModel.loadVehicles()
            }
            .errorAlert(errorMessage: $viewModel.errorMessage)
            .alert("Vožnja kreirana!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Vaša vožnja je uspešno objavljena.")
            }
        }
    }
    
    // MARK: - Step 1: Basic Info
    private var basicInfoStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Osnovne informacije")
                .font(.title2)
                .fontWeight(.bold)
            
            // Vehicle Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Vozilo *")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if vehicleViewModel.vehicles.isEmpty {
                    Button(action: {
                        // TODO: Navigate to add vehicle
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Dodajte vozilo")
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                } else {
                    Menu {
                        ForEach(vehicleViewModel.vehicles) { vehicle in
                            Button(action: {
                                viewModel.selectedVehicleId = vehicle.id
                            }) {
                                HStack {
                                    Text(vehicle.displayName)
                                    if viewModel.selectedVehicleId == vehicle.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                            
                            if let selectedId = viewModel.selectedVehicleId,
                               let vehicle = vehicleViewModel.vehicles.first(where: { $0.id == selectedId }) {
                                Text(vehicle.displayName)
                            } else {
                                Text("Izaberite vozilo")
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
            }
            
            // Departure Location
            CustomTextField(
                icon: "location.circle.fill",
                placeholder: "Polazište *",
                text: $viewModel.departureLocation
            )
            
            // Arrival Location
            CustomTextField(
                icon: "location.fill",
                placeholder: "Destinacija *",
                text: $viewModel.arrivalLocation
            )
            
            // Available Seats
            VStack(alignment: .leading, spacing: 8) {
                Text("Broj slobodnih mesta *")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    ForEach(1...4, id: \.self) { count in
                        Button(action: {
                            viewModel.availableSeats = count
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.title3)
                                Text("\(count)")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.availableSeats == count ? Color.blue : Color(.systemGray6))
                            .foregroundColor(viewModel.availableSeats == count ? .white : .primary)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Price
            VStack(alignment: .leading, spacing: 8) {
                Text("Cena po mestu *")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(.green)
                    
                    TextField("Cena", text: $viewModel.pricePerSeat)
                        .keyboardType(.numberPad)
                    
                    Text("RSD")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Step 2: Date & Time
    private var dateTimeStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Datum i vreme")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Kada planirate da krenete?")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Date Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Datum *")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                DatePicker(
                    "",
                    selection: $viewModel.departureDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            // Time Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Vreme polaska *")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                DatePicker(
                    "",
                    selection: $viewModel.departureTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            // Estimated Arrival Time (Optional)
            VStack(alignment: .leading, spacing: 8) {
                Text("Procenjeno vreme dolaska (opciono)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Toggle("Dodaj procenjeno vreme dolaska", isOn: Binding(
                    get: { viewModel.arrivalTime != nil },
                    set: { if !$0 { viewModel.arrivalTime = nil } else {
                        viewModel.arrivalTime = viewModel.departureTime.addingTimeInterval(3600)
                    }}
                ))
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                if viewModel.arrivalTime != nil {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { viewModel.arrivalTime ?? Date() },
                            set: { viewModel.arrivalTime = $0 }
                        ),
                        in: viewModel.departureTime...,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Step 3: Preferences
    private var preferencesStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Preferencije")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Dodatne informacije o vožnji")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(spacing: 16) {
                // Auto Accept
                PreferenceToggle(
                    icon: "checkmark.circle.fill",
                    title: "Automatski prihvataj rezervacije",
                    description: "Rezervacije će biti automatski prihvaćene",
                    isOn: $viewModel.autoAccept,
                    activeColor: .green
                )
                
                // Smoking
                PreferenceToggle(
                    icon: "smoke.fill",
                    title: "Dozvoljeno pušenje",
                    description: "Putnici mogu pušiti u vozilu",
                    isOn: $viewModel.allowSmoking,
                    activeColor: .orange
                )
                
                // Pets
                PreferenceToggle(
                    icon: "pawprint.fill",
                    title: "Dozvoljeni kućni ljubimci",
                    description: "Putnici mogu voditi kućne ljubimce",
                    isOn: $viewModel.allowPets,
                    activeColor: .brown
                )
                
                // Max Two in Back
                PreferenceToggle(
                    icon: "person.2.fill",
                    title: "Maksimalno dvoje pozadi",
                    description: "Najviše dva putnika na zadnjem sedištu",
                    isOn: $viewModel.maxTwoInBack,
                    activeColor: .blue
                )
            }
            
            // Luggage Size
            VStack(alignment: .leading, spacing: 8) {
                Text("Veličina prtljaga")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Picker("Veličina prtljaga", selection: $viewModel.selectedLuggage) {
                    Text("Mali").tag("Mali")
                    Text("Srednji").tag("Srednji")
                    Text("Veliki").tag("Veliki")
                }
                .pickerStyle(.segmented)
            }
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Opis (opciono)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextEditor(text: $viewModel.description)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
                Text("Dodatne informacije za putnike")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Step 4: Waypoints
    private var waypointsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Usputne stanice")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Dodajte mesta gde možete pokupiti ili ostaviti putnike")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if viewModel.waypoints.isEmpty {
                Button(action: {
                    viewModel.addWaypoint()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Dodaj usputnu stanicu")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.waypoints.enumerated()), id: \.element.id) { index, waypoint in
                        WaypointInput(
                            index: index + 1,
                            location: Binding(
                                get: { waypoint.location },
                                set: { viewModel.waypoints[index].location = $0 }
                            ),
                            estimatedTime: Binding(
                                get: { waypoint.estimatedTime },
                                set: { viewModel.waypoints[index].estimatedTime = $0 }
                            ),
                            onRemove: {
                                viewModel.removeWaypoint(at: index)
                            }
                        )
                    }
                }
                
                if viewModel.waypoints.count < 5 {
                    Button(action: {
                        viewModel.addWaypoint()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Dodaj još")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
            }
            
            Text("Možete dodati do 5 usputnih stanica")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: 12) {
                // Next / Submit Button
                CustomButton(
                    title: currentStep == 4 ? "Objavi vožnju" : "Nastavi",
                    action: {
                        if currentStep == 4 {
                            Task {
                                let success = await viewModel.createRide()
                                if success {
                                    showSuccess = true
                                }
                            }
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    },
                    style: .primary,
                    isLoading: viewModel.isLoading,
                    disabled: !canProceed
                )
                
                // Back Button
                if currentStep > 1 {
                    Button(action: {
                        withAnimation {
                            currentStep -= 1
                        }
                    }) {
                        Text("Nazad")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Helpers
    private var canProceed: Bool {
        switch currentStep {
        case 1:
            return !viewModel.departureLocation.isEmpty &&
                   !viewModel.arrivalLocation.isEmpty &&
                   !viewModel.pricePerSeat.isEmpty &&
                   Double(viewModel.pricePerSeat) != nil &&
                   viewModel.selectedVehicleId != nil
        case 2:
            return true
        case 3:
            return true
        case 4:
            return true
        default:
            return false
        }
    }
}
