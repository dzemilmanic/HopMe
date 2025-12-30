import SwiftUI
import Combine
import Foundation

struct CreateTestimonialView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CreateTestimonialViewModel()
    var onSuccess: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vaša ocena")) {
                    HStack {
                        Spacer()
                        RatingStars(rating: Double(viewModel.rating), size: 30) { rating in
                            viewModel.rating = Int(rating)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Vaše iskustvo")) {
                    TextEditor(text: $viewModel.text)
                        .frame(minHeight: 100)
                        .overlay(
                            Text("Napišite vaše utiske (min 10 karaktera)...")
                                .foregroundColor(.gray)
                                .opacity(viewModel.text.isEmpty ? 0.6 : 0)
                                .padding(.top, 8)
                                .padding(.leading, 4),
                            alignment: .topLeading
                        )
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            if await viewModel.submitTestimonial() {
                                onSuccess()
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding(.trailing, 5)
                            }
                            Text("Pošalji recenziju")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(viewModel.isLoading || !viewModel.isValid)
                    .listRowBackground(viewModel.isValid ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(viewModel.isValid ? .white : .gray)
                }
            }
            .navigationTitle("Ostavi utisak")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Otkaži") {
                        dismiss()
                    }
                }
            }
        }
    }
}

class CreateTestimonialViewModel: ObservableObject {
    @Published var rating: Int = 5
    @Published var text: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = TestimonialService.shared
    
    var isValid: Bool {
        rating >= 1 && rating <= 5 && text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }
    
    @MainActor
    func submitTestimonial() async -> Bool {
        guard isValid else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await service.createTestimonial(rating: rating, text: text)
            isLoading = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Greška pri slanju recenzije"
        }
        
        isLoading = false
        return false
    }
}
