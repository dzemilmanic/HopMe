import SwiftUI

struct TermsOfServiceView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
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
            .navigationTitle("Terms of service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
            
            Text("Terms of service")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Read our terms and policies")
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
            
            Text("Last updated: 30. decembar 2025.")
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
            Text("Quick links")
                .font(.headline)
            
            HStack(spacing: 12) {
                QuickLinkButton(icon: "shield.fill", title: "Privacy", color: .blue) {
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
            Text("Content")
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
            
            Text("By using the HopMe application, you accept these terms of service.")
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
    case introduction = "Introduction"
    case accountTerms = "Account terms"
    case serviceUsage = "Service usage"
    case payments = "Payments and charges"
    case userResponsibilities = "User responsibilities"
    case driverResponsibilities = "Driver responsibilities"
    case intellectualProperty = "Intellectual property"
    case privacy = "Privacy"
    case liability = "Limitation of liability"
    case termination = "Termination"
    case disputeResolution = "Dispute resolution"
    case changes = "Changes to terms"
    
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
            Welcome to HopMe, a platform for sharing rides. These Terms of Service ("Terms") govern your access to and use of the HopMe application and services.
            
            By using our services, you agree to these terms. If you do not agree to any part of these terms, do not use our application.
            
            The HopMe platform consists of mobile applications, websites, and all related services that allow users to book rides and drivers to offer transportation services.
            """
        case .accountTerms:
            return """
            To use HopMe, you must create an account and provide accurate, complete, and up-to-date information. You are responsible for maintaining the security of your account and password.
            
            You must be at least 18 years old to create an account. You guarantee that all information you provide is true and that you will update it regularly.
            
            You are not allowed to:
            • Share your account with others
            • Use someone else's account
            • Create a fake account
            • Use automated systems to access
            """
        case .serviceUsage:
            return """
            The HopMe platform connects passengers with drivers. As a user, you agree to use the services only for legitimate purposes and in compliance with all applicable laws and regulations.
            
            As a passenger, you can:
            • Reserve rides through the application
            • Rate drivers
            • Contact support for assistance
            
            HopMe reserves the right to suspend or terminate access to users who violate these terms.
            """
        case .payments:
            return """
            All payment transactions are processed through our secure platform. We accept various payment methods including credit/debit cards and cash.
            
            Prices are determined based on distance, time, and other factors. The final price will be displayed before confirming the reservation.
            
            Cancellations may be charged in accordance with our cancellation policy. Refund processing takes place within 5-7 business days.
            """
        case .userResponsibilities:
            return """
            As a user of the HopMe platform, you are responsible for:
            
            • Respecting drivers and other users
            • Accurate arrival at the agreed location and time
            • Maintaining the vehicle and driver's property
            • Adhering to safety regulations (using a safety belt)
            • Not disturbing the driver during the ride
            
            Unprofessional behavior may result in account suspension.
            """
        case .driverResponsibilities:
            return """
            Drivers on the HopMe platform are independent contractors and are responsible for:
            
            • Possession of a valid driver's license and vehicle registration
            • Maintaining the vehicle in a safe working condition
            • Providing professional and safe transportation services
            • Respecting passengers and their privacy
            • Adhering to all traffic laws and regulations
            
            HopMe reserves the right to verify drivers and their vehicles.
            """
        case .intellectualProperty:
            return """
            The content of the HopMe application, including text, images, logos, design, and code, is protected by copyright and belongs to HopMe or our licensors.
            
            You are not allowed to:
            • Copy or reproduce the application content
            • Modify or create derivative works
            • Use our trademarks without permission
            • Reverse engineering the application
            
            All rights not expressly granted by these terms are reserved by HopMe.
            """
        case .privacy:
            return """
            Privacy is important to us. We collect, use, and protect your personal data in accordance with our Privacy Policy.
            
            Collected data includes:
            • Personal information (name, email, phone)
            • Location data
            • Transaction history
            • Application usage data
            
            For complete details, please review our Privacy Policy.
            """
        case .liability:
            return """
            The HopMe platform serves as an intermediary between passengers and drivers. We do not guarantee availability, quality, or safety of transportation services.
            
            In accordance with applicable law, HopMe is not liable for:
            • Direct, indirect, or incidental damages
            • Loss of income or data
            • Injuries or damages incurred during the ride
            • Actions of independent drivers
            
            Your total liability is limited to the amount paid for the specific service.
            """
        case .termination:
            return """
            You can close your account at any time through the application settings or by contacting support.
            
            HopMe reserves the right to suspend or terminate your account if:
            • You violate these terms of service
            • You engage in fraudulent activities
            • You provide false information
            • You fail to pay your obligations
            
            After termination, you will lose access to the application and all related services.
            """
        case .disputeResolution:
            return """
            In the event of a dispute arising from the use of HopMe services, we first recommend that you contact our support to resolve the issue.
            
            If the dispute cannot be resolved, we agree to:
            • Voluntary mediation
            • Arbitration if necessary
            • Application of Serbian law
            
            Any legal proceedings must be initiated within one year of the dispute arising.
            """
        case .changes:
            return """
            HopMe reserves the right to modify these terms of service at any time. Changes will take effect immediately upon publication in the application.
            
            Your continued use of the application after changes constitutes acceptance of the new terms.
            
            We recommend that you regularly check these terms for any updates.
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
                            Text("Important")
                                .font(.headline)
                            Text("Please carefully read this section as it contains important legal information.")
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
