import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyleType = .primary
    var isLoading: Bool = false
    var disabled: Bool = false
    
    enum ButtonStyleType {
        case primary
        case secondary
        case outline
        case danger
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .blue
            case .secondary: return .green
            case .outline: return .clear
            case .danger: return .red
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .secondary, .danger: return .white
            case .outline: return .blue
            }
        }
        
        var borderColor: Color {
            switch self {
            case .outline: return .blue
            default: return .clear
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                }
            }
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style.borderColor, lineWidth: 2)
            )
        }
        .disabled(disabled || isLoading)
        .opacity(disabled ? 0.6 : 1)
    }
}
