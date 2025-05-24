// lib/config/secure_config.dart
// This file should be added to .gitignore to prevent committing credentials

class TwitterApiSecureConfig {
  // Twitter API v2 credentials
  static const String bearerToken = 'YOUR_BEARER_TOKEN';
  static const String apiKey = 'YOUR_API_KEY';
  static const String apiKeySecret = 'YOUR_API_KEY_SECRET';
  static const String accessToken = 'YOUR_ACCESS_TOKEN';
  static const String accessTokenSecret = 'YOUR_ACCESS_TOKEN_SECRET';
  
  // API configuration
  static const int maxTweetsPerRequest = 30;
  static const int cacheExpirationMinutes = 15;
  
  // Rate limiting (requests per 15-minute window)
  static const int userLookupLimit = 900;
  static const int tweetLookupLimit = 300;
  static const int searchLimit = 450;
}