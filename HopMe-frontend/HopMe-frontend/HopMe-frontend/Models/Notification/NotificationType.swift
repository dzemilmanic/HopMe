enum NotificationType: String, Codable {
    case newBooking = "new_booking"
    case bookingAccepted = "booking_accepted"
    case bookingRejected = "booking_rejected"
    case bookingCancelled = "booking_cancelled"
    case rideCancelled = "ride_cancelled"
    case rideCompleted = "ride_completed"
    case newRating = "new_rating"
    
    var icon: String {
        switch self {
        case .newBooking: return "car.fill"
        case .bookingAccepted: return "checkmark.circle.fill"
        case .bookingRejected: return "xmark.circle.fill"
        case .bookingCancelled: return "xmark.octagon.fill"
        case .rideCancelled: return "exclamationmark.triangle.fill"
        case .rideCompleted: return "flag.checkered"
        case .newRating: return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .newBooking: return "blue"
        case .bookingAccepted: return "green"
        case .bookingRejected, .bookingCancelled, .rideCancelled: return "red"
        case .rideCompleted: return "orange"
        case .newRating: return "yellow"
        }
    }
}
