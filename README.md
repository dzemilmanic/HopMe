# 🚗 HopMe - Ride Sharing Platform

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
   git clone https://github.com/dzemilmanic/HopMe.git
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

## 👥 Author

**Džemil Manić** 

---

## 🙏 Acknowledgments

- Built with ❤️ using modern web and mobile technologies
- Inspired by the need for efficient carpooling solutions
- Special thanks to all contributors and testers

---

<div align="center">

**⭐ Star this repo if you find it helpful!**

Made with ❤️ by the HopMe Team

</div>
