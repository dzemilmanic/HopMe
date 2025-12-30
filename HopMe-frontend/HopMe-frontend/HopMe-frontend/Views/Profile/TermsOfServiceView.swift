import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedSection: TermsSection? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Last Updated
                    lastUpdatedSection
                    
                    // Quick Links
                    quickLinksSection
                    
                    // Terms Sections
                    termsSectionsView
                    
                    // Acceptance Button
                    acceptanceSection
                }
                .padding()
            }
            .navigationTitle("Uslovi korišćenja")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Gotovo") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Uslovi korišćenja")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Pročitajte naše uslove i politike")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Last Updated
    private var lastUpdatedSection: some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundColor(.gray)
            
            Text("Poslednje ažurirano: 30. decembar 2025.")
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Quick Links
    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Brzi linkovi")
                .font(.headline)
            
            HStack(spacing: 12) {
                QuickLinkButton(icon: "shield.fill", title: "Privatnost", color: .blue) {
                    // TODO: Navigate to privacy policy
                }
                
                QuickLinkButton(icon: "doc.plaintext", title: "Politika", color: .green) {
                    // TODO: Navigate to policy
                }
                
                QuickLinkButton(icon: "hand.raised.fill", title: "Zakon", color: .orange) {
                    // TODO: Navigate to legal
                }
            }
        }
    }
    
    // MARK: - Terms Sections
    private var termsSectionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sadržaj")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(TermsSection.allCases) { section in
                    NavigationLink(destination: TermsSectionDetailView(section: section)) {
                        TermsSectionRow(section: section)
                    }
                }
            }
        }
    }
    
    // MARK: - Acceptance Section
    private var acceptanceSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundColor(.green)
            
            Text("Korišćenjem HopMe aplikacije, prihvatate ove uslove korišćenja.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Models

enum TermsSection: String, CaseIterable, Identifiable {
    case introduction = "Uvod"
    case accountTerms = "Uslovi naloga"
    case serviceUsage = "Korišćenje usluga"
    case payments = "Plaćanja i naknade"
    case userResponsibilities = "Odgovornosti korisnika"
    case driverResponsibilities = "Odgovornosti vozača"
    case intellectualProperty = "Intelektualna svojina"
    case privacy = "Privatnost podataka"
    case liability = "Ograničenje odgovornosti"
    case termination = "Otkaz i prekid usluge"
    case disputeResolution = "Rešavanje sporova"
    case changes = "Izmene uslova"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .introduction: return "book.fill"
        case .accountTerms: return "person.fill"
        case .serviceUsage: return "car.fill"
        case .payments: return "creditcard.fill"
        case .userResponsibilities: return "checkmark.shield.fill"
        case .driverResponsibilities: return "steering.wheel"
        case .intellectualProperty: return "c.circle.fill"
        case .privacy: return "lock.shield.fill"
        case .liability: return "exclamationmark.triangle.fill"
        case .termination: return "xmark.circle.fill"
        case .disputeResolution: return "scale.3d"
        case .changes: return "arrow.triangle.2.circlepath"
        }
    }
    
    var color: Color {
        switch self {
        case .introduction: return .blue
        case .accountTerms: return .purple
        case .serviceUsage: return .green
        case .payments: return .orange
        case .userResponsibilities: return .cyan
        case .driverResponsibilities: return .indigo
        case .intellectualProperty: return .pink
        case .privacy: return .red
        case .liability: return .yellow
        case .termination: return .red
        case .disputeResolution: return .brown
        case .changes: return .blue
        }
    }
    
    var content: String {
        switch self {
        case .introduction:
            return """
            Dobrodošli u HopMe, platformu za deljenje vožnji. Ovi Uslovi korišćenja ("Uslovi") regulišu vaš pristup i korišćenje HopMe aplikacije i usluga.
            
            Korišćenjem naših usluga, slažete se sa ovim uslovima. Ako se ne slažete sa bilo kojim delom uslova, nemojte koristiti našu aplikaciju.
            
            HopMe platformu čine mobilna aplikacija, veb stranica i sve povezane usluge koje omogućavaju korisnicima da rezervišu vožnje i vozačima da nude usluge prevoza.
            """
        case .accountTerms:
            return """
            Da biste koristili HopMe, morate kreirati nalog i pružiti tačne, potpune i ažurne informacije. Vi ste odgovorni za održavanje sigurnosti vašeg naloga i lozinke.
            
            Morate imati najmanje 18 godina da biste kreirali nalog. Garantujete da su sve informacije koje pružite tačne i da ćete ih redovno ažurirati.
            
            Niste dozvoljeni da:
            • Delite svoj nalog sa drugima
            • Koristite tuđi nalog
            • Kreirate lažni nalog
            • Koristite automatizovane sisteme za pristup
            """
        case .serviceUsage:
            return """
            HopMe platforma povezuje putnike sa vozačima. Kao korisnik, slažete se da ćete koristiti usluge samo u legitimne svrhe i u skladu sa svim primenjivim zakonima i propisima.
            
            Kao putnik, možete:
            • Rezervisati vožnje kroz aplikaciju
            • Ocenjivati vozače
            • Kontaktirati podršku za pomoć
            
            HopMe zadržava pravo da suspenduje ili prekine pristup korisnicima koji krše ove uslove.
            """
        case .payments:
            return """
            Sve transakcije plaćanja obrađuju se kroz našu sigurnu platformu. Prihvatamo različite metode plaćanja uključujući kreditne/debitne kartice i keš.
            
            Cene se određuju na osnovu distance, vremena i drugih faktora. Konačna cena biće prikazana pre potvrde rezervacije.
            
            Otkazivanja mogu biti naplaćena u skladu sa našom politikom otkazivanja. Povraćaj novca se obrađuje u roku od 5-7 radnih dana.
            """
        case .userResponsibilities:
            return """
            Kao korisnik HopMe platforme, odgovorni ste za:
            
            • Poštovanje vozača i drugih korisnika
            • Tačno prijavljivanje na dogovorenom mestu i vremenu
            • Poštovanje vozila i vozačeve imovine
            • Pridržavanje bezbednosnih propisa (korišćenje sigurnosnog pojasa)
            • Neometanje vozača tokom vožnje
            
            Neprikladno ponašanje može rezultirati suspenzijom naloga.
            """
        case .driverResponsibilities:
            return """
            Vozači na HopMe platformi su nezavisni ugovarači i odgovorni su za:
            
            • Posedovanje važeće vozačke dozvole i registracije vozila
            • Održavanje vozila u bezbednom radnom stanju
            • Pružanje profesionalnih i bezbednih usluga prevoza
            • Poštovanje putnika i njihove privatnosti
            • Pridržavanje svih saobraćajnih zakona i propisa
            
            HopMe zadržava pravo da verifikuje vozače i njihova vozila.
            """
        case .intellectualProperty:
            return """
            Sav sadržaj HopMe aplikacije, uključujući tekst, slike, logotipe, dizajn i kod, zaštićen je autorskim pravima i pripadaju HopMe ili našim licencodavcima.
            
            Ne smete:
            • Kopirati ili reprodukovati sadržaj aplikacije
            • Modifikovati ili kreirati izvedene radove
            • Koristiti naše zaštitne znakove bez dozvole
            • Reverse engineering aplikacije
            
            Sve prava koja nisu izričito dodeljena ovim uslovima, zadržava HopMe.
            """
        case .privacy:
            return """
            Vaša privatnost je važna za nas. Prikupljamo, koristimo i štitimo vaše lične podatke u skladu sa našom Politikom privatnosti.
            
            Prikupljeni podaci uključuju:
            • Lične informacije (ime, email, telefon)
            • Lokacijske podatke
            • Istoriju transakcija
            • Podatke o korišćenju aplikacije
            
            Za potpune detalje, pogledajte našu Politiku privatnosti.
            """
        case .liability:
            return """
            HopMe platforma služi kao posrednik između putnika i vozača. Ne garantujemo dostupnost, kvalitet ili bezbednost usluga prevoza.
            
            U meri dozvoljenom zakonom, HopMe nije odgovoran za:
            • Direktne, indirektne ili slučajne štete
            • Gubitak dobiti ili podataka
            • Povrede ili štete nastale tokom vožnje
            • Radnje nezavisnih vozača
            
            Vaša ukupna naknada ograničena je na iznos plaćen za konkretnu uslugu.
            """
        case .termination:
            return """
            Možete zatvoriti svoj nalog u bilo kom trenutku kroz podešavanja aplikacije ili kontaktiranjem podrške.
            
            HopMe zadržava pravo da suspenduje ili prekine vaš nalog ako:
            • Kršite ove uslove korišćenja
            • Učestvujete u prevarnim aktivnostima
            • Pružate lažne informacije
            • Ne plaćate dugovanja
            
            Nakon prekida, izgubit ćete pristup aplikaciji i svim povezanim uslugama.
            """
        case .disputeResolution:
            return """
            U slučaju spora koji proizilazi iz korišćenja HopMe usluga, prvo pokušajte da kontaktirate našu podršku za rešavanje.
            
            Ako spor ne može biti rešen, slažete se na:
            • Dobrovoljnu medijaciju
            • Arbitražu ako je potrebno
            • Primenu zakona Republike Srbije
            
            Bilo koji pravni postupak mora biti pokrenut u roku od jedne godine od nastanka spora.
            """
        case .changes:
            return """
            HopMe zadržava pravo da izmeni ove uslove korišćenja u bilo kom trenutku. Izmene će stupiti na snagu odmah po objavljivanju u aplikaciji.
            
            Vaše nastavno korišćenje aplikacije nakon izmena predstavlja prihvatanje novih uslova.
            
            Preporučujemo da redovno proveravate ove uslove za bilo kakve ažuriranja.
            
            Za značajne izmene, obavestićemo vas putem email-a ili obaveštenja u aplikaciji.
            """
        }
    }
}

// MARK: - Supporting Views

struct QuickLinkButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct TermsSectionRow: View {
    let section: TermsSection
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: section.icon)
                .foregroundColor(section.color)
                .frame(width: 24)
            
            Text(section.rawValue)
                .foregroundColor(.primary)
            
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

struct TermsSectionDetailView: View {
    let section: TermsSection
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Section Header
                HStack(spacing: 12) {
                    Image(systemName: section.icon)
                        .font(.title)
                        .foregroundColor(section.color)
                    
                    Text(section.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(section.color.opacity(0.1))
                .cornerRadius(12)
                
                // Section Content
                Text(section.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(6)
                
                // Important Notice
                if section == .liability || section == .termination {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Važno")
                                .font(.headline)
                            Text("Pažljivo pročitajte ovaj odeljak jer sadrži važne pravne informacije.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(section.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Terms of Service View") {
    TermsOfServiceView()
}
