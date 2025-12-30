import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: HelpCategory? = nil
    @State private var showContactForm = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Search Bar
                    searchSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // FAQ Categories
                    faqCategoriesSection
                    
                    // Contact Support
                    contactSupportSection
                }
                .padding()
            }
            .navigationTitle("Pomoć i podrška")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Gotovo") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showContactForm) {
                ContactSupportFormView()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Kako vam možemo pomoći?")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Pronađite odgovore na najčešća pitanja ili nas kontaktirajte")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Pretražite pomoć...", text: $searchText)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Brze radnje")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    icon: "envelope.fill",
                    title: "Email podrška",
                    color: .blue
                ) {
                    // TODO: Open email
                    if let url = URL(string: "mailto:support@hopme.com") {
                        UIApplication.shared.open(url)
                    }
                }
                
                QuickActionCard(
                    icon: "phone.fill",
                    title: "Pozovi nas",
                    color: .green
                ) {
                    // TODO: Call support
                    if let url = URL(string: "tel:+381601234567") {
                        UIApplication.shared.open(url)
                    }
                }
                
                QuickActionCard(
                    icon: "message.fill",
                    title: "Live Chat",
                    color: .purple
                ) {
                    // TODO: Open chat
                }
                
                QuickActionCard(
                    icon: "doc.text.fill",
                    title: "Dokumentacija",
                    color: .orange
                ) {
                    // TODO: Open documentation
                }
            }
        }
    }
    
    // MARK: - FAQ Categories
    private var faqCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Najčešća pitanja")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(HelpCategory.allCases) { category in
                    NavigationLink(destination: FAQCategoryView(category: category)) {
                        FAQCategoryRow(category: category)
                    }
                }
            }
        }
    }
    
    // MARK: - Contact Support
    private var contactSupportSection: some View {
        VStack(spacing: 16) {
            Text("Niste pronašli odgovor?")
                .font(.headline)
            
            Text("Naš tim je ovde da vam pomogne 24/7")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: {
                showContactForm = true
            }) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Kontaktirajte nas")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Supporting Models

enum HelpCategory: String, CaseIterable, Identifiable {
    case booking = "Rezervacije"
    case rides = "Vožnje"
    case payments = "Plaćanja"
    case account = "Nalog"
    case safety = "Bezbednost"
    case technical = "Tehnički problemi"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .booking: return "calendar"
        case .rides: return "car.fill"
        case .payments: return "creditcard.fill"
        case .account: return "person.fill"
        case .safety: return "shield.fill"
        case .technical: return "wrench.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .booking: return .blue
        case .rides: return .green
        case .payments: return .orange
        case .account: return .purple
        case .safety: return .red
        case .technical: return .gray
        }
    }
    
    var questions: [FAQItem] {
        switch self {
        case .booking:
            return [
                FAQItem(question: "Kako da rezervišem vožnju?", answer: "Otvorite aplikaciju, unesite destinaciju, izaberite vozača i potvrdite rezervaciju."),
                FAQItem(question: "Mogu li otkazati rezervaciju?", answer: "Da, možete otkazati rezervaciju sve do 15 minuta pre zakazanog vremena."),
                FAQItem(question: "Koliko košta rezervacija?", answer: "Cena zavisi od distance i vozača. Videćete konačnu cenu pre potvrde.")
            ]
        case .rides:
            return [
                FAQItem(question: "Kako da pratim svoju vožnju?", answer: "U aplikaciji možete pratiti trenutnu lokaciju vozača u realnom vremenu."),
                FAQItem(question: "Šta ako vozač kasni?", answer: "Kontaktirajte vozača direktno ili kontaktirajte podršku za pomoć.")
            ]
        case .payments:
            return [
                FAQItem(question: "Koje metode plaćanja prihvatate?", answer: "Prihvatamo kartice, keš i mobilno plaćanje."),
                FAQItem(question: "Kako da dodam novu karticu?", answer: "Idite na Podešavanja > Plaćanje i dodajte novu karticu.")
            ]
        case .account:
            return [
                FAQItem(question: "Kako da promenim profil?", answer: "Idite na Profil > Izmeni profil i ažurirajte informacije."),
                FAQItem(question: "Kako da obrišem nalog?", answer: "Kontaktirajte podršku za trajno brisanje naloga.")
            ]
        case .safety:
            return [
                FAQItem(question: "Da li je aplikacija bezbedna?", answer: "Da, svi vozači su verifikovani i imaju dozvole."),
                FAQItem(question: "Šta da radim u hitnim situacijama?", answer: "Koristite dugme za hitne slučajeve u aplikaciji ili pozovite 192.")
            ]
        case .technical:
            return [
                FAQItem(question: "Aplikacija ne radi kako treba", answer: "Pokušajte da restartujete aplikaciju ili proverite internet konekciju."),
                FAQItem(question: "Kako da ažuriram aplikaciju?", answer: "Proverite App Store za najnoviju verziju.")
            ]
        }
    }
}

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

// MARK: - Supporting Views

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct FAQCategoryRow: View {
    let category: HelpCategory
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .foregroundColor(category.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .foregroundColor(.primary)
                
                Text("\(category.questions.count) pitanja")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct FAQCategoryView: View {
    let category: HelpCategory
    @State private var expandedItems: Set<UUID> = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(category.questions) { item in
                    FAQItemView(
                        item: item,
                        isExpanded: expandedItems.contains(item.id)
                    ) {
                        if expandedItems.contains(item.id) {
                            expandedItems.remove(item.id)
                        } else {
                            expandedItems.insert(item.id)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQItemView: View {
    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onTap) {
                HStack {
                    Text(item.question)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if isExpanded {
                Text(item.answer)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ContactSupportFormView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var message = ""
    @State private var selectedCategory: HelpCategory = .technical
    
    var body: some View {
        NavigationView {
            Form {
                Section("Vaše informacije") {
                    TextField("Ime i prezime", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                Section("Vaše pitanje") {
                    Picker("Kategorija", selection: $selectedCategory) {
                        ForEach(HelpCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    TextField("Naslov", text: $subject)
                    
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                }
                
                Section {
                    Button("Pošalji") {
                        // TODO: Send support message
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Kontaktirajte nas")
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

#Preview("Help & Support View") {
    HelpSupportView()
}
