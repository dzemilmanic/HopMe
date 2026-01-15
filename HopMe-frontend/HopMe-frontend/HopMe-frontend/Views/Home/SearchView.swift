import SwiftUI

struct SearchView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
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
                LoadingView(message: "Searching for rides...")
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
                    title: "No available rides",
                    description: viewModel.canSearch ? "Try with different search criteria" : "No active rides at the moment"
                )
            } else {
                searchResults
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
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
                // Load all rides initially, user can search to filter
                await viewModel.loadAllRides()
            }
        }
    }
    
    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.blue)
                
                TextField("From", text: $viewModel.searchFrom)
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
                
                TextField("To", text: $viewModel.searchTo)
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
                DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .labelsHidden()
                
                Spacer()
                
                Picker("Passengers", selection: $viewModel.passengers) {
                    ForEach(1...8, id: \.self) { count in
                        Text("\(count) passenger\(count > 1 ? "s" : "")").tag(count)
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
                    Text("Search")
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
                        Text("Filters")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(20)
                }
                
                if viewModel.filters.maxPrice != nil {
                    Button(action: {
                        viewModel.filters.maxPrice = nil
                        viewModel.applyFilters()
                    }) {
                        HStack(spacing: 4) {
                            Text("Max \(viewModel.filters.maxPrice!)din")
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(16)
                    }
                }
                
                if viewModel.filters.minRating != nil {
                    FilterChip(
                        title: "\(viewModel.filters.minRating!)★+",
                        icon: "star.fill",
                        isSelected: true,
                        action: {
                            viewModel.filters.minRating = nil
                            viewModel.applyFilters()
                        }
                    )
                }

                if viewModel.filters.autoAcceptOnly {
                    FilterChip(
                        title: "Auto accept",
                        icon: "checkmark.circle.fill",  
                        isSelected: true,
                        action: {
                            viewModel.filters.autoAcceptOnly = false
                            viewModel.applyFilters()
                        }
                    )
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
#Preview("Search View") {
    NavigationView {
        SearchView()
    }
}
