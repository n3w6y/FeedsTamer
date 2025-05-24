import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:feedstamer/models/tweet.dart';
import 'package:feedstamer/models/twitter_user.dart';

class XApiService {
  // Singleton pattern
  static final XApiService _instance = XApiService._internal();
  factory XApiService() => _instance;
  XApiService._internal();
  
  final Logger logger = Logger();
  
  // API keys (replace with your own from environment variables or secure storage)
  // These should be stored securely in a production app
  final String _bearerToken = 'AAAAAAAAAAAAAAAAAAAAADOW1wEAAAAAgwUMi5I4A9ukPCbcymbiALKCKbU%3DYXVlEU4yh480u9ZwDRctQP8lYrPjcEfJkNLfwxYtneD7s2XHvQ';
  
  // Base URL for Twitter API v2
  final String _baseUrl = 'https://api.twitter.com/2';
  
  // Headers for API requests
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_bearerToken',
    'Content-Type': 'application/json',
  };
  
  // Get user by username
  Future<TwitterUser?> getUserByUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/by/username/$username?user.fields=profile_image_url,description,created_at,verified,protected,public_metrics'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          // Transform Twitter API v2 response to our model
          final userData = data['data'];
          
          return TwitterUser(
            id: userData['id'],
            username: userData['username'],
            name: userData['name'],
            profileImageUrl: userData['profile_image_url'],
            description: userData['description'],
            followerCount: userData['public_metrics']['followers_count'],
            followingCount: userData['public_metrics']['following_count'],
            createdAt: userData['created_at'] != null 
                ? DateTime.parse(userData['created_at']) 
                : null,
            isVerified: userData['verified'] ?? false,
            isProtected: userData['protected'] ?? false,
          );
        }
      } else {
        logger.e('Failed to get user: ${response.statusCode} - ${response.body}');
      }
      
      return null;
    } catch (e) {
      logger.e('Error getting user by username: $e');
      return null;
    }
  }
  
  // Search for users
  Future<List<TwitterUser>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/search?query=$query&user.fields=profile_image_url,description,created_at,verified,protected,public_metrics&max_results=10'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          final users = <TwitterUser>[];
          
          for (final userData in data['data']) {
            users.add(
              TwitterUser(
                id: userData['id'],
                username: userData['username'],
                name: userData['name'],
                profileImageUrl: userData['profile_image_url'],
                description: userData['description'],
                followerCount: userData['public_metrics']['followers_count'],
                followingCount: userData['public_metrics']['following_count'],
                createdAt: userData['created_at'] != null 
                    ? DateTime.parse(userData['created_at']) 
                    : null,
                isVerified: userData['verified'] ?? false,
                isProtected: userData['protected'] ?? false,
              ),
            );
          }
          
          return users;
        }
      } else {
        logger.e('Failed to search users: ${response.statusCode} - ${response.body}');
      }
      
      return [];
    } catch (e) {
      logger.e('Error searching users: $e');
      return [];
    }
  }
  
  // Get tweets for a user
  Future<List<Tweet>> getUserTweets(String userId, {DateTime? sinceId}) async {
    try {
      String url = '$_baseUrl/users/$userId/tweets?tweet.fields=created_at,public_metrics,entities&expansions=referenced_tweets.id&max_results=20';
      
      if (sinceId != null) {
        // Convert DateTime to Twitter API format
        url += '&start_time=${sinceId.toUtc().toIso8601String()}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          final tweets = <Tweet>[];
          
          // Get user information
          final user = await getUserById(userId);
          
          if (user == null) {
            return [];
          }
          
          for (final tweetData in data['data']) {
            final tweet = _parseTweetFromApiV2(tweetData, user, data['includes']);
            
            if (tweet != null) {
              tweets.add(tweet);
            }
          }
          
          return tweets;
        }
      } else {
        logger.e('Failed to get user tweets: ${response.statusCode} - ${response.body}');
      }
      
      return [];
    } catch (e) {
      logger.e('Error getting user tweets: $e');
      return [];
    }
  }
  
  // Get user by ID
  Future<TwitterUser?> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId?user.fields=profile_image_url,description,created_at,verified,protected,public_metrics'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          final userData = data['data'];
          
          return TwitterUser(
            id: userData['id'],
            username: userData['username'],
            name: userData['name'],
            profileImageUrl: userData['profile_image_url'],
            description: userData['description'],
            followerCount: userData['public_metrics']['followers_count'],
            followingCount: userData['public_metrics']['following_count'],
            createdAt: userData['created_at'] != null 
                ? DateTime.parse(userData['created_at']) 
                : null,
            isVerified: userData['verified'] ?? false,
            isProtected: userData['protected'] ?? false,
          );
        }
      } else {
        logger.e('Failed to get user by ID: ${response.statusCode} - ${response.body}');
      }
      
      return null;
    } catch (e) {
      logger.e('Error getting user by ID: $e');
      return null;
    }
  }
  
  // Parse Tweet from Twitter API v2 response
  Tweet? _parseTweetFromApiV2(
    Map<String, dynamic> tweetData, 
    TwitterUser user,
    Map<String, dynamic>? includes,
  ) {
    try {
      // Extract media URLs
      final mediaUrls = <String>[];
      
      if (tweetData['entities'] != null && 
          tweetData['entities']['urls'] != null) {
        for (final url in tweetData['entities']['urls']) {
          if (url['media_key'] != null && 
              includes != null && 
              includes['media'] != null) {
            
            // Find media in includes
            final media = includes['media'].firstWhere(
              (m) => m['media_key'] == url['media_key'],
              orElse: () => null,
            );
            
            if (media != null && media['url'] != null) {
              mediaUrls.add(media['url']);
            } else if (url['expanded_url'] != null && 
                      (url['expanded_url'].contains('photo') || 
                       url['expanded_url'].contains('video'))) {
              mediaUrls.add(url['expanded_url']);
            }
          }
        }
      }
      
      // Extract quoted tweet information
      String? quotedTweetId;
      String? quotedTweetText;
      String? quotedTweetUsername;
      
      if (tweetData['referenced_tweets'] != null) {
        for (final referencedTweet in tweetData['referenced_tweets']) {
          if (referencedTweet['type'] == 'quoted') {
            quotedTweetId = referencedTweet['id'];
            
            // Look for quoted tweet in includes
            if (includes != null && includes['tweets'] != null) {
              final quotedTweet = includes['tweets'].firstWhere(
                (t) => t['id'] == quotedTweetId,
                orElse: () => null,
              );
              
              if (quotedTweet != null) {
                quotedTweetText = quotedTweet['text'];
                
                // Find author
                if (quotedTweet['author_id'] != null && 
                    includes['users'] != null) {
                  final author = includes['users'].firstWhere(
                    (u) => u['id'] == quotedTweet['author_id'],
                    orElse: () => null,
                  );
                  
                  if (author != null) {
                    quotedTweetUsername = author['username'];
                  }
                }
              }
            }
          }
        }
      }
      
      return Tweet(
        id: tweetData['id'],
        text: tweetData['text'] ?? '',
        accountId: user.id,
        accountUsername: user.username,
        accountName: user.name,
        accountProfileImageUrl: user.profileImageUrl,
        createdAt: tweetData['created_at'] != null 
            ? DateTime.parse(tweetData['created_at']) 
            : DateTime.now(),
        isRead: false,
        mediaUrls: mediaUrls,
        likeCount: tweetData['public_metrics']?['like_count'] ?? 0,
        retweetCount: tweetData['public_metrics']?['retweet_count'] ?? 0,
        replyCount: tweetData['public_metrics']?['reply_count'] ?? 0,
        quotedTweetId: quotedTweetId,
        quotedTweetText: quotedTweetText,
        quotedTweetAccountUsername: quotedTweetUsername,
      );
    } catch (e) {
      logger.e('Error parsing tweet: $e');
      return null;
    }
  }
}