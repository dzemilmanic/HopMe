import SwiftUI
import SwiftUI

struct VehiclesView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = VehicleListViewModel()
    @State private var showAddVehicle = false
    @State private var vehicleToDelete: Vehicle?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    LoadingView(message: "Loading vehicles...")
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
                        title: "You don't have any vehicles",
                        description: "Add a vehicle to create a ride",
                        actionTitle: "Add vehicle",
                        action: { showAddVehicle = true }
                    )
                } else {
                    vehiclesList
                }
            }
            .navigationTitle("My vehicles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
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
            .alert("Deleting vehicle", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    vehicleToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let vehicle = vehicleToDelete {
                        Task {
                            await viewModel.deleteVehicle(id: vehicle.id)
                        }
                    }
                    vehicleToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this vehicle?")
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
                        },
                        onUpdate: {
                            Task {
                                await viewModel.loadVehicles()
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }
}

#Preview {
    VehiclesView()
}
