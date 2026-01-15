import Foundation

struct ValidationHelper {
    static func validateEmail(_ email: String) -> ValidationResult {
        guard !email.isEmpty else {
            return .failure("Email is required")
        }
        
        guard email.isValidEmail else {
            return .failure("Invalid email address")
        }
        
        return .success
    }
    
    static func validatePassword(_ password: String) -> ValidationResult {
        guard !password.isEmpty else {
            return .failure("Password is required")
        }
        
        guard password.count >= 6 else {
            return .failure("Password must have at least 6 characters")
        }
        
        return .success
    }
    
    static func validatePhone(_ phone: String) -> ValidationResult {
        guard !phone.isEmpty else {
            return .failure("Phone number is required")
        }
        
        guard phone.isValidPhone else {
            return .failure("Invalid phone number")
        }
        
        return .success
    }
    
    static func validateName(_ name: String, field: String) -> ValidationResult {
        guard !name.isEmpty else {
            return .failure("\(field) is required")
        }
        
        guard name.count >= 2 else {
            return .failure("\(field) must have at least 2 characters")
        }
        
        return .success
    }
}

enum ValidationResult {
    case success
    case failure(String)
    
    var isValid: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .failure(let message) = self {
            return message
        }
        return nil
    }
}
