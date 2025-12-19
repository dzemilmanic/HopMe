import SwiftUI

struct ProgressSteps: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                ZStack {
                    Circle()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                    
                    if step < currentStep {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.white)
                    } else {
                        Text("\(step)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(step == currentStep ? .white : .gray)
                    }
                }
                
                if step < totalSteps {
                    Rectangle()
                        .fill(step < currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
        .padding(.vertical, 20)
    }
}
