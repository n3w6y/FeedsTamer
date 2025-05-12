# FeedsTamer

FeedsTamer helps you reclaim your attention by curating content from a small number of authoritative accounts across different platforms.

![FeedsTamer Logo](assets/images/logo.png)

## Features

- **Decrease Irrelevant Distractions**: Focus only on content from sources you explicitly choose to follow
- **Reduce Feed Burnout**: Avoid endless scrolling and algorithm-driven content
- **Increase Productivity**: Spend less time lost in social media feeds
- **Cross-Platform Integration**: Combine feeds from Twitter/X, Instagram, YouTube, and more
- **Focus Tools**: Pomodoro timer, usage limits, and distraction-free mode
- **Analytics**: Track your usage and see how much time you've saved

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Firebase project setup

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/feedstamer.git
   ```

2. Navigate to the project directory
   ```bash
   cd feedstamer
   ```

3. Install dependencies
   ```bash
   flutter pub get
   ```

4. Setup Firebase
   - Create a Firebase project at [firebase.google.com](https://firebase.google.com)
   - Add Android and iOS apps with your package name and bundle ID
   - Download the config files and place them in the appropriate locations:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
   - Update `lib/firebase_options.dart` with your Firebase project details

5. Run the app
   ```bash
   flutter run
   ```

## Project Structure

- `lib/models/`: Data models for users, accounts, and content
- `lib/screens/`: UI screens and widgets
- `lib/services/`: Business logic and API integrations
- `lib/constants/`: App-wide constants and theme definitions
- `lib/utils/`: Utility functions and helpers

## Architecture

The app follows a clean architecture pattern with:

- **UI Layer**: Flutter widgets and screens
- **Business Logic**: Services and providers
- **Data Layer**: Models and repositories
- **External Services**: Firebase and social media APIs

State management is handled with Flutter Riverpod.

## Firebase Setup

The app uses the following Firebase services:

- **Authentication**: User login and registration
- **Firestore**: Database for user data, accounts, and content
- **Analytics**: Usage tracking and insights
- **Cloud Messaging**: Push notifications

Follow the Firebase setup guide in the [Firebase documentation](https://firebase.google.com/docs/flutter/setup) to configure your project.

## Social Media API Integration

The app integrates with various social media APIs:

- **Twitter/X API**: For Twitter feed integration
- **Instagram API**: For Instagram feed integration
- **YouTube Data API**: For YouTube content integration

You'll need to obtain API keys for each platform you want to integrate.

## Roadmap

- [x] User authentication
- [x] Basic feed integration
- [x] Account selection
- [x] Focus tools
- [ ] AI content prioritization
- [ ] Calendar integration
- [ ] Advanced analytics
- [ ] Desktop version

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Riverpod](https://riverpod.dev/)
- Icon and design by [YourName]