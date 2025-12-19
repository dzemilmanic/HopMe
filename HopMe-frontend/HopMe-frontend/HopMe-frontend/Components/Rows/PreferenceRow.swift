import SwiftUI

struct PreferenceRow: View {
    let icon: String
    let title: String
    let value: Bool
    let activeColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(value ? activeColor : .gray)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(value ? .primary : .gray)
            
            Spacer()
            
            Image(systemName: value ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(value ? .green : .red)
        }
    }
}
