# Firebase Authentication with Twitter Integration

This guide walks you through integrating Twitter authentication into your FeedsTamer Flutter app using Firebase Authentication.

## Prerequisites

1. Firebase project with Authentication enabled
2. Twitter Developer Account with an app set up
3. Flutter project with Firebase core and auth packages installed

## Step 1: Set Up Twitter Developer App

1. Go to [Twitter Developer Portal](https://developer.twitter.com/en/portal/dashboard)
2. Create a new app or use an existing one
3. Set up the app's authentication settings:
   - Enable 3-legged OAuth
   - Add callback URL: `https://your-firebase-project-id.firebaseapp.com/__/auth/handler`
   - Get your API Key (Consumer Key) and API Secret (Consumer Secret)

## Step 2: Configure Firebase Authentication

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to Authentication > Sign-in method
4. Enable Twitter sign-in method
5. Enter your Twitter API Key and API Secret from Step 1
6. Save the changes

## Step 3: Update Your Flutter Code

### 1. Update Dependencies

Ensure you have the necessary dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.14.0
  firebase_auth: ^4.6.3
  cloud_firestore: ^4.8.1
```

### 2. Implement the Auth Service with Twitter Sign-In

Use the provided `auth_service_with_twitter.dart` file, which includes a `signInWithTwitter()` method:

```dart
// Sign in with Twitter
Future<UserCredential?> signInWithTwitter() async {
  try {
    // Create a TwitterAuthProvider
    final TwitterAuthProvider twitterProvider = TwitterAuthProvider();
    
    // Sign in with Twitter
    final UserCredential result = await _auth.signInWithProvider(twitterProvider);
    
    logger.i('User signed in with Twitter: ${result.user?.uid}');
    
    // Load user profile
    if (result.user != null) {
      await _loadUserProfile(result.user!.uid);
    }
    
    return result;
  } catch (e) {
    logger.e('Error signing in with Twitter: $e');
    return null;
  }
}
```

### 3. Implement the Login Screen with Twitter Button

Use the provided `login_screen_with_twitter.dart` file, which includes a Twitter sign-in button and handler method:

```dart
// Handle Twitter sign in
Future<void> _signInWithTwitter() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final result = await _authService.signInWithTwitter();
    
    if (mounted && result != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Twitter sign in was cancelled.';
      });
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Failed to sign in with Twitter. Please try again.';
    });
  }
}
```

## Step 4: Configure Native Platforms

### Android Configuration

1. Update your `android/app/build.gradle` file to ensure minSdkVersion is at least 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        // other configs...
    }
}
```

2. Update your `AndroidManifest.xml` to include the following in the `<application>` tag:

```xml
<activity
    android:name="com.twitter.sdk.android.core.identity.OAuthActivity"
    android:exported="true" />
```

### iOS Configuration

1. Update your `ios/Runner/Info.plist` to include:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>twitterkit-YOUR_TWITTER_API_KEY</string>
        </array>
    </dict>
</array>
```

Replace `YOUR_TWITTER_API_KEY` with your actual Twitter API Key.

## Step 5: Testing

1. Run your Flutter app
2. Navigate to the login screen
3. Tap the "Continue with Twitter" button
4. You should be redirected to Twitter's login page
5. After successful authentication, you should be redirected back to your app and logged in

## Troubleshooting

### Common Issues:

1. **Sign-in fails silently**: 
   - Check your Twitter API keys in Firebase console
   - Ensure your callback URL is correctly configured

2. **Redirect fails after Twitter authentication**:
   - Check the URL schemes in your Info.plist (iOS)
   - Verify the OAuthActivity is properly declared in AndroidManifest.xml

3. **"Sign in with Twitter was cancelled" error**:
   - This usually means the user backed out of the Twitter authentication flow
   - If it happens without user action, check your Twitter app settings

4. **Firebase initialization issues**:
   - Ensure Firebase is properly initialized before attempting authentication
   - Check for "Firebase App named '[DEFAULT]' already exists" error in logs

### Debugging Tips:

1. Enable verbose logging in your auth service
2. Check Firebase Authentication logs in the Firebase Console
3. Try testing with different Twitter accounts

## Security Considerations

1. Never store your Twitter API Secret in client-side code
2. Use Firebase Security Rules to protect user data in Firestore
3. Implement proper error handling for authentication failures
4. Consider implementing email verification for additional security