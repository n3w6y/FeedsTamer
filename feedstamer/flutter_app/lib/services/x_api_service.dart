// lib/services/x_api_service.dart
// This file imports configuration files which must exist in the lib/config/ directory

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

// Define these constants directly in this file instead of importing them
// from potentially missing config files
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

class TwitterApiSecureConfig {
  // Twitter API v2 credentials - replace with your actual values when deploying
  static const String bearerToken = 'YOUR_BEARER_TOKEN';
  static const String apiKey = 'YOUR_API_KEY';
  static const String apiKeySecret = 'YOUR_API_KEY_SECRET';
  static const String accessToken = 'YOUR_ACCESS_TOKEN';
  static const String accessTokenSecret = 'YOUR_ACCESS_TOKEN_SECRET';
}

/// Service for interacting with the Twitter (X) API
class TwitterApiService {
  final Logger _logger = Logger();
  final String _baseUrl = TwitterApiConfig.baseUrl;
  
  // Cache for API responses
  final Map<String, dynamic> _responseCache = {};
  
  /// Check if the API is available by making a simple request
  Future<bool> isAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/by?usernames=twitter'),
        headers: _getAuthHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Twitter API availability check failed: $e');
      return false;
    }
  }
  
  /// Get tweets from a specific user
  Future<Map<String, dynamic>> getTweetsFromUser(String userId, {int maxResults = 10}) async {
    final cacheKey = 'user_tweets_$userId _$maxResults';
    
    // Check cache first
    if (_responseCache.containsKey(cacheKey)) {
      return _responseCache[cacheKey];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/tweets?max_results=$maxResults'
                 '&tweet.fields=${TwitterApiConfig.tweetFields}'),
        headers: _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _responseCache[cacheKey] = data; // Cache the response
        return data;
      } else {
        _logger.e('Error fetching tweets: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch tweets: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Exception in getTweetsFromUser: $e');
      throw Exception('Failed to fetch tweets: $e');
    }
  }
  
  /// Search for users by username
  Future<Map<String, dynamic>> searchUsers(String query) async {
    final cacheKey = 'search_users_$query';
    
    // Check cache first
    if (_responseCache.containsKey(cacheKey)) {
      return _responseCache[cacheKey];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/by?usernames=$query'
                 '&user.fields=${TwitterApiConfig.userFields}'),
        headers: _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _responseCache[cacheKey] = data; // Cache the response
        return data;
      } else {
        _logger.e('Error searching users: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to search users: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Exception in searchUsers: $e');
      throw Exception('Failed to search users: $e');
    }
  }
  
  /// Get details for a specific user
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final cacheKey = 'user_details_$userId';
    
    // Check cache first
    if (_responseCache.containsKey(cacheKey)) {
      return _responseCache[cacheKey];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId?user.fields=${TwitterApiConfig.userFields}'),
        headers: _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _responseCache[cacheKey] = data; // Cache the response
        return data;
      } else {
        _logger.e('Error fetching user details: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch user details: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Exception in getUserDetails: $e');
      throw Exception('Failed to fetch user details: $e');
    }
  }
  
  /// Search for tweets with a specific query
  Future<Map<String, dynamic>> searchTweets(String query, {int maxResults = 10}) async {
    final cacheKey = 'search_tweets_$query _$maxResults';
    
    // Check cache first
    if (_responseCache.containsKey(cacheKey)) {
      return _responseCache[cacheKey];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${TwitterApiConfig.searchEndpoint}?query=$query'
                 '&max_results=$maxResults&tweet.fields=${TwitterApiConfig.tweetFields}'),
        headers: _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _responseCache[cacheKey] = data; // Cache the response
        return data;
      } else {
        _logger.e('Error searching tweets: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to search tweets: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Exception in searchTweets: $e');
      throw Exception('Failed to search tweets: $e');
    }
  }
  
  /// Get details for multiple tweets by ID
  Future<Map<String, dynamic>> getTweetDetails(List<String> tweetIds) async {
    final ids = tweetIds.join(',');
    final cacheKey = 'tweet_details_$ids';
    
    // Check cache first
    if (_responseCache.containsKey(cacheKey)) {
      return _responseCache[cacheKey];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tweets?ids=$ids&tweet.fields=${TwitterApiConfig.tweetFields}'),
        headers: _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _responseCache[cacheKey] = data; // Cache the response
        return data;
      } else {
        _logger.e('Error fetching tweet details: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch tweet details: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Exception in getTweetDetails: $e');
      throw Exception('Failed to fetch tweet details: $e');
    }
  }
  
  /// Clear the cache for a specific key or all cached data
  void clearCache({String? cacheKey}) {
    if (cacheKey != null) {
      _responseCache.remove(cacheKey);
    } else {
      _responseCache.clear();
    }
  }
  
  /// Get authentication headers for API requests
  Map<String, String> _getAuthHeaders() {
    return {
      'Authorization': 'Bearer ${TwitterApiSecureConfig.bearerToken}',
      'Content-Type': 'application/json',
    };
  }
}