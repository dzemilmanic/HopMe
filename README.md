# 🚗 HopMe - Ride Sharing Platform

<div align="center">

![Platform](https://img.shields.io/badge/Platform-iOS-blue?style=for-the-badge&logo=apple)
![Backend](https://img.shields.io/badge/Backend-Node.js-green?style=for-the-badge&logo=node.js)
![Database](https://img.shields.io/badge/Database-PostgreSQL-blue?style=for-the-badge&logo=postgresql)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**A modern ride-sharing platform connecting drivers with passengers traveling the same route**

[Features](#-features) • [Tech Stack](#-tech-stack) • [Getting Started](#-getting-started) • [API Documentation](#-api-documentation) • [Architecture](#-architecture)

</div>

---

## 📖 About

HopMe is a comprehensive ride-sharing solution designed to make carpooling easy and efficient. Whether you're a driver with empty seats or a passenger looking for a ride, HopMe connects you with people traveling the same route. Built with modern technologies and best practices, HopMe offers a seamless experience across iOS devices with a powerful backend infrastructure.

---

## ✨ Features

### 👤 For Passengers

- 🔍 **Smart Search** - Find rides by origin, destination, date, and time
- 📍 **Real-time Tracking** - View ride routes and driver locations
- 🎫 **Easy Booking** - Reserve seats with instant confirmation
- ⭐ **Rating System** - Rate drivers and share your experience
- 📱 **Notifications** - Real-time updates on booking status
- 💳 **Testimonials** - Read and write reviews about drivers

### 🚘 For Drivers

- ➕ **Create Rides** - Post rides with detailed information
- 🚗 **Vehicle Management** - Add and manage multiple vehicles with photos
- 📩 **Booking Requests** - Receive and manage passenger requests
- ✅ **Approve/Reject** - Full control over who joins your ride
- 📊 **Trip History** - Track all your rides and earnings
- ⭐ **Build Reputation** - Receive ratings and testimonials from passengers

### 🛡️ Security & Authentication

- 🔐 **JWT Authentication** - Secure token-based authentication
- 📧 **Email Verification** - Verify users via email (Resend integration)
- 🔑 **Password Recovery** - Secure forgot password flow
- 🔒 **Profile Privacy** - Granular privacy controls
- 👁️ **Account Security** - Change password and manage sessions

### 🎯 Additional Features

- 🗺️ **Maps Integration** - Geocoding, reverse geocoding, and route calculation
- 🌐 **Multi-language Support** - Currently supports English and Serbian
- 📸 **Image Uploads** - Vehicle photos stored on Azure Blob Storage
- 📊 **Admin Dashboard** - Comprehensive admin controls for platform management
- 🔔 **Push Notifications** - Real-time updates for bookings and ride changes

---

## 🏗 Tech Stack

### 🔙 Backend

| Technology | Purpose |
|------------|---------|
| **Node.js** | Runtime environment |
| **Express.js** | Web framework |
| **PostgreSQL** | Primary database |
| **JWT** | Authentication & authorization |
| **Resend** | Email service |
| **Azure Blob Storage** | Image storage |
| **Swagger** | API documentation |
| **bcryptjs** | Password hashing |
| **Multer** | File upload handling |
| **node-geocoder** | Geocoding services |

### 📱 Frontend (iOS)

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | UI framework |
| **Swift 5+** | Programming language |
| **MVVM** | Architecture pattern |
| **URLSession** | Networking |
| **Keychain** | Secure token storage |
| **MapKit** | Maps and location |
| **Combine** | Reactive programming |

---

## 📦 Project Structure

```
HopMe/
│
├── 🔙 HopMe-backend/               # Node.js Backend
│   ├── src/
│   │   ├── config/                 # Database & app config
│   │   ├── controllers/            # Business logic (9 controllers)
│   │   │   ├── AdminController.js
│   │   │   ├── AuthController.js
│   │   │   ├── BookingController.js
│   │   │   ├── MapsController.js
│   │   │   ├── NotificationController.js
│   │   │   ├── RatingController.js
│   │   │   ├── RideController.js
│   │   │   ├── TestimonialController.js
│   │   │   └── UserController.js
│   │   ├── middleware/             # Auth, validation, error handling
│   │   ├── models/                 # Database models (8 models)
│   │   │   ├── Booking.js
│   │   │   ├── Notification.js
│   │   │   ├── Rating.js
│   │   │   ├── Ride.js
│   │   │   ├── Testimonial.js
│   │   │   ├── User.js
│   │   │   ├── Vehicle.js
│   │   │   └── VerificationToken.js
│   │   ├── routes/                 # API routes
│   │   ├── services/               # External services (email, storage)
│   │   └── utils/                  # Helper functions
│   ├── scripts/                    # Database migration scripts
│   ├── .env.example                # Environment variables template
│   ├── server.js                   # App entry point
│   └── package.json
│
└── 📱 HopMe-frontend/              # SwiftUI iOS App
    └── HopMe-frontend/
        └── HopMe-frontend/
            ├── Assets.xcassets/    # App images & icons
            ├── Components/         # Reusable UI components (37 components)
            ├── Core/               # Core utilities
            ├── Models/             # Data models (33 models)
            ├── Services/           # API services (12 services)
            ├── ViewModels/         # MVVM view models (23 view models)
            ├── Views/              # SwiftUI views (29 views)
            │   ├── Auth/           # Login, Register, ForgotPassword
            │   ├── Booking/        # Booking management
            │   ├── Home/           # Home & Search
            │   ├── Main/           # Tab bar & navigation
            │   ├── Notifications/  # Notification center
            │   ├── Profile/        # User profile & settings
            │   ├── Rating/         # Rating & reviews
            │   ├── Rides/          # Ride creation & management
            │   ├── Settings/       # App settings
            │   └── Vehicles/       # Vehicle management
            ├── Utils/              # Helper utilities
            ├── Environment.swift   # API configuration
            └── HopMe_frontendApp.swift
```

---

## 🚀 Getting Started

### Prerequisites

- **Backend:**
  - Node.js 16+ and npm
  - PostgreSQL database (hosted or local)
  - Resend account for email service
  - Azure Storage account for image uploads

- **Frontend:**
  - macOS with Xcode 14+
  - iOS 15.0+ simulator or device
  - Apple Developer account (for physical device testing)

### 🔙 Backend Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/HopMe.git
   cd HopMe/HopMe-backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```

4. **Edit `.env` file with your credentials:**
   ```env
   # Server Configuration
   PORT=5000
   NODE_ENV=development

   # PostgreSQL Database
   DB_HOST=your-postgres-host.com
   DB_PORT=5432
   DB_NAME=your_database_name
   DB_USER=your_username
   DB_PASSWORD=your_password
   DB_SSL=true

   # JWT Configuration
   JWT_SECRET=your_super_secret_key_min_32_characters
   JWT_EXPIRE=7d

   # Email (Resend)
   RESEND_API_KEY=re_your_api_key
   EMAIL_FROM=noreply@yourdomain.com

   # Azure Blob Storage
   AZURE_STORAGE_CONNECTION_STRING=your_connection_string
   AZURE_STORAGE_CONTAINER_NAME=vehicle-images

   # Frontend URL
   FRONTEND_URL=http://localhost:3000
   ```

5. **Run database migrations**
   ```bash
   npm run migrate
   ```

6. **Create admin user (optional)**
   ```bash
   npm run create-admin
   ```

7. **Start the server**
   ```bash
   # Development mode (with auto-reload)
   npm run dev

   # Production mode
   npm start
   ```

8. **Verify the backend is running**
   - Health check: `http://localhost:5000/health`
   - API docs: `http://localhost:5000/api-docs`

### 📱 iOS App Setup

1. **Navigate to frontend directory**
   ```bash
   cd ../HopMe-frontend/HopMe-frontend/HopMe-frontend
   ```

2. **Configure API endpoint**
   
   Open `Environment.swift` and update the backend URL if needed:
   ```swift
   var baseURL: String {
       switch self {
       case .development:
           return "http://localhost:5000/api"  // Local backend
           // return "https://your-backend.up.railway.app/api"  // Hosted backend
       case .production:
           return "https://your-backend.up.railway.app/api"
       }
   }
   ```

3. **Open in Xcode**
   ```bash
   open ../HopMe-frontend.xcodeproj
   ```
   Or open the `.xcodeproj` file manually in Xcode.

4. **Select a simulator/device**
   - Choose your target device from the Xcode toolbar
   - Recommended: iPhone 14 Pro or newer

5. **Run the app**
   - Press `⌘ + R` or click the Play button
   - Wait for the build to complete

---

## 📡 API Documentation

The HopMe backend provides a comprehensive RESTful API with Swagger documentation.

### Access API Documentation

**Local:** `http://localhost:5000/api-docs`  
**Production:** `https://your-backend.up.railway.app/api-docs`

### Main API Endpoints

#### 🔐 Authentication
```
POST   /api/auth/register              # Register new user
POST   /api/auth/login                 # Login user
POST   /api/auth/verify-email          # Verify email address
POST   /api/auth/forgot-password       # Request password reset
POST   /api/auth/reset-password        # Reset password with token
POST   /api/auth/resend-verification   # Resend verification email
```

#### 👤 User Management
```
GET    /api/user/profile               # Get current user profile
PUT    /api/user/profile               # Update profile
POST   /api/user/change-password       # Change password
GET    /api/user/vehicles              # Get user vehicles
POST   /api/user/vehicles              # Add new vehicle
PUT    /api/user/vehicles/:id          # Update vehicle
DELETE /api/user/vehicles/:id          # Delete vehicle
POST   /api/user/profile-picture       # Upload profile picture
DELETE /api/user/profile-picture       # Remove profile picture
```

#### 🚗 Rides
```
GET    /api/rides/search               # Search available rides
POST   /api/rides                      # Create new ride
GET    /api/rides/:rideId              # Get ride details
GET    /api/rides/my-rides             # Get user's rides as driver
POST   /api/rides/:rideId/publish      # Publish ride
POST   /api/rides/:rideId/cancel       # Cancel ride
POST   /api/rides/:rideId/complete     # Mark ride as completed
```

#### 🎫 Bookings
```
POST   /api/bookings                   # Create booking
GET    /api/bookings/my-bookings       # Get user's bookings
GET    /api/bookings/:bookingId        # Get booking details
POST   /api/bookings/:bookingId/cancel # Cancel booking
GET    /api/bookings/ride/:rideId      # Get bookings for a ride (driver)
POST   /api/bookings/:bookingId/approve   # Approve booking (driver)
POST   /api/bookings/:bookingId/reject    # Reject booking (driver)
```

#### ⭐ Ratings
```
POST   /api/ratings                    # Create rating
GET    /api/ratings/user/:userId       # Get user's ratings
GET    /api/ratings/my-ratings         # Get ratings I received
GET    /api/ratings/all-my-ratings     # Get all my ratings (given & received)
```

#### 💬 Testimonials
```
GET    /api/testimonials               # Get all testimonials
POST   /api/testimonials               # Create testimonial
GET    /api/testimonials/my            # Get my testimonial
PUT    /api/testimonials/my            # Update my testimonial
DELETE /api/testimonials/my            # Delete my testimonial
```

#### 🔔 Notifications
```
GET    /api/notifications              # Get all notifications
GET    /api/notifications/unread-count # Get unread count
POST   /api/notifications/:id/read     # Mark as read
POST   /api/notifications/mark-all-read # Mark all as read
DELETE /api/notifications/:id          # Delete notification
```

#### 🗺️ Maps
```
GET    /api/maps/geocode               # Convert address to coordinates
GET    /api/maps/reverse               # Convert coordinates to address
POST   /api/maps/route                 # Get route between points
GET    /api/maps/distance              # Calculate distance
GET    /api/maps/search                # Search locations
GET    /api/maps/nearby                # Find nearby places
```

#### 🛡️ Admin
```
GET    /api/admin/users                # Get all users
PUT    /api/admin/users/:id            # Update user
DELETE /api/admin/users/:id            # Delete user
GET    /api/admin/rides                # Get all rides
DELETE /api/admin/rides/:id            # Delete ride
GET    /api/admin/statistics           # Get platform statistics
```

---

## 🏛️ Architecture

### Backend Architecture

```
Client Request
     ↓
Express Router
     ↓
Middleware (Auth, Validation)
     ↓
Controller (Business Logic)
     ↓
Model (Database Queries)
     ↓
PostgreSQL Database
     ↓
Response Transformer (camelCase)
     ↓
Client Response
```

**Key Patterns:**
- **MVC Pattern** - Separation of concerns
- **Middleware Chain** - Authentication, validation, error handling
- **Response Transformer** - Automatic snake_case to camelCase conversion
- **JWT Authentication** - Stateless authentication
- **Input Validation** - express-validator for request validation

### Frontend Architecture (MVVM)

```
View (SwiftUI)
  ↓  ↑
ViewModel (Business Logic)
  ↓  ↑
Service (API Calls)
  ↓  ↑
Model (Data Structures)
```

**Key Patterns:**
- **MVVM** - Clean separation of UI and logic
- **ObservableObject** - Reactive state management
- **Dependency Injection** - Services injected into ViewModels
- **Keychain Storage** - Secure token persistence
- **Environment Objects** - Shared state across views

---

## 🔒 Security Features

- ✅ JWT token-based authentication
- ✅ Bcrypt password hashing
- ✅ Email verification for new accounts
- ✅ Secure password reset flow
- ✅ Input validation and sanitization
- ✅ SQL injection protection (parameterized queries)
- ✅ CORS protection
- ✅ Rate limiting on sensitive endpoints
- ✅ Secure file upload validation
- ✅ Environment variables for secrets

---

## 🧪 Testing

### Backend Testing
```bash
# Run tests
npm test

# Run with coverage
npm run test:coverage
```

### iOS Testing
- Open Xcode
- Press `⌘ + U` to run all tests
- UI tests and unit tests available

---

## 🚀 Deployment

### Backend Deployment (Railway/Heroku)

1. **Set environment variables** in your hosting platform dashboard
2. **Deploy:**
   ```bash
   git push railway main
   # or
   git push heroku main
   ```
3. **Run migrations** on the hosted database

### iOS App Deployment

1. **Configure signing** in Xcode
2. **Archive the app** (Product → Archive)
3. **Upload to App Store Connect**
4. **Submit for review**

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- **Backend:** ESLint configuration (run `npm run lint`)
- **Frontend:** SwiftLint (follow Swift style guide)

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

**HopMe Team** - *Initial work*

---

## 🙏 Acknowledgments

- Built with ❤️ using modern web and mobile technologies
- Inspired by the need for efficient carpooling solutions
- Special thanks to all contributors and testers

---

## 📧 Support

For support, email support@hopme.app or open an issue in this repository.

---

<div align="center">

**⭐ Star this repo if you find it helpful!**

Made with ❤️ by the HopMe Team

</div>
