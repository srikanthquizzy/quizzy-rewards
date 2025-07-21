# Quizzy Rewards - Flutter Quiz App

A comprehensive Flutter-based Android app where users earn coins by answering quiz questions and completing various tasks. Built with Firebase backend, AdMob integration, and a premium UI design.

## Features

### 🔐 Authentication
- Firebase Authentication with phone number + OTP
- Secure user registration and login
- Referral code system for new users

### 🏠 Home Dashboard
- Clean grid layout with 6 main features
- Real-time coin balance display
- User-friendly navigation

### ❓ Quiz System
- 10 multiple-choice questions per quiz
- 5 quizzes allowed per day
- 10-second timer per question
- 2 coins per correct answer
- Sound effects for correct/wrong answers
- AdMob ads integration (before quiz, question 6, and result screen)

### 💰 Coin & Reward System
- **Conversion Rate**: 100 coins = ₹10
- **First Withdrawal**: Minimum 100 coins (₹10)
- **Subsequent Withdrawals**: Minimum 1000 coins (₹100)
- **Withdrawal Conditions for ₹100+**:
  - Complete at least 2 referral apps
  - Join Telegram channel

### 🎯 Multiple Earning Methods
1. **Daily Quiz**: Up to 5 quizzes per day
2. **Referral System**: 50 coins for referrer, 25 for new user
3. **Watch Ads**: 5 coins per ad (5 ads per day)
4. **Spin Wheel**: 0-10 coins (2 spins per day)
5. **Install Apps**: Dynamic app list from Firebase
6. **Welcome Bonus**: 25 coins for new users

### 📱 Core Screens
- **Splash Screen**: App intro with loading animation
- **Login/OTP**: Phone verification with optional referral code
- **Home Screen**: Main dashboard with feature grid
- **Quiz Game**: Interactive quiz with timer and sounds
- **Results Screen**: Detailed score breakdown
- **Referral Screen**: Share referral code and track earnings
- **Withdrawal Screen**: UPI withdrawal requests

### 🎨 UI Design
- **Theme**: Royal Blue (#1E3A8A) and Gold (#FFD700)
- **Premium Design**: Clean cards with rounded corners and shadows
- **Responsive Layout**: Works on all screen sizes
- **Smooth Animations**: Micro-interactions and transitions
- **Professional Typography**: Poppins font family

### 🔧 Backend Integration
- **Firebase Firestore**: User data, quiz questions, referral apps
- **Firebase Authentication**: Secure phone number authentication
- **Firebase Cloud Messaging**: Push notifications
- **AdMob**: Rewarded ads, banner ads, interstitial ads
- **Admin Dashboard**: Dynamic content management

### 🔔 Notifications
- Daily reminder at 11:00 AM
- Custom notification sounds
- Background message handling
- Local notification support

## Technical Architecture

### State Management
- **Provider Pattern**: Clean state management
- **Reactive UI**: Real-time updates
- **Separation of Concerns**: Modular provider classes

### Project Structure
```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
├── providers/                   # State management
├── screens/                     # UI screens
├── services/                    # Backend services
├── utils/                       # Utilities and themes
└── widgets/                     # Reusable components
```

### Key Dependencies
- `firebase_core`: Firebase initialization
- `firebase_auth`: Phone authentication
- `cloud_firestore`: Database operations
- `google_mobile_ads`: AdMob integration
- `provider`: State management
- `audioplayers`: Sound effects
- `flutter_fortune_wheel`: Spin wheel functionality

## Setup Instructions

### 1. Firebase Setup
1. Create a new Firebase project
2. Enable Authentication (Phone provider)
3. Set up Firestore database
4. Enable Cloud Messaging
5. Add `google-services.json` to `android/app/`

### 2. AdMob Setup
1. Create AdMob account
2. Add app to AdMob
3. Create ad units (Banner, Interstitial, Rewarded)
4. Update Ad Unit IDs in `lib/providers/ads_provider.dart`

### 3. Database Structure
```
users/
├── uid/
    ├── phoneNumber: string
    ├── coinBalance: number
    ├── referralCode: string
    ├── quizzesPlayedToday: number
    └── ...

quiz_questions/
├── questionId/
    ├── question: string
    ├── options: array
    ├── correctAnswer: number
    └── category: string

referral_apps/
├── appId/
    ├── name: string
    ├── iconUrl: string
    ├── deepLink: string
    └── coinsReward: number
```

### 4. Installation
```bash
# Clone the repository
git clone <repository-url>

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Key Features Implementation

### Quiz System
- Dynamic question loading from Firebase
- Timer-based gameplay with 10 seconds per question
- Sound effects for user feedback
- Progress tracking and score calculation
- Daily limit enforcement (5 quizzes per day)

### Referral System
- Unique referral code generation
- Automatic reward distribution
- Share functionality with custom messages
- Referral tracking and history

### Coin System
- Real-time balance updates
- Transaction logging
- Withdrawal request management
- Minimum withdrawal thresholds
- UPI payment integration

### Ad Integration
- Strategic ad placement for maximum revenue
- Rewarded ads for bonus coins
- Banner ads during quiz gameplay
- Interstitial ads between screens

## Revenue Model

### User Engagement
- **Daily Active Users**: Quiz limits encourage daily usage
- **Retention**: Multiple earning methods keep users engaged
- **Viral Growth**: Referral system drives organic growth

### Monetization
- **Ad Revenue**: Strategic ad placement with high completion rates
- **User Acquisition**: Referral system reduces acquisition costs
- **Engagement Metrics**: Quiz performance and daily challenges

## Security Features

### Data Protection
- Firebase security rules for user data
- Input validation and sanitization
- Secure authentication flow
- Transaction integrity checks

### Fraud Prevention
- Daily limits on earning activities
- Referral validation system
- Withdrawal verification process
- Admin approval for withdrawals

## Future Enhancements

### Planned Features
- **Leaderboards**: Weekly and monthly rankings
- **Tournaments**: Special quiz events with bigger rewards
- **Categories**: Specialized quiz topics
- **Social Features**: Friend challenges and sharing
- **Premium Features**: Ad-free experience with subscription

### Technical Improvements
- **Offline Support**: Cache questions for offline play
- **Performance Optimization**: Lazy loading and caching
- **Analytics**: Detailed user behavior tracking
- **A/B Testing**: Optimize user experience

## Contributing

This is a production-ready Flutter app with enterprise-level architecture. The codebase follows Flutter best practices and is designed for scalability and maintainability.

## License

This project is proprietary and confidential. All rights reserved.