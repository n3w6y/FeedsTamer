import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:feedstamer/services/twitter_api_service.dart';
import 'package:feedstamer/services/account_service.dart';
import 'package:feedstamer/services/feed_service.dart';

// This service helps integrate the X API with the app's UI and data flow
class XServiceIntegrator {
  // Singleton pattern
  static final XServiceIntegrator _instance = XServiceIntegrator._internal();
  factory XServiceIntegrator() => _instance;
  XServiceIntegrator._internal();

  final logger = Logger();
  
  final TwitterApiService _twitterApiService = TwitterApiService();
  final AccountService _accountService = AccountService();
  final FeedService _feedService = FeedService();

  // Flag to track if real API is being used
  bool _usingRealApi = false;
  bool get usingRealApi => _usingRealApi;
  
  // Initialize all services together
  Future<void> initialize() async {
    try {
      logger.i('Initializing X service integrator...');

      // Initialize Twitter API service
      await _twitterApiService.initialize();
      
      // Check if API service is ready
      _usingRealApi = await _twitterApiService.isReady();
      
      // Initialize account and feed services
      await _accountService.initialize();
      await _feedService.initialize();
      
      // Log initialization status
      if (_usingRealApi) {
        logger.i('X API integration enabled - using real API data');
      } else {
        logger.i('X API integration using mock data (API credentials not found or invalid)');
      }
      
      logger.i('X service integrator initialized successfully');
    } catch (e) {
      logger.e('Error initializing X service integrator: $e');
      _usingRealApi = false;
    }
  }
  
  // Show API status dialog to user
  void showApiStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_usingRealApi ? 'Using Real X API' : 'Using Mock Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _usingRealApi
                  ? 'FeedsTamer is connected to the X API and using real data.'
                  : 'FeedsTamer is using mock data for demonstration.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _usingRealApi ? Icons.check_circle : Icons.info,
                  color: _usingRealApi ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  _usingRealApi
                      ? 'API connection successful'
                      : 'API connection not configured',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _usingRealApi ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  // Refresh all feeds (using real API if available, mock data otherwise)
  Future<void> refreshAllFeeds() async {
    try {
      logger.i('Refreshing all feeds...');
      
      // If using real API, refresh from API
      if (_usingRealApi) {
        await _feedService.refreshFeed();
      } else {
        // Otherwise, use mock data
        await _feedService.addMockTweets();
      }
      
      logger.i('Feeds refreshed successfully');
    } catch (e) {
      logger.e('Error refreshing feeds: $e');
      // Fall back to mock data if API fails
      if (_usingRealApi) {
        logger.i('Falling back to mock data');
        await _feedService.addMockTweets();
      }
    }
  }
  
  // Add a new account to follow
  Future<bool> followNewAccount(String username) async {
    try {
      logger.i('Adding account to follow: $username');
      
      // If using real API, validate account first
      if (_usingRealApi) {
        final user = await _twitterApiService.getUserByUsername(username);
        
        if (user == null) {
          logger.w('Account not found: $username');
          return false;
        }
      }
      
      // Add account to followed accounts
      final success = await _accountService.followAccount(username);
      
      // Refresh feeds if successful
      if (success) {
        await refreshAllFeeds();
      }
      
      return success;
    } catch (e) {
      logger.e('Error following account: $e');
      return false;
    }
  }
  
  // Add mock accounts and tweets for demonstration
  Future<void> setupMockData() async {
    try {
      logger.i('Setting up mock data...');
      
      // Add mock accounts
      await _accountService.addMockAccounts();
      
      // Add mock tweets
      await _feedService.addMockTweets();
      
      logger.i('Mock data setup complete');
    } catch (e) {
      logger.e('Error setting up mock data: $e');
    }
  }
}