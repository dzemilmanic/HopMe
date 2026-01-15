import SwiftUI
import PhotosUI

struct EditVehicleView: View {
    @StateObject private var viewModel: EditVehicleViewModel
    @SwiftUI.Environment(\.dismiss) var dismiss
    let onComplete: () -> Void
    
    @State private var showImagePicker = false
    @State private var showSuccess = false
    
    init(vehicle: Vehicle, onComplete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EditVehicleViewModel(vehicle: vehicle))
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Vehicle type *") {
                    Picker("Vehicle type", selection: $viewModel.vehicleType) {
                        ForEach(viewModel.vehicleTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Vehicle details") {
                    TextField("Brand (optional)", text: $viewModel.brand)
                    TextField("Model (optional)", text: $viewModel.model)
                    TextField("Year (optional)", text: $viewModel.year)
                        .keyboardType(.numberPad)
                    TextField("Color (optional)", text: $viewModel.color)
                    TextField("License plate (optional)", text: $viewModel.licensePlate)
                        .textInputAutocapitalization(.characters)
                }
                
                Section("Vehicle images *") {
                    if viewModel.existingImages.isEmpty && viewModel.newImages.isEmpty {
                        Button(action: { showImagePicker = true }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .foregroundColor(.blue)
                                Text("Add images")
                                    .foregroundColor(.blue)
                            }
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Show existing images
                                ForEach(Array(viewModel.existingImages.enumerated()), id: \.element.id) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        AsyncImage(url: URL(string: image.imageUrl)) { img in
                                            img
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                        }
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        Button(action: {
                                            viewModel.removeExistingImage(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.red))
                                        }
                                        .padding(4)
                                    }
                                }
                                
                                // Show new images
                                ForEach(Array(viewModel.newImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        Button(action: {
                                            viewModel.removeNewImage(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.red))
                                        }
                                        .padding(4)
                                    }
                                }
                                
                                if (viewModel.existingImages.count + viewModel.newImages.count) < 5 {
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
                        
                        Text("\(viewModel.existingImages.count + viewModel.newImages.count)/5 slika")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            let success = await viewModel.saveChanges()
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
                            Text("Save changes")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(viewModel.isFormValid ? Color.blue : Color.gray)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
            }
            .navigationTitle("Edit vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: $viewModel.newImages, maxImages: 5 - viewModel.existingImages.count)
            }
            .alert("Vehicle updated!", isPresented: $showSuccess) {
                Button("OK") {
                    onComplete()
                    dismiss()
                }
            } message: {
                Text("Changes successfully saved.")
            }
            .errorAlert(errorMessage: $viewModel.errorMessage)
        }
    }
}
