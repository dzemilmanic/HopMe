# 🚗 HopMe -- Ride Sharing Mobile App

HopMe is a modern ride‑sharing platform that connects **drivers** who
have empty seats with **passengers** traveling the same route.\
This repository includes:

-   🟦 **Node.js Backend**
-   🍏 **SwiftUI iOS Application**

------------------------------------------------------------------------

## ✨ Features

### 👤 Passengers

-   🔍 Search available rides\
-   🎫 Book seats\
-   ⭐ Rate drivers after the ride

### 🚘 Drivers

-   ➕ Create rides\
-   📩 Receive and manage booking requests\
-   ✔ Approve or reject passengers

### 🛠 Admin

-   🧩 Manage the entire platform\
-   👥 User management\
-   🚗 Ride moderation

------------------------------------------------------------------------

## 🏗 Tech Stack

### 🔙 Backend (Node.js)

-   Node.js\
-   Express\
-   JWT Authentication\
-   PostgreSQL\
-   REST API Architecture

### 📱 Frontend (iOS -- SwiftUI)

-   Swift\
-   SwiftUI\
-   MVVM Architecture\
-   URLSession networking\
-   Secure local storage

------------------------------------------------------------------------

## 📦 Project Structure

    HopMe/
    │
    ├── HopMe-backend/
    │   ├── src/
    │   ├── controllers/
    │   ├── models/
    │   ├── routes/
    │   └── app.js
    │
    └── HopMe-frontend/
        ├── Views/
        ├── ViewModels/
        ├── Models/
        └── HopMeApp.swift

------------------------------------------------------------------------

## 🚀 Getting Started

### 🟦 Backend Setup

``` bash
cd HopMe-backend
npm install
npm run dev
```

### 🍏 iOS App Setup

Open the `HopMe-frontend` folder in Xcode and run the app on any
simulator or physical device.

------------------------------------------------------------------------

## 🔐 Authentication Flow

-   User registers → receives token\
-   User logs in → token persists in Keychain (iOS)\
-   All protected endpoints require valid JWT

------------------------------------------------------------------------

## 📡 API Endpoints (Short Preview)

    GET /api/rides
    POST /api/rides
    POST /api/bookings
    GET /api/users/:id

Full API documentation coming soon.

------------------------------------------------------------------------

## 🧪 Testing

-   Jest for backend\
-   XCTest for iOS app

------------------------------------------------------------------------

## 🤝 Contribution

Pull requests are welcome!\
Feel free to open issues for bugs or feature suggestions.

------------------------------------------------------------------------

## 📝 License

MIT License © 2025 HopMe Team
