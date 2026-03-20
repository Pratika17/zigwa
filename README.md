# Zigwa - Smart Waste Management Platform

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License">
</div>

## 🌍 About Zigwa

Zigwa is a revolutionary mobile application that transforms waste management through community participation and circular economy principles. Our platform connects three key stakeholders in the waste management ecosystem:

- **👥 Users**: Report trash locations and earn rewards
- **🚛 Collection Workers**: Get notified, collect waste, and earn money
- **🏭 Dealers**: Process waste and manage payment distribution

## ✨ Key Features

### 📱 Multi-User Platform
- **Separate Authentication**: Dedicated login systems for Users, Collection Workers, and Dealers
- **Role-Based Dashboards**: Customized interfaces for each user type
- **Secure Profile Management**: User data protection and privacy

### 📸 Smart Reporting
- **Photo Capture**: Take pictures of trash using camera or gallery
- **Location Tagging**: Automatic GPS location detection and address resolution
- **Waste Classification**: Categorize trash by type (Plastic, Paper, Metal, Glass, etc.)
- **Detailed Descriptions**: Add context and additional information

### 🔔 Real-Time Notifications
- **Instant Alerts**: Collection workers get notified of new reports
- **Status Updates**: Users receive updates on their report progress
- **Payment Notifications**: Automatic alerts when payments are processed

### 💰 Fair Payment Distribution
- **65%** → Collection Workers (for their collection efforts)
- **25%** → Users (for reporting and contributing)
- **10%** → Platform Fee (for maintaining the service)

### 📊 Comprehensive Tracking
- **Status Monitoring**: Track reports from submission to payment
- **Earnings Dashboard**: View total earnings and completed tasks
- **Progress Indicators**: Visual representation of report lifecycle

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter (Dart)
- **State Management**: Provider Pattern
- **Local Storage**: SQLite
- **Location Services**: Geolocator & Geocoding
- **Camera Integration**: Image Picker
- **Notifications**: Flutter Local Notifications

### Project Structure
```
lib/
├── models/           # Data models
├── providers/        # State management
├── services/         # Business logic
├── screens/          # UI screens
│   ├── auth/        # Authentication screens
│   ├── user/        # User-specific screens
│   ├── collector/   # Collection worker screens
│   └── dealer/      # Dealer screens
├── utils/           # Utilities and constants
└── main.dart        # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.9.0)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/zigwa.git
   cd zigwa
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Demo Mode
The app includes a demo mode for testing:
- Enter any email and password to create demo accounts
- Each user type has pre-populated data for testing
- No real backend integration required for demo

## 📱 User Flows

### 👤 Regular Users
1. **Sign Up/Login** → Choose "User" role
2. **Report Trash** → Take photo, add location, describe waste
3. **Track Progress** → Monitor report status and earnings
4. **Receive Payment** → Get 25% of processed waste value

### 🚛 Collection Workers
1. **Sign Up/Login** → Choose "Collection Worker" role
2. **View Available Reports** → See new trash reports in area
3. **Accept Tasks** → Choose reports to collect
4. **Mark as Collected** → Update status after collection
5. **Receive Payment** → Get 65% of processed waste value

### 🏭 Dealers
1. **Sign Up/Login** → Choose "Dealer" role
2. **Review Collected Items** → See items brought by collectors
3. **Process & Value** → Set actual value of waste materials
4. **Distribute Payments** → Trigger payment to users and collectors

## 🎨 UI/UX Design

### Design Principles
- **Intuitive Navigation**: Easy-to-use bottom navigation
- **Color-Coded Roles**: Different colors for each user type
- **Material Design**: Following Google's design guidelines
- **Accessibility**: Support for different screen sizes and accessibility features

### Color Scheme
- **Users**: Blue (#2196F3)
- **Collection Workers**: Orange (#FF9800)
- **Dealers**: Purple (#9C27B0)
- **Primary**: Green (#2E7D32)

## 🔧 Configuration

### Permissions Required
```xml
<!-- Android permissions -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Environment Setup
1. Enable location services on device
2. Grant camera permissions
3. Ensure internet connectivity for geocoding

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Test Coverage
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable names
- Add comments for complex logic
- Maintain consistent formatting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Community contributors and testers
- Environmental organizations inspiring this project

## 📞 Support

For support and questions:
- 📧 Email: support@zigwa.com
- 🌐 Website: www.zigwa.com
- 📱 App Store: [Coming Soon]
- 🤖 Google Play: [Coming Soon]

## 🗺️ Roadmap

### Phase 1 (Current)
- ✅ Basic app functionality
- ✅ Three user types
- ✅ Photo capture and location
- ✅ Payment distribution

### Phase 2 (Upcoming)
- 🔄 Real-time chat between users
- 🔄 Advanced analytics dashboard
- 🔄 Gamification features
- 🔄 Social sharing capabilities

### Phase 3 (Future)
- 🔄 AI-powered waste classification
- 🔄 Route optimization for collectors
- 🔄 Integration with municipal systems
- 🔄 Carbon footprint tracking

---

<div align="center">
  <p><strong>Join the circular economy revolution! 🌱</strong></p>
  <p>Made with ❤️ by the Zigwa Team</p>
</div>
