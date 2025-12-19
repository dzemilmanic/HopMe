import SwiftUI
import PhotosUI

struct AddVehicleView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddVehicleViewModel()
    let onComplete: () -> Void
    
    @State private var showImagePicker = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Tip vozila *") {
                    Picker("Tip vozila", selection: $viewModel.vehicleType) {
                        ForEach(viewModel.vehicleTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Detalji vozila") {
                    TextField("Marka (opciono)", text: $viewModel.brand)
                    TextField("Model (opciono)", text: $viewModel.model)
                    TextField("Godina (opciono)", text: $viewModel.year)
                        .keyboardType(.numberPad)
                    TextField("Boja (opciono)", text: $viewModel.color)
                    TextField("Registarska tablica (opciono)", text: $viewModel.licensePlate)
                        .textInputAutocapitalization(.characters)
                }
                
                Section("Slike vozila *") {
                    if viewModel.images.isEmpty {
                        Button(action: { showImagePicker = true }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .foregroundColor(.blue)
                                Text("Dodaj slike")
                                    .foregroundColor(.blue)
                            }
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(viewModel.images.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        Button(action: {
                                            viewModel.removeImage(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.red))
                                        }
                                        .padding(4)
                                    }
                                }
                                
                                if viewModel.images.count < 5 {
                                    Button(action: { showImagePicker = true }) {
                                        VStack {
                                            Image(systemName: "plus")
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                        }
                                        .frame(width: 100, height: 100)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        Text("\(viewModel.images.count)/5 slika")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            let success = await viewModel.addVehicle()
                            if success {
                                showSuccess = true
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Dodaj vozilo")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(viewModel.isFormValid ? Color.blue : Color.gray)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
            }
            .navigationTitle("Dodaj vozilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Otkaži") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: $viewModel.images, maxImages: 5)
            }
            .alert("Vozilo dodato!", isPresented: $showSuccess) {
                Button("OK") {
                    onComplete()
                    dismiss()
                }
            } message: {
                Text("Vaše vozilo je uspešno dodato.")
            }
            .errorAlert(errorMessage: $viewModel.errorMessage)
        }
    }
}
#Preview("Add Vehicle View") {
    AddVehicleView {
        print("Vehicle added")
    }
}
