enum APIEndpoint {
    // Auth
    case login
    case registerPassenger
    case registerDriver
    case verifyEmail(token: String)
    case requestPasswordReset
    case resetPassword
    case addDriverRole
    
    // User
    case profile
    case updateProfile
    case vehicles
    case vehicle(id: Int)
    case vehicleImages(vehicleId: Int)
    case deleteVehicleImage(vehicleId: Int, imageId: Int)
    
    // Rides
    case searchRides(from: String?, to: String?, date: String?, seats: Int?, page: Int?)
    case ride(id: Int)
    case createRide
    case myRides
    case updateRide(id: Int)
    case cancelRide(id: Int)
    case startRide(id: Int)
    case completeRide(id: Int)
    
    // Bookings
    case createBooking
    case myBookings
    case booking(id: Int)
    case cancelBooking(id: Int)
    case rideBookings(rideId: Int)
    case acceptBooking(id: Int)
    case rejectBooking(id: Int)
    
    // Ratings
    case createRating
    case userRatings(userId: Int)
    case myRatings
    
    // Notifications
    case notifications
    case unreadCount
    case markAsRead(id: Int)
    case markAllAsRead
    case deleteNotification(id: Int)
    
    // Maps
    case geocode(address: String)
    case reverseGeocode(lat: Double, lng: Double)
    case route
    case distance(lat1: Double, lng1: Double, lat2: Double, lng2: Double)
    case searchLocations(query: String, limit: Int?)
    
    var path: String {
        switch self {
        // Auth
        case .login: return "/auth/login"
        case .registerPassenger: return "/auth/register/passenger"
        case .registerDriver: return "/auth/register/driver"
        case .verifyEmail(let token): return "/auth/verify-email?token=\(token)"
        case .requestPasswordReset: return "/auth/request-password-reset"
        case .resetPassword: return "/auth/reset-password"
        case .addDriverRole: return "/auth/add-driver-role"
        
        // User
        case .profile: return "/user/profile"
        case .updateProfile: return "/user/profile"
        case .vehicles: return "/user/vehicles"
        case .vehicle(let id): return "/user/vehicles/\(id)"
        case .vehicleImages(let vehicleId): return "/user/vehicles/\(vehicleId)/images"
        case .deleteVehicleImage(let vehicleId, let imageId):
            return "/user/vehicles/\(vehicleId)/images/\(imageId)"
        
        // Rides
        case .searchRides(let from, let to, let date, let seats, let page):
            var query = "/rides/search?"
            if let from = from { query += "from=\(from)&" }
            if let to = to { query += "to=\(to)&" }
            if let date = date { query += "date=\(date)&" }
            if let seats = seats { query += "seats=\(seats)&" }
            if let page = page { query += "page=\(page)&" }
            return query
            
        case .ride(let id): return "/rides/\(id)"
        case .createRide: return "/rides"
        case .myRides: return "/rides/driver/my-rides"
        case .updateRide(let id): return "/rides/\(id)"
        case .cancelRide(let id): return "/rides/\(id)/cancel"
        case .startRide(let id): return "/rides/\(id)/start"
        case .completeRide(let id): return "/rides/\(id)/complete"
        
        // Bookings
        case .createBooking: return "/bookings"
        case .myBookings: return "/bookings/my-bookings"
        case .booking(let id): return "/bookings/\(id)"
        case .cancelBooking(let id): return "/bookings/\(id)/cancel"
        case .rideBookings(let rideId): return "/bookings/ride/\(rideId)"
        case .acceptBooking(let id): return "/bookings/\(id)/accept"
        case .rejectBooking(let id): return "/bookings/\(id)/reject"
        
        // Ratings
        case .createRating: return "/ratings"
        case .userRatings(let userId): return "/ratings/user/\(userId)"
        case .myRatings: return "/ratings/my-ratings"
        
        // Notifications
        case .notifications: return "/notifications"
        case .unreadCount: return "/notifications/unread-count"
        case .markAsRead(let id): return "/notifications/\(id)/read"
        case .markAllAsRead: return "/notifications/mark-all-read"
        case .deleteNotification(let id): return "/notifications/\(id)"
        
        // Maps
        case .geocode(let address): return "/maps/geocode?address=\(address)"
        case .reverseGeocode(let lat, let lng): return "/maps/reverse?lat=\(lat)&lng=\(lng)"
        case .route: return "/maps/route"
        case .distance(let lat1, let lng1, let lat2, let lng2):
            return "/maps/distance?lat1=\(lat1)&lng1=\(lng1)&lat2=\(lat2)&lng2=\(lng2)"
        case .searchLocations(let query, let limit):
            var path = "/maps/search?query=\(query)"
            if let limit = limit { path += "&limit=\(limit)" }
            return path
        }
    }
}
