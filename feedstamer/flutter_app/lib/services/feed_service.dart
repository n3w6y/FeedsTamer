// lib/services/feed_service.dart
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Import the corrected path for the Tweet model
import 'package:feedstamer/models/tweet.dart'; // Lowercase 't' in the import
import 'package:feedstamer/services/x_service_integrator.dart';

/// Service for managing feeds from different platforms
class FeedService {
  final XServiceIntegrator _xServiceIntegrator;
  final Logger _logger = Logger();
  
  // Cache for followed accounts
  List<String> _followedTwitterAccounts = [];
  
  // Singleton instance
  static final FeedService _instance = FeedService._internal();
  
  // Factory constructor - fixed the null safety issue
  factory FeedService({XServiceIntegrator? xServiceIntegrator}) {
    if (xServiceIntegrator != null) {
      // Use a non-null assertion operator to convert nullable to non-nullable
      _instance._xServiceIntegrator = xServiceIntegrator;
    }
    return _instance;
  }
  
  // Private constructor - initialize with non-nullable XServiceIntegrator
  FeedService._internal() : _xServiceIntegrator = XServiceIntegrator();
  
  /// Initialize the feed service
  Future<void> initialize() async {
    await _loadFollowedAccounts();
  }
  
  /// Get tweets from followed accounts
  Future<List<Tweet>> getTwitterFeed({int maxResults = 10}) async {
    try {
      // Check if any accounts are followed
      if (_followedTwitterAccounts.isEmpty) {
        await _loadFollowedAccounts();
        
        // If still empty, return empty list
        if (_followedTwitterAccounts.isEmpty) {
          return [];
        }
      }
      
      // Get tweets from followed accounts
      return await _xServiceIntegrator.getTweetsFromFollowedAccounts(
        _followedTwitterAccounts,
        maxResults: maxResults,
      );
    } catch (e) {
      _logger.e('Error getting Twitter feed: $e');
      return [];
    }
  }
  
  /// Get list of followed Twitter accounts
  Future<List<String>> getFollowedTwitterAccounts() async {
    await _loadFollowedAccounts();
    return _followedTwitterAccounts;
  }
  
  /// Follow a new Twitter account
  Future<bool> followTwitterAccount(String accountId) async {
    try {
      // Check if account is already followed
      if (_followedTwitterAccounts.contains(accountId)) {
        return true; // Already following
      }
      
      // Add account to followed list
      _followedTwitterAccounts.add(accountId);
      
      // Save updated list
      await _saveFollowedAccounts();
      
      return true;
    } catch (e) {
      _logger.e('Error following Twitter account: $e');
      return false;
    }
  }
  
  /// Unfollow a Twitter account
  Future<bool> unfollowTwitterAccount(String accountId) async {
    try {
      // Remove account from followed list
      _followedTwitterAccounts.remove(accountId);
      
      // Save updated list
      await _saveFollowedAccounts();
      
      return true;
    } catch (e) {
      _logger.e('Error unfollowing Twitter account: $e');
      return false;
    }
  }
  
  /// Search for Twitter accounts
  Future<List<TwitterUser>> searchTwitterAccounts(String query) async {
    try {
      return await _xServiceIntegrator.searchTwitterUsers(query);
    } catch (e) {
      _logger.e('Error searching Twitter accounts: $e');
      return [];
    }
  }
  
  /// Check if a Twitter account is followed
  bool isTwitterAccountFollowed(String accountId) {
    return _followedTwitterAccounts.contains(accountId);
  }
  
  /// Clear feed cache
  void clearCache() {
    _xServiceIntegrator.clearCache();
  }
  
  /// Load followed accounts from SharedPreferences
  Future<void> _loadFollowedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = prefs.getString('followed_twitter_accounts');
      
      if (accountsJson != null) {
        final List<dynamic> accountsList = json.decode(accountsJson);
        _followedTwitterAccounts = accountsList.map((e) => e.toString()).toList();
      } else {
        // Default followed accounts for testing
        _followedTwitterAccounts = [
          '44196397', // @elonmusk
          '783214',   // @twitter
        ];
        await _saveFollowedAccounts();
      }
    } catch (e) {
      _logger.e('Error loading followed accounts: $e');
      // Set default accounts
      _followedTwitterAccounts = [
        '44196397', // @elonmusk
        '783214',   // @twitter
      ];
    }
  }
  
  /// Save followed accounts to SharedPreferences
  Future<void> _saveFollowedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = json.encode(_followedTwitterAccounts);
      await prefs.setString('followed_twitter_accounts', accountsJson);
    } catch (e) {
      _logger.e('Error saving followed accounts: $e');
    }
  }
}