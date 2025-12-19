import SwiftUI

struct VehiclesView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = VehicleListViewModel()
    @State private var showAddVehicle = false
    @State private var vehicleToDelete: Vehicle?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    LoadingView(message: "Učitavanje vozila...")
                } else if let error = viewModel.errorMessage {
                    ErrorView(
                        message: error,
                        retryAction: {
                            Task {
                                await viewModel.loadVehicles()
                            }
                        }
                    )
                } else if viewModel.vehicles.isEmpty {
                    EmptyStateView(
                        icon: "car.fill",
                        title: "Nemate vozila",
                        description: "Dodajte vozilo kako biste mogli da kreirate vožnje",
                        actionTitle: "Dodaj vozilo",
                        action: { showAddVehicle = true }
                    )
                } else {
                    vehiclesList
                }
            }
            .navigationTitle("Moja vozila")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zatvori") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddVehicle = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddVehicle) {
                AddVehicleView {
                    Task {
                        await viewModel.loadVehicles()
                    }
                }
            }
            .alert("Brisanje vozila", isPresented: $showDeleteAlert) {
                Button("Otkaži", role: .cancel) {
                    vehicleToDelete = nil
                }
                Button("Obriši", role: .destructive) {
                    if let vehicle = vehicleToDelete {
                        Task {
                            await viewModel.deleteVehicle(id: vehicle.id)
                        }
                    }
                    vehicleToDelete = nil
                }
            } message: {
                Text("Da li ste sigurni da želite da obrišete ovo vozilo?")
            }
            .task {
                await viewModel.loadVehicles()
            }
        }
    }
    
    private var vehiclesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.vehicles) { vehicle in
                    VehicleCard(
                        vehicle: vehicle,
                        onDelete: {
                            vehicleToDelete = vehicle
                            showDeleteAlert = true
                        }
                    )
                }
            }
            .padding()
        }
    }
}

#Preview("Vehicles View") {
    VehiclesView()
}
