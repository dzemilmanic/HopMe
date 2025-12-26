/**
 * Helper utilities for formatting API responses
 * Ensures consistent camelCase format and proper array parsing for iOS
 */

// Parse PostgreSQL array string to proper JavaScript array
export const parsePostgresArray = (value) => {
  if (Array.isArray(value)) return value;
  if (typeof value === 'string') {
    return value.replace(/[{}]/g, '').split(',').filter(r => r.trim());
  }
  return [];
};

// Format user object for iOS response
export const formatUserResponse = (user) => {
  if (!user) return null;
  
  return {
    id: user.id,
    email: user.email,
    firstName: user.first_name || user.firstName,
    lastName: user.last_name || user.lastName,
    phone: user.phone,
    dateOfBirth: user.date_of_birth || user.dateOfBirth,
    bio: user.bio,
    profileImageUrl: user.profile_image_url || user.profileImageUrl,
    roles: parsePostgresArray(user.roles),
    accountStatus: user.account_status || user.accountStatus,
    isEmailVerified: user.is_email_verified ?? user.isEmailVerified,
    isPhoneVerified: user.is_phone_verified ?? user.isPhoneVerified,
    approvedBy: user.approved_by || user.approvedBy,
    approvedAt: user.approved_at || user.approvedAt,
    createdAt: user.created_at || user.createdAt,
    updatedAt: user.updated_at || user.updatedAt,
    vehicles: user.vehicles || []
  };
};

// Format vehicle object for iOS response
export const formatVehicleResponse = (vehicle) => {
  if (!vehicle) return null;
  
  return {
    id: vehicle.id,
    userId: vehicle.user_id || vehicle.userId,
    vehicleType: vehicle.vehicle_type || vehicle.vehicleType,
    brand: vehicle.brand,
    model: vehicle.model,
    year: vehicle.year,
    licensePlate: vehicle.license_plate || vehicle.licensePlate,
    color: vehicle.color,
    isActive: vehicle.is_active ?? vehicle.isActive,
    createdAt: vehicle.created_at || vehicle.createdAt,
    images: vehicle.images || []
  };
};

// Format ride object for iOS response
export const formatRideResponse = (ride) => {
  if (!ride) return null;
  
  return {
    id: ride.id,
    driver: ride.driver ? formatUserResponse(ride.driver) : null,
    driverId: ride.driver_id || ride.driverId,
    vehicleId: ride.vehicle_id || ride.vehicleId,
    vehicle: ride.vehicle ? formatVehicleResponse(ride.vehicle) : null,
    fromCity: ride.from_city || ride.fromCity,
    toCity: ride.to_city || ride.toCity,
    fromAddress: ride.from_address || ride.fromAddress,
    toAddress: ride.to_address || ride.toAddress,
    fromLat: ride.from_lat || ride.fromLat,
    fromLng: ride.from_lng || ride.fromLng,
    toLat: ride.to_lat || ride.toLat,
    toLng: ride.to_lng || ride.toLng,
    departureTime: ride.departure_time || ride.departureTime,
    estimatedArrival: ride.estimated_arrival || ride.estimatedArrival,
    price: ride.price,
    availableSeats: ride.available_seats || ride.availableSeats,
    totalSeats: ride.total_seats || ride.totalSeats,
    status: ride.status,
    notes: ride.notes,
    allowPets: ride.allow_pets ?? ride.allowPets,
    allowSmoking: ride.allow_smoking ?? ride.allowSmoking,
    allowLuggage: ride.allow_luggage ?? ride.allowLuggage,
    autoApprove: ride.auto_approve ?? ride.autoApprove,
    waypoints: ride.waypoints || [],
    createdAt: ride.created_at || ride.createdAt
  };
};

// Format booking object for iOS response
export const formatBookingResponse = (booking) => {
  if (!booking) return null;
  
  return {
    id: booking.id,
    rideId: booking.ride_id || booking.rideId,
    passengerId: booking.passenger_id || booking.passengerId,
    passenger: booking.passenger ? formatUserResponse(booking.passenger) : null,
    ride: booking.ride ? formatRideResponse(booking.ride) : null,
    seats: booking.seats,
    status: booking.status,
    pickupLocation: booking.pickup_location || booking.pickupLocation,
    dropoffLocation: booking.dropoff_location || booking.dropoffLocation,
    createdAt: booking.created_at || booking.createdAt,
    updatedAt: booking.updated_at || booking.updatedAt
  };
};
