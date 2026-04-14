## 🚀 AeroSparkle BMS

Booking Management System (Mini Application)

## 📌 Overview

AeroSparkle BMS is a Flutter-based mobile application that simulates a basic booking management system. It demonstrates how bookings can be displayed, managed, and updated in a clean and user-friendly interface, similar to real-world service platforms.

## ✨ Features

✅ Core Requirements

- Display booking list with:
  - Customer Name
  - Service Type
  - Booking Status (Pending / Completed)
- Update booking status from Pending → Completed
- Apply 10% discount automatically for bookings above RM200

## ⭐ Additional (Bonus Features)

- 🔄 Mock API integration with simulated delay
- ⚠️ Error handling (API failure simulation + retry)
- ⏳ Loading indicators (data fetch & update)
- 📅 Calendar planner view (schedule-based navigation)
- 📄 Booking detail screen
- 📍 Location + Google Maps integration
- 🎨 Clean and responsive UI (Material 3)

## 🧱 Architecture

The application follows a simple and maintainable structure:

lib/
├── models/ # Data models & business logic
├── services/ # Mock API & data handling
├── screens/ # Main UI screens
├── widgets/ # Reusable UI components
└── main.dart # App entry point

Layered Design

- Model Layer → Handles booking data & discount logic
- Service Layer → Simulates API behavior (fetch, update, error)
- UI Layer → Displays data and handles user interaction

## ⚙️ Business Logic

- Bookings with amount > RM200 receive:
  - ✅ 10% discount
- Booking status is limited to:
  - Pending
  - Completed
- Bookings can be marked as completed based on booking date

## ▶️ Getting Started

1. Clone the repository
   git clone https://github.com/your-username/booking_management_system.git

2. Navigate into the project
   cd booking_management_system

3. Install dependencies
   flutter pub get

4. Run the application
   flutter run

## 🧪 Demo Guide

- 🐞 Tap **bug icon** → simulate API failure
- 🔄 Tap **refresh** → test loading and error handling
- 📅 Use planner → view bookings by date
- 📄 Tap booking → view details
- ✅ Tap **"Mark as Completed"** → update status

## 📝 Assumptions

- Mock API is used as no backend is provided
- Booking data is pre-defined for demonstration
- Discount rule is fixed at 10%
- Only **Pending** and **Completed** statuses are used
- Authentication is not included (out of scope)

## 👤 Author

Wan Aliff Luqman
