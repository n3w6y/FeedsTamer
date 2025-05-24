# X API Integration in FeedsTamer

This README provides instructions on how to use the X (formerly Twitter) API integration in the FeedsTamer app.

## API Credentials

The app is now configured to use your X API credentials:

- **Bearer Token**: Used for API access (OAuth 2.0)
- **Access Token**: For user-context operations (OAuth 1.0a)
- **Access Token Secret**: For user-context operations (OAuth 1.0a)

## Files Added/Modified

1. **API Configuration**
   - `lib/config/api_config.dart` - Template for storing API credentials
   - `lib/config/secure_config.dart` - Actual secure configuration with credentials

2. **Service Layer**
   - Enhanced `TwitterApiService` to use the real API credentials
   - Added `XServiceIntegrator` to coordinate between API service, account service, and feed service

3. **UI Components**
   - Added `feed_screen_with_real_api.dart` - An enhanced feed screen that supports real API data

4. **Main App Integration**
   - `main_updated_with_x.dart` - Updated main file that initializes the X API integration

## How to Test the API Integration

1. **Update your main.dart file** with the contents of `main_updated_with_x.dart`

2. **Replace your home screen** with the new `FeedScreen` from `feed_screen_with_real_api.dart`

3. **Run the app** - It will automatically detect if it can use the real API or should fall back to mock data

## Security Considerations

- The credentials are currently stored in `secure_config.dart`, which should be added to your `.gitignore` file to prevent committing them to version control

- In a production app, consider using:
  - Environment variables
  - Secure storage
  - Firebase Remote Config
  - A backend service to provide tokens

## Features Available with Real API

With the X API integration, users can now:

1. **Search for X accounts** to follow
2. **View real tweets** from followed accounts
3. **See profile information** for X users
4. **Track engagement metrics** like likes, retweets, and replies

## Fallback Mechanism

The app is designed to seamlessly fall back to mock data if:

- API credentials are missing or invalid
- Network connectivity issues occur
- API rate limits are reached

## Next Steps

1. **Implement OAuth 1.0a Signing** for user-context operations (currently uses bearer token only)
2. **Add Rate Limit Handling** with exponential backoff
3. **Create Cache Management** to reduce API calls
4. **Implement Webhook Support** for real-time updates

## Troubleshooting

If you encounter issues with the API integration:

1. Check the API status in the app (badge in the feed screen)
2. Verify the credentials in `secure_config.dart`
3. Check the logs for API errors
4. Ensure network connectivity