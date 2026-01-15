import SwiftUI

struct WaypointInput: View {
    let index: Int
    @Binding var location: String
    @Binding var estimatedTime: Date?
    let onRemove: () -> Void
    
    @State private var showTimePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Stop \(index)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            CustomTextField(
                icon: "mappin.circle.fill",
                placeholder: "Location",
                text: $location
            )
            
            Toggle("Add estimated time", isOn: Binding(
                get: { estimatedTime != nil },
                set: { if !$0 { estimatedTime = nil } else {
                    estimatedTime = Date().addingTimeInterval(1800)
                }}
            ))
            .font(.caption)
            .padding(.horizontal)
            
            if estimatedTime != nil {
                DatePicker(
                    "Estimated time",
                    selection: Binding(
                        get: { estimatedTime ?? Date() },
                        set: { estimatedTime = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
