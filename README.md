# 🚗 Car Maintenance Tracker

Flutter application for managing vehicle maintenance, allowing you to register multiple cars and track the full history of services, costs, and statistics.

## 📱 Features

### Car Management
- ✅ Register multiple cars with nickname, manufacturer, model, and year
- ✅ Edit and delete cars
- ✅ Select car image (gallery or camera)
- ✅ List all registered cars

### Maintenance Management
- ✅ Full maintenance registration with:
  - Maintenance date
  - Maintenance title
  - Problem description
  - Replaced parts
  - Total cost
  - Mechanic name
  - Vehicle mileage
  - Additional notes
- ✅ Edit and delete maintenances
- ✅ Detailed view of each maintenance
- ✅ Paginated maintenance history (5 at a time with a "Load more" button)

### Statistics and Reports
- ✅ Days since last maintenance
- ✅ Total amount spent on maintenance
- ✅ Total number of maintenances performed
- ✅ Record counter in the history

### Interface
- ✅ Animated splash screen
- ✅ Modern and responsive design
- ✅ Intuitive navigation

## 🛠️ Technologies Used

- **Flutter** – Cross-platform framework
- **MongoDB** – Cloud NoSQL database
- **mongo_dart** – MongoDB driver for Dart
- **flutter_dotenv** – Environment variables management
- **image_picker** – Image selection (gallery/camera)
- **shared_preferences** – Local preferences storage
- **intl** – Internationalization and date/number formatting
- **path_provider** – Access to device directories

## 📋 Prerequisites

- Flutter SDK (version 3.5.4 or higher)
- Dart SDK
- MongoDB Atlas account (or your own MongoDB server)
- Xcode (for iOS) or Android Studio (for Android)

## 🚀 How to Set Up

### 1. Clone the repository

```bash
git clone <repository-url>
cd car_maintenance_tracker
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment variables

1. Copy the `.env.example` file to `.env`:
```bash
cp .env.example .env
```

2. Edit the `.env` file and add your MongoDB connection string:
```env
MONGODB_CONNECTION_STRING=mongodb+srv://user:password@cluster.mongodb.net/
DATABASE_NAME=CarMaintenance
```

**⚠️ Important**: The `.env` file contains sensitive information and must not be committed to Git. It is already configured in `.gitignore`.

### 4. Run the application

```bash
# iOS
flutter run

# Android
flutter run

# Specific device
flutter devices
flutter run -d <device-id>
```

## 📁 Project Structure

```
lib/
├── main.dart                          # Application entrypoint
├── models/
│   ├── car_model.dart                 # Car data model
│   └── maintenance_model.dart         # Maintenance data model
├── screens/
│   ├── splash_screen.dart             # Splash screen
│   ├── cars_list_screen.dart          # Cars list
│   ├── add_car_screen.dart            # Add/edit car
│   ├── home_screen.dart               # Main screen with statistics
│   ├── add_maintenance_screen.dart    # Add/edit maintenance
│   └── maintenance_detail_screen.dart # Maintenance details
└── services/
    └── database_service.dart          # MongoDB connection service
```

## 🎨 UI Characteristics

- **Info Cards**: Statistics displayed in visual cards
- **Pagination**: Maintenance history with progressive loading
- **Circular Images**: Car photos shown in circular shape
- **Animations**: Smooth animations on the splash screen
- **Floating Action Buttons**: FABs for main actions

## 🔒 Security

- Database credentials stored in a `.env` file (not versioned)
- Form data validation
- Error handling for database operations

## 📝 Data Models

### Car
- `id`: Unique identifier
- `nickname`: Car nickname
- `manufacturer`: Manufacturer
- `model`: Model
- `year`: Year

### MaintenanceRecord
- `id`: Unique identifier
- `carId`: Linked car ID
- `serviceDate`: Maintenance date
- `title`: Maintenance title
- `problemDescription`: Problem description
- `replacedParts`: List of replaced parts
- `cost`: Total cost
- `mechanicName`: Mechanic name
- `notes`: Additional notes
- `km`: Vehicle mileage

## 🐛 Troubleshooting

### Error loading .env
- Make sure the `.env` file is in the project root
- Run `flutter clean` and `flutter pub get`
- Do a full rebuild of the app (not just hot reload)

### MongoDB connection error
- Check if the connection string in `.env` is correct
- Confirm that the IP is allowed in MongoDB Atlas (Network Access)
- Check user credentials and password

### Error selecting image
- Check camera and gallery permissions on the device
- On iOS, check `Info.plist` for camera permissions

## 📄 License

This project is private and for personal use.

## 👨‍💻 Developed by

Car Maintenance Tracker – Vehicle maintenance management system

---


**Version**: 1.0.0+1
