import 'package:feedstamer/models/tweet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedService {
  // Singleton pattern
  static final FeedService _instance = FeedService._internal();
  factory FeedService() => _instance;
  FeedService._internal();
  
  // In-memory cache for demo
  final Map<String, bool> _readTweets = {};
  DateTime? _lastFetchTime;
  
  // Get last fetch time
  DateTime? getLastFetchTime() {
    return _lastFetchTime;
  }
  
  // Mark tweet as read
  Future<void> markTweetAsRead(String tweetId) async {
    _readTweets[tweetId] = true;
    
    // Save to persistent storage in a real app
    try {
      final prefs = await SharedPreferences.getInstance();
      final readTweets = prefs.getStringList('read_tweets') ?? [];
      if (!readTweets.contains(tweetId)) {
        readTweets.add(tweetId);
        await prefs.setStringList('read_tweets', readTweets);
      }
    } catch (e) {
      // Handle error
      print('Error saving read state: $e');
    }
  }
  
  // Get feed tweets
  Future<List<Tweet>> getFeedTweets({DateTime? since}) async {
    // Update last fetch time
    _lastFetchTime = DateTime.now();
    
    // In a real app, fetch from API
    // For now, return mock data
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    return _getMockTweets();
  }
  
  // Mock data for demo
  List<Tweet> _getMockTweets() {
    final authors = [
      TwitterUser(
        id: '1',
        username: 'elonmusk',
        displayName: 'Elon Musk',
        profileImageUrl: 'https://pbs.twimg.com/profile_images/1683325380441128960/yRsRRjGO_400x400.jpg',
      ),
      TwitterUser(
        id: '2',
        username: 'BillGates',
        displayName: 'Bill Gates',
        profileImageUrl: 'https://pbs.twimg.com/profile_images/1414439092373254147/JdS8yLGI_400x400.jpg',
      ),
      TwitterUser(
        id: '3',
        username: 'tim_cook',
        displayName: 'Tim Cook',
        profileImageUrl: 'https://pbs.twimg.com/profile_images/1535420431766671360/Pwq-1eJc_400x400.jpg',
      ),
    ];
    
    return [
      Tweet(
        id: '1',
        text: 'Excited about the future of AI! What do you think will be the biggest breakthrough in the next 5 years?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        author: authors[0],
        likeCount: 5432,
        retweetCount: 1234,
        replyCount: 543,
        isRead: _readTweets['1'] ?? false,
      ),
      Tweet(
        id: '2',
        text: 'Climate change requires global cooperation like we've never seen before. I'm optimistic that we can make progress.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        author: authors[1],
        likeCount: 8765,
        retweetCount: 2345,
        replyCount: 876,
        isRead: _readTweets['2'] ?? false,
      ),
      Tweet(
        id: '3',
        text: 'Privacy is a fundamental human right. At Apple, it's also one of our core values.',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        author: authors[2],
        likeCount: 7654,
        retweetCount: 1987,
        replyCount: 765,
        isRead: _readTweets['3'] ?? false,
      ),
      Tweet(
        id: '4',
        text: 'Just had a great conversation with the team about our latest projects. Can't wait to share more soon!',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        author: authors[0],
        likeCount: 3456,
        retweetCount: 876,
        replyCount: 234,
        isRead: _readTweets['4'] ?? false,
      ),
      Tweet(
        id: '5',
        text: 'Reading is still the main way that I both learn new things and test my understanding. How do you learn?',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        author: authors[1],
        likeCount: 6789,
        retweetCount: 1543,
        replyCount: 654,
        isRead: _readTweets['5'] ?? false,
      ),
    ];
  }
}