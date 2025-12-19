import Foundation

extension String {
    // MARK: - Validation
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidPhone: Bool {
        let phoneRegex = "^[+]?[0-9]{9,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
    
    // MARK: - Formatting
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Encoding
    var urlEncoded: String? {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    // MARK: - Serbian Latin/Cyrillic
    var toLatinSerbian: String {
        let mapping: [Character: String] = [
            "А": "A", "Б": "B", "В": "V", "Г": "G", "Д": "D",
            "Ђ": "Đ", "Е": "E", "Ж": "Ž", "З": "Z", "И": "I",
            "Ј": "J", "К": "K", "Л": "L", "Љ": "Lj", "М": "M",
            "Н": "N", "Њ": "Nj", "О": "O", "П": "P", "Р": "R",
            "С": "S", "Т": "T", "Ћ": "Ć", "У": "U", "Ф": "F",
            "Х": "H", "Ц": "C", "Ч": "Č", "Џ": "Dž", "Ш": "Š"
        ]
        
        return self.map { mapping[$0] ?? String($0) }.joined()
    }
}
