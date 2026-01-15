import SwiftUI

struct HelpSupportView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
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
            .navigationTitle("Help and support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
            
            Text("How can we help you?")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Find answers to the most common questions or contact us")
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
            
            TextField("Search help...", text: $searchText)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick actions")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    icon: "envelope.fill",
                    title: "Email support",
                    color: .blue
                ) {
                    // TODO: Open email
                    if let url = URL(string: "mailto:support@hopme.com") {
                        UIApplication.shared.open(url)
                    }
                }
                
                QuickActionCard(
                    icon: "phone.fill",
                    title: "Call us",
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
                    title: "Documentation",
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
            Text("Most common questions")
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
            Text("Didn't find an answer?")
                .font(.headline)
            
            Text("Our team is here to help you 24/7")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: {
                showContactForm = true
            }) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Contact us")
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
    case booking = "Bookings"
    case rides = "Rides"
    case payments = "Payments"
    case account = "Account"
    case safety = "Safety"
    case technical = "Technical issues"
    
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
                FAQItem(question: "How do I book a ride?", answer: "Open the app, enter your destination, select a driver, and confirm the reservation."),
                FAQItem(question: "Can I cancel my reservation?", answer: "Yes, you can cancel your reservation up to 15 minutes before the scheduled time."),
                FAQItem(question: "How much does the reservation cost?", answer: "The price depends on the distance and driver. You will see the final price before confirmation.")
            ]
        case .rides:
            return [
                FAQItem(question: "How do I track my ride?", answer: "In the app, you can track the driver's current location in real-time."),
                FAQItem(question: "What if the driver is late?", answer: "Contact the driver directly or contact support for assistance.")
            ]
        case .payments:
            return [
                FAQItem(question: "What payment methods do you accept?", answer: "We accept credit cards, cash, and mobile payments."),
                FAQItem(question: "How do I add a new card?", answer: "Go to Settings > Payment and add a new card.")
            ]
        case .account:
            return [
                FAQItem(question: "How do I change my profile?", answer: "Go to Profile > Edit Profile and update your information."),
                FAQItem(question: "How do I delete my account?", answer: "Contact support for permanent account deletion.")
            ]
        case .safety:
            return [
                FAQItem(question: "Is the app safe?", answer: "Yes, all drivers are verified and have licenses."),
                FAQItem(question: "What should I do in emergency situations?", answer: "Use the emergency button in the app or call 192.")
            ]
        case .technical:
            return [
                FAQItem(question: "The app doesn't work as expected", answer: "Try to restart the app or check your internet connection."),
                FAQItem(question: "How do I update the app?", answer: "Check the App Store for the latest version.")
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
                
                Text("\(category.questions.count) questions")
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
    @SwiftUI.Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var message = ""
    @State private var selectedCategory: HelpCategory = .technical
    
    var body: some View {
        NavigationView {
            Form {
                Section("Your information") {
                    TextField("First name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                Section("Your question") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(HelpCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    TextField("Subject", text: $subject)
                    
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                }
                
                Section {
                    Button("Send") {
                        // TODO: Send support message
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Contact us")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
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
