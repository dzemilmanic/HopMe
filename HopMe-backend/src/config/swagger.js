import swaggerJsdoc from 'swagger-jsdoc';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'HopMe API',
      version: '1.0.0',
      description: 'API documentation for HopMe platform',
      contact: {
        name: 'HopMe Support',
        email: 'info@hopme.rs',
      },
    },
    servers: [
      {
        url: 'http://localhost:5000/api',
        description: 'Development server',
      },
      {
        url: 'https://api.hopme.rs/api',
        description: 'Production server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        User: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            email: { type: 'string', format: 'email' },
            firstName: { type: 'string' },
            lastName: { type: 'string' },
            phone: { type: 'string' },
            profileImageUrl: { type: 'string', nullable: true },
            roles: {
              type: 'array',
              items: {
                type: 'string',
                enum: ['putnik', 'vozac', 'admin'],
              },
            },
            accountStatus: {
              type: 'string',
              enum: ['pending', 'approved', 'rejected', 'suspended'],
            },
            isEmailVerified: { type: 'boolean' },
          },
        },
        Ride: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            driverId: { type: 'integer' },
            vehicleId: { type: 'integer' },
            departureLocation: { type: 'string' },
            arrivalLocation: { type: 'string' },
            departureTime: { type: 'string', format: 'date-time' },
            availableSeats: { type: 'integer' },
            pricePerSeat: { type: 'number', format: 'double' },
            status: {
              type: 'string',
              enum: ['scheduled', 'in_progress', 'completed', 'cancelled'],
            },
          },
        },
        Booking: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            rideId: { type: 'integer' },
            passengerId: { type: 'integer' },
            seatsBooked: { type: 'integer' },
            totalPrice: { type: 'number' },
            status: {
              type: 'string',
              enum: ['pending', 'accepted', 'rejected', 'cancelled', 'completed'],
            },
          },
        },
        Error: {
          type: 'object',
          properties: {
            message: { type: 'string' },
          },
        },
      },
    },
    tags: [
      { name: 'Auth', description: 'Authentication and registration' },
      { name: 'Rides', description: 'Manage rides' },
      { name: 'Bookings', description: 'Manage bookings' },
      { name: 'Ratings', description: 'Rating system' },
      { name: 'Notifications', description: 'Notifications' },
      { name: 'Admin', description: 'Admin operations' },
      { name: 'User', description: 'User profile' },
      { name: 'Maps', description: 'Maps, routes and geolocation' },
    ],
  },
  apis: ['./src/routes/*.js'], // Path to the API routes
};

const swaggerSpec = swaggerJsdoc(options);

export default swaggerSpec;