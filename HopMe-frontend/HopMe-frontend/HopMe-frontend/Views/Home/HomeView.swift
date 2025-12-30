import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSearch = false
    @State private var searchFrom = ""
    @State private var searchTo = ""
    @State private var selectedDate = Date()
    @State private var passengers = 1
    @State private var showAddTestimonial = false
    @State private var testimonialToDelete: Testimonial?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with greeting
                headerSection
                
                // Quick Search Card
                quickSearchCard
                
                // Popular Routes
                popularRoutesSection
                
                // Stats Section
                statsSection
                
                // How it works
                howItWorksSection
                
                // Testimonials
                testimonialsSection
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.loadData()
        }
        .navigationTitle("HopMe")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSearch) {
            NavigationView {
                SearchView(
                    searchFrom: searchFrom,
                    searchTo: searchTo,
                    selectedDate: selectedDate,
                    passengers: passengers
                )
            }
        }
        .sheet(isPresented: $showAddTestimonial) {
            CreateTestimonialView {
                Task {
                    await viewModel.loadTestimonials()
                    await viewModel.checkUserTestimonial() // Proveri ponovo da li korisnik sada ima testimonial
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Zdravo, \(authViewModel.currentUser?.firstName ?? "Korisnik")! 👋")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Gde želite da putujete?")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    // MARK: - Quick Search Card
    private var quickSearchCard: some View {
        VStack(spacing: 16) {
            // From
            HStack(spacing: 12) {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                TextField("Polazište", text: $searchFrom)
                    .font(.body)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // To
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                
                TextField("Destinacija", text: $searchTo)
                    .font(.body)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Date and Passengers
            HStack(spacing: 12) {
                // Date
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Passengers
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.purple)
                    
                    Picker("", selection: $passengers) {
                        ForEach(1...8, id: \.self) { count in
                            Text("\(count)").tag(count)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // Search Button
            Button(action: {
                showSearch = true
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Pretraži vožnje")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(searchFrom.isEmpty && searchTo.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // MARK: - Popular Routes
    private var popularRoutesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popularne rute")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.popularRoutes, id: \.from) { route in
                        PopularRouteCard(
                            from: route.from,
                            to: route.to,
                            price: route.price
                        ) {
                            searchFrom = route.from
                            searchTo = route.to
                            showSearch = true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(icon: "person.3.fill", value: viewModel.stats.users, label: "Korisnika")
            StatCard(icon: "car.fill", value: viewModel.stats.rides, label: "Vožnji")
            StatCard(icon: "star.fill", value: viewModel.stats.rating, label: "Ocena")
        }
        .padding(.horizontal)
    }
    
    // MARK: - How It Works
    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kako funkcionише?")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                HowItWorksStep(
                    number: 1,
                    icon: "magnifyingglass",
                    title: "Pronađite vožnju",
                    description: "Pretražite vožnje koje odgovaraju vašoj ruti"
                )
                
                HowItWorksStep(
                    number: 2,
                    icon: "checkmark.circle.fill",
                    title: "Rezervišite mesto",
                    description: "Izaberite vožnju i rezervišite sedište"
                )
                
                HowItWorksStep(
                    number: 3,
                    icon: "car.fill",
                    title: "Putujte",
                    description: "Upoznajte vozača i krenite na put"
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Testimonials
    private var testimonialsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Šta korisnici kažu")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Prikaži dugme samo ako korisnik nema testimonial
                if !viewModel.userHasTestimonial {
                    Button(action: {
                        showAddTestimonial = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Dodaj utisak")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
            
            if viewModel.testimonials.isEmpty {
                Text("Budite prvi koji će ostaviti utisak!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.testimonials) { testimonial in
                            TestimonialCard(
                                testimonial: testimonial,
                                onDelete: authViewModel.currentUser?.isAdmin == true ? {
                                    testimonialToDelete = testimonial
                                    showDeleteConfirmation = true
                                } : nil
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom)
        .alert("Brisanje recenzije", isPresented: $showDeleteConfirmation) {
            Button("Otkaži", role: .cancel) {
                testimonialToDelete = nil
            }
            Button("Obriši", role: .destructive) {
                if let testimonial = testimonialToDelete {
                    Task {
                        try? await TestimonialService.shared.deleteTestimonial(id: testimonial.id)
                        await viewModel.loadTestimonials()
                        testimonialToDelete = nil
                    }
                }
            }
        } message: {
            Text("Da li ste sigurni da želite da obrišete ovu recenziju?")
        }
    }
}
#Preview("Home View") {
    NavigationView {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
