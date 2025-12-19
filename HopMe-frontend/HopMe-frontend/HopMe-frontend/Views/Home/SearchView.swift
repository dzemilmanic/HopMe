import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SearchViewModel()
    @State private var showFilters = false
    
    // Pre-filled search params
    var searchFrom: String = ""
    var searchTo: String = ""
    var selectedDate: Date = Date()
    var passengers: Int = 1
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Header
            searchHeader
            
            // Filters Bar
            if viewModel.searchResults.isEmpty && !viewModel.isLoading {
                EmptyView()
            } else {
                filtersBar
            }
            
            Divider()
            
            // Content
            if viewModel.isLoading {
                LoadingView(message: "Pretražujem vožnje...")
            } else if let error = viewModel.errorMessage {
                ErrorView(
                    message: error,
                    retryAction: {
                        Task {
                            await performSearch()
                        }
                    }
                )
            } else if viewModel.searchResults.isEmpty {
                EmptyStateView(
                    icon: "car.fill",
                    title: "Nema rezultata",
                    description: "Pokušajte sa različitim kriterijumima pretrage"
                )
            } else {
                searchResults
            }
        }
        .navigationTitle("Pretraga")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Zatvori") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterSheet(filters: $viewModel.filters) {
                viewModel.applyFilters()
            }
        }
        .onAppear {
            viewModel.searchFrom = searchFrom
            viewModel.searchTo = searchTo
            viewModel.selectedDate = selectedDate
            viewModel.passengers = passengers
            
            Task {
                await performSearch()
            }
        }
    }
    
    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.blue)
                
                TextField("Polazište", text: $viewModel.searchFrom)
                    .textFieldStyle(.plain)
                
                if !viewModel.searchFrom.isEmpty {
                    Button(action: { viewModel.searchFrom = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .foregroundColor(.green)
                
                TextField("Destinacija", text: $viewModel.searchTo)
                    .textFieldStyle(.plain)
                
                if !viewModel.searchTo.isEmpty {
                    Button(action: { viewModel.searchTo = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            HStack {
                DatePicker("Datum", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .labelsHidden()
                
                Spacer()
                
                Picker("Putnika", selection: $viewModel.passengers) {
                    ForEach(1...8, id: \.self) { count in
                        Text("\(count) putnik\(count > 1 ? "a" : "")").tag(count)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Button(action: {
                Task {
                    await performSearch()
                }
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Pretraži")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canSearch ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!viewModel.canSearch)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Filters Bar
    private var filtersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: { showFilters = true }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("Filteri")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(20)
                }
                
                if viewModel.filters.maxPrice != nil {
                    FilterChip(title: "Max \(viewModel.filters.maxPrice!)din") {
                        viewModel.filters.maxPrice = nil
                        viewModel.applyFilters()
                    }
                }
                
                if viewModel.filters.minRating != nil {
                    FilterChip(title: "\(viewModel.filters.minRating!)★+") {
                        viewModel.filters.minRating = nil
                        viewModel.applyFilters()
                    }
                }
                
                if viewModel.filters.autoAcceptOnly {
                    FilterChip(title: "Auto prihvat") {
                        viewModel.filters.autoAcceptOnly = false
                        viewModel.applyFilters()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Search Results
    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.searchResults) { ride in
                    NavigationLink(destination: RideDetailView(ride: ride)) {
                        RideCard(ride: ride)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    private func performSearch() async {
        await viewModel.search()
    }
}
