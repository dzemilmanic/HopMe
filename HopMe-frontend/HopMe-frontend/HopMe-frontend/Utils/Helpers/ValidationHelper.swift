import Foundation

struct ValidationHelper {
    static func validateEmail(_ email: String) -> ValidationResult {
        guard !email.isEmpty else {
            return .failure("Email je obavezan")
        }
        
        guard email.isValidEmail else {
            return .failure("Unesite validnu email adresu")
        }
        
        return .success
    }
    
    static func validatePassword(_ password: String) -> ValidationResult {
        guard !password.isEmpty else {
            return .failure("Lozinka je obavezna")
        }
        
        guard password.count >= 6 else {
            return .failure("Lozinka mora imati minimum 6 karaktera")
        }
        
        return .success
    }
    
    static func validatePhone(_ phone: String) -> ValidationResult {
        guard !phone.isEmpty else {
            return .failure("Telefon je obavezan")
        }
        
        guard phone.isValidPhone else {
            return .failure("Unesite validan broj telefona")
        }
        
        return .success
    }
    
    static func validateName(_ name: String, field: String) -> ValidationResult {
        guard !name.isEmpty else {
            return .failure("\(field) je obavezan")
        }
        
        guard name.count >= 2 else {
            return .failure("\(field) mora imati minimum 2 karaktera")
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
