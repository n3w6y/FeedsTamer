// lib/services/x_service_integrator.dart
import 'package:feedstamer/services/x_api_service.dart';
import 'package:logger/logger.dart';
import 'package:feedstamer/models/Tweet.dart';

/// Service that coordinates between Twitter API service and other app services
class XServiceIntegrator {
  final TwitterApiService _twitterApiService;
  final Logger _logger = Logger();
  bool _isApiAvailable = false;
  
  XServiceIntegrator({TwitterApiService? twitterApiService}) 
      : _twitterApiService = twitterApiService ?? TwitterApiService();
  
  /// Check if the Twitter API is available
  Future<bool> isApiAvailable() async {
    try {
      _isApiAvailable = await _twitterApiService.isAvailable();
      return _isApiAvailable;
    } catch (e) {
      _logger.i('Twitter API not available: $e');
      _isApiAvailable = false;
      return false;
    }
  }
  
  /// Get tweets from a list of followed accounts
  Future<List<Tweet>> getTweetsFromFollowedAccounts(List<String> accountIds, {int maxResults = 10}) async {
    List<Tweet> allTweets = [];
    
    // First check if API is available
    if (!_isApiAvailable) {
      await isApiAvailable();
    }
    
    // If API is still not available, return empty list
    if (!_isApiAvailable) {
      _logger.w('Twitter API not available, returning empty tweet list');
      return [];
    }
    
    try {
      for (final userId in accountIds) {
        try {
          final response = await _twitterApiService.getTweetsFromUser(userId, maxResults: maxResults);
          
          if (response['data'] != null) {
            final List<dynamic> tweets = response['data'];
            for (var tweet in tweets) {
              // Add author_id to each tweet
              tweet['author_id'] = userId;
              
              // Try to get user information for this tweet
              try {
                final userResponse = await _twitterApiService.getUserDetails(userId);
                if (userResponse['data'] != null) {
                  tweet['author'] = userResponse['data'];
                }
              } catch (e) {
                _logger.w('Error getting user details for tweet: $e');
                // Continue without author information
              }
              
              allTweets.add(Tweet.fromJson(tweet));
            }
          }
        } catch (e) {
          _logger.e('Error fetching tweets for user $userId: $e');
          // Continue with other users
        }
      }
      
      // Sort tweets by created_at (newest first)
      allTweets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return allTweets;
    } catch (e) {
      _logger.e('Error in getTweetsFromFollowedAccounts: $e');
      return [];
    }
  }
  
  /// Search for Twitter users by username
  Future<List<TwitterUser>> searchTwitterUsers(String query) async {
    // First check if API is available
    if (!_isApiAvailable) {
      await isApiAvailable();
    }
    
    // If API is still not available, return empty list
    if (!_isApiAvailable) {
      _logger.w('Twitter API not available, returning empty user list');
      return [];
    }
    
    try {
      final response = await _twitterApiService.searchUsers(query);
      
      List<TwitterUser> users = [];
      if (response['data'] != null) {
        final List<dynamic> userData = response['data'];
        for (var user in userData) {
          users.add(TwitterUser.fromJson(user));
        }
      }
      
      return users;
    } catch (e) {
      _logger.e('Error in searchTwitterUsers: $e');
      return [];
    }
  }
  
  /// Get details for a specific Twitter user
  Future<TwitterUser?> getTwitterUserDetails(String userId) async {
    // First check if API is available
    if (!_isApiAvailable) {
      await isApiAvailable();
    }
    
    // If API is still not available, return null
    if (!_isApiAvailable) {
      _logger.w('Twitter API not available, returning null user');
      return null;
    }
    
    try {
      final response = await _twitterApiService.getUserDetails(userId);
      
      if (response['data'] != null) {
        return TwitterUser.fromJson(response['data']);
      } else {
        return null;
      }
    } catch (e) {
      _logger.e('Error in getTwitterUserDetails: $e');
      return null;
    }
  }
  
  /// Search for tweets with a specific query
  Future<List<Tweet>> searchTweets(String query, {int maxResults = 10}) async {
    // First check if API is available
    if (!_isApiAvailable) {
      await isApiAvailable();
    }
    
    // If API is still not available, return empty list
    if (!_isApiAvailable) {
      _logger.w('Twitter API not available, returning empty tweet list');
      return [];
    }
    
    try {
      final response = await _twitterApiService.searchTweets(query, maxResults: maxResults);
      
      List<Tweet> tweets = [];
      if (response['data'] != null) {
        final List<dynamic> tweetData = response['data'];
        for (var tweet in tweetData) {
          tweets.add(Tweet.fromJson(tweet));
        }
      }
      
      return tweets;
    } catch (e) {
      _logger.e('Error in searchTweets: $e');
      return [];
    }
  }
  
  /// Clear the Twitter API cache
  void clearCache() {
    _twitterApiService.clearCache();
  }
}