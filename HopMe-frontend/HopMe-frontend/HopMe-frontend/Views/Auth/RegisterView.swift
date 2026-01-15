import SwiftUI
import PhotosUI
import SwiftUI
import Combine

struct RegisterView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = RegisterViewModel()
    @State private var currentStep = 1
    @State private var showImagePicker = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress Indicator
                    ProgressSteps(currentStep: currentStep, totalSteps: viewModel.isDriver ? 3 : 2)
                        .padding(.horizontal)
                    
                    // Step Content
                    switch currentStep {
                    case 1:
                        accountTypeStep
                    case 2:
                        personalInfoStep
                    case 3:
                        if viewModel.isDriver {
                            vehicleInfoStep
                        }
                    default:
                        EmptyView()
                    }
                    
                    // Navigation Buttons
                    navigationButtons
                }
                .padding(.vertical)
            }
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .errorAlert(errorMessage: $viewModel.errorMessage)
            .alert("Registration succesfull!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Check your email for verification.")
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: $viewModel.vehicleImages, maxImages: 5)
            }
        }
    }
    
    // MARK: - Step 1: Account Type
    private var accountTypeStep: some View {
        VStack(spacing: 20) {
            Text("Choose account type")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("You can add driver role later")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                AccountTypeCard(
                    icon: "person.fill",
                    title: "Passenger",
                    description: "Find rides and travel cheaper",
                    isSelected: !viewModel.isDriver,
                    action: { viewModel.isDriver = false }
                )
                
                AccountTypeCard(
                    icon: "car.fill",
                    title: "Driver",
                    description: "Share rides and earn money",
                    isSelected: viewModel.isDriver,
                    action: { viewModel.isDriver = true }
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Step 2: Personal Info
    private var personalInfoStep: some View {
        VStack(spacing: 20) {
            Text("Personal information")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    CustomTextField(
                        icon: "person.fill",
                        placeholder: "First name",
                        text: $viewModel.firstName
                    )
                    
                    CustomTextField(
                        icon: "person.fill",
                        placeholder: "Last name",
                        text: $viewModel.lastName
                    )
                }
                
                CustomTextField(
                    icon: "envelope.fill",
                    placeholder: "Email address",
                    text: $viewModel.email,
                    keyboardType: .emailAddress
                )
                
                CustomTextField(
                    icon: "phone.fill",
                    placeholder: "Phone number",
                    text: $viewModel.phone,
                    keyboardType: .phonePad
                )
                
                CustomTextField(
                    icon: "lock.fill",
                    placeholder: "Password (min. 6 characters)",
                    text: $viewModel.password,
                    isSecure: true
                )
                
                CustomTextField(
                    icon: "lock.fill",
                    placeholder: "Confirm password",
                    text: $viewModel.confirmPassword,
                    isSecure: true
                )
                
                if !viewModel.password.isEmpty && !viewModel.confirmPassword.isEmpty {
                    HStack {
                        Image(systemName: viewModel.passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(viewModel.passwordsMatch ? .green : .red)
                        Text(viewModel.passwordsMatch ? "Password match" : "Passwords do not match")
                            .font(.caption)
                            .foregroundColor(viewModel.passwordsMatch ? .green : .red)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Step 3: Vehicle Info (Driver only)
    private var vehicleInfoStep: some View {
        VStack(spacing: 20) {
            Text("Vehicle information")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                // Vehicle Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vehicle type *")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Picker("Vehicle type", selection: $viewModel.vehicleType) {
                        ForEach(["Sedan", "SUV", "Hatchback", "Wagon", "Coupe", "Minivan"], id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                HStack(spacing: 12) {
                    CustomTextField(
                        icon: "car.fill",
                        placeholder: "Brand (optional)",
                        text: $viewModel.brand
                    )
                    
                    CustomTextField(
                        icon: "car.fill",
                        placeholder: "Model (optional)",
                        text: $viewModel.model
                    )
                }
                
                // Vehicle Images
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Vehicle images *")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(viewModel.vehicleImages.count)/5")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if viewModel.vehicleImages.isEmpty {
                        Button(action: { showImagePicker = true }) {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                
                                Text("Add vehicle images")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                
                                Text("Minimum 1 image, maximum 5")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 150)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(viewModel.vehicleImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        Button(action: {
                                            viewModel.removeVehicleImage(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.red))
                                        }
                                        .padding(4)
                                    }
                                }
                                
                                if viewModel.vehicleImages.count < 5 {
                                    Button(action: { showImagePicker = true }) {
                                        VStack {
                                            Image(systemName: "plus")
                                                .font(.title)
                                                .foregroundColor(.blue)
                                        }
                                        .frame(width: 120, height: 120)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        VStack(spacing: 12) {
            // Next / Submit Button
            CustomButton(
                title: isLastStep ? "Register" : "Next",
                action: {
                    if isLastStep {
                        Task {
                            let success = await viewModel.register()
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
                    Text("Back")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    private var isLastStep: Bool {
        viewModel.isDriver ? currentStep == 3 : currentStep == 2
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 1:
            return true
        case 2:
            return !viewModel.firstName.isEmpty &&
                   !viewModel.lastName.isEmpty &&
                   !viewModel.email.isEmpty &&
                   !viewModel.phone.isEmpty &&
                   viewModel.password.count >= 6 &&
                   viewModel.passwordsMatch
        case 3:
            return viewModel.isDriver ? !viewModel.vehicleImages.isEmpty : true
        default:
            return false
        }
    }
}
#Preview("Register View") {
    RegisterView()
}
