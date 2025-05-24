import 'package:flutter/material.dart';
import 'package:feedstamer/models/tweet.dart';
import 'package:feedstamer/models/twitter_user.dart';
import 'package:feedstamer/screens/feed/account_selection_screen.dart';
import 'package:feedstamer/services/feed_service.dart';
import 'package:feedstamer/services/account_service.dart';
import 'package:feedstamer/services/x_service_integrator.dart';
import 'package:feedstamer/widgets/tweet_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FeedService _feedService = FeedService();
  final AccountService _accountService = AccountService();
  final XServiceIntegrator _xServiceIntegrator = XServiceIntegrator();
  final ScrollController _scrollController = ScrollController();
  
  List<Tweet> _tweets = [];
  List<TwitterUser> _followedAccounts = [];
  bool _isLoading = true;
  DateTime? _lastRefreshTime;
  bool _isUsingRealApi = false;
  
  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }
  
  Future<void> _initializeScreen() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check if we're using the real API
      _isUsingRealApi = _xServiceIntegrator.usingRealApi;
      
      // Get followed accounts
      _followedAccounts = _accountService.followedAccounts;
      
      // Get cached tweets
      _tweets = _feedService.getFeedTweets();
      
      // Get last refresh time
      _lastRefreshTime = await _feedService.getLastFetchTime();
      
      setState(() {
        _isLoading = false;
      });
      
      // If no accounts are followed, we'll show an empty state
      // If accounts are followed but no tweets, refresh the feed
      if (_followedAccounts.isNotEmpty && _tweets.isEmpty) {
        _refreshFeed();
      } else if (_followedAccounts.isEmpty) {
        // For development mode - add mock accounts if no accounts are followed
        await _xServiceIntegrator.setupMockData();
        
        // Update local variables
        _followedAccounts = _accountService.followedAccounts;
        _tweets = _feedService.getFeedTweets();
        
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing feed: $e')),
        );
      }
      
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _refreshFeed() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _xServiceIntegrator.refreshAllFeeds();
      
      // Update local variables
      _tweets = _feedService.getFeedTweets();
      _lastRefreshTime = await _feedService.getLastFetchTime();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing feed: $e')),
        );
      }
      
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _navigateToAccountSelection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountSelectionScreen(),
      ),
    );
    
    // When returning from account selection, refresh the feed
    setState(() {
      _followedAccounts = _accountService.followedAccounts;
    });
    
    _refreshFeed();
  }
  
  void _showApiStatus() {
    _xServiceIntegrator.showApiStatusDialog(context);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // API status badge
    final apiStatusBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _isUsingRealApi ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isUsingRealApi ? Icons.cloud_done : Icons.cloud_off,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            _isUsingRealApi ? 'Live API' : 'Mock Data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feed'),
        actions: [
          // API status indicator
          GestureDetector(
            onTap: _showApiStatus,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: apiStatusBadge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshFeed,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _navigateToAccountSelection,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: _isLoading && _tweets.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _followedAccounts.isEmpty
                ? _buildEmptyState(theme)
                : _buildFeedContent(theme),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAccountSelection,
        tooltip: 'Add accounts to follow',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Icon(
          Icons.feed_outlined,
          size: 80,
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
        const SizedBox(height: 24),
        Text(
          'Your feed is empty',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Add X accounts to start building your personalized feed',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: ElevatedButton.icon(
            onPressed: _navigateToAccountSelection,
            icon: const Icon(Icons.add),
            label: const Text('Add Accounts'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeedContent(ThemeData theme) {
    return Column(
      children: [
        // Feed info header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          child: Row(
            children: [
              // Followed accounts count
              Text(
                'Following: ${_followedAccounts.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              
              // Last updated time
              if (_lastRefreshTime != null)
                Text(
                  'Updated ${_formatRefreshTime(_lastRefreshTime!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        
        // Feed content
        Expanded(
          child: _tweets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.feed_outlined,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tweets found',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _refreshFeed,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _tweets.length,
                      itemBuilder: (context, index) {
                        final tweet = _tweets[index];
                        return TweetCard(
                          tweet: tweet,
                          onTap: () {
                            // Mark as read and refresh UI
                            setState(() {});
                          },
                        );
                      },
                    ),
                    
                    // Loading indicator
                    if (_isLoading)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
  
  String _formatRefreshTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '${time.month}/${time.day} at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}