import SwiftUI

struct FilterSheet: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @Binding var filters: SearchFilters
    let onApply: () -> Void
    
    @State private var tempFilters: SearchFilters
    
    init(filters: Binding<SearchFilters>, onApply: @escaping () -> Void) {
        self._filters = filters
        self.onApply = onApply
        self._tempFilters = State(initialValue: filters.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Price Section
                Section {
                    Toggle("Postavi maksimalnu cenu", isOn: Binding(
                        get: { tempFilters.maxPrice != nil },
                        set: { if !$0 { tempFilters.maxPrice = nil } else { tempFilters.maxPrice = 1000 } }
                    ))
                    
                    if tempFilters.maxPrice != nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Maksimalna cena: \(Int(tempFilters.maxPrice ?? 0)) RSD")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Slider(
                                value: Binding(
                                    get: { Double(tempFilters.maxPrice ?? 0) },
                                    set: { tempFilters.maxPrice = Int($0) }
                                ),
                                in: 100...5000,
                                step: 100
                            )
                        }
                    }
                } header: {
                    Text("Cena")
                }
                
                // Rating Section
                Section {
                    Toggle("Postavi minimalnu ocenu", isOn: Binding(
                        get: { tempFilters.minRating != nil },
                        set: { if !$0 { tempFilters.minRating = nil } else { tempFilters.minRating = 4 } }
                    ))
                    
                    if tempFilters.minRating != nil {
                        Picker("Minimalna ocena", selection: Binding(
                            get: { tempFilters.minRating ?? 4 },
                            set: { tempFilters.minRating = $0 }
                        )) {
                            ForEach([3, 4, 5], id: \.self) { rating in
                                HStack {
                                    Text("\(rating)")
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.orange)
                                }
                                .tag(rating)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                } header: {
                    Text("Ocena vozača")
                }
                
                // Preferences Section
                Section {
                    Toggle("Samo automatski prihvat", isOn: $tempFilters.autoAcceptOnly)
                    Toggle("Dozvoljeno pušenje", isOn: $tempFilters.allowSmoking)
                    Toggle("Dozvoljeni ljubimci", isOn: $tempFilters.allowPets)
                } header: {
                    Text("Preferencije")
                }
                
                // Luggage Section
                Section {
                    Toggle("Filtriraj po prtljagu", isOn: Binding(
                        get: { tempFilters.luggageSize != nil },
                        set: { if !$0 { tempFilters.luggageSize = nil } else { tempFilters.luggageSize = "Srednji" } }
                    ))
                    
                    if tempFilters.luggageSize != nil {
                        Picker("Veličina prtljaga", selection: Binding(
                            get: { tempFilters.luggageSize ?? "Srednji" },
                            set: { tempFilters.luggageSize = $0 }
                        )) {
                            Text("Mali").tag("Mali")
                            Text("Srednji").tag("Srednji")
                            Text("Veliki").tag("Veliki")
                        }
                        .pickerStyle(.segmented)
                    }
                } header: {
                    Text("Prtljag")
                }
            }
            .navigationTitle("Filteri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Otkaži") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Resetuj") {
                        tempFilters = SearchFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider()
                    
                    CustomButton(
                        title: "Primeni filtere",
                        action: {
                            filters = tempFilters
                            onApply()
                            dismiss()
                        },
                        style: .primary
                    )
                    .padding()
                    .background(Color(.systemBackground))
                }
            }
        }
    }
}

// SearchFilters model (if not already defined)
//struct SearchFilters {
//    var maxPrice: Int?
//    var minRating: Int?
//   var autoAcceptOnly: Bool = false
//   var allowSmoking: Bool = false
//    var allowPets: Bool = false
//    var luggageSize: String?
//}
