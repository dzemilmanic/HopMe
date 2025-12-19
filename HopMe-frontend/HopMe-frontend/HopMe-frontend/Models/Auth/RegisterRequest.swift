struct RegisterRequest: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let phone: String
    let vehicleType: String?
    let brand: String?
    let model: String?
}
	
