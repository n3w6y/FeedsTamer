// lib/config/api_config.dart

/// Template class for API configuration
/// Do not add actual credentials here - use secure_config.dart instead
class TwitterApiConfig {
  // Twitter API v2 endpoints
  static const String baseUrl = 'https://api.twitter.com/2';
  
  // Endpoints
  static const String usersEndpoint = '/users';
  static const String tweetsEndpoint = '/tweets';
  static const String searchEndpoint = '/tweets/search/recent';
  
  // Tweet fields to include in responses
  static const String tweetFields = 'created_at,public_metrics,referenced_tweets,attachments,entities';
  
  // User fields to include in responses
  static const String userFields = 'profile_image_url,description,public_metrics,verified,created_at';
  
  // Media fields to include in responses
  static const String mediaFields = 'type,url,preview_image_url,width,height';
}