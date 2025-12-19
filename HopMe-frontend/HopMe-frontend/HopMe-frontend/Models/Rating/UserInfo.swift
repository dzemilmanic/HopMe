struct UserInfo: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let profileImage: String?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        return "\(first)\(last)".uppercased()
    }
}
