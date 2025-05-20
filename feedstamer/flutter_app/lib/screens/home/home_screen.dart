import 'package:flutter/material.dart';
import 'package:feedstamer/screens/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // Mock data for feed items
  final List<Map<String, dynamic>> _feedItems = [
    {
      'platform': 'Twitter',
      'author': '@flutterdev',
      'content': 'We just released Flutter 3.10 with tons of new features!',
      'timeAgo': '2h ago',
      'likes': 342,
      'comments': 56,
    },
    {
      'platform': 'Reddit',
      'author': 'r/FlutterDev',
      'content': 'What are your favorite state management solutions for Flutter? Riverpod vs Provider vs Bloc.',
      'timeAgo': '5h ago',
      'likes': 128,
      'comments': 87,
    },
    {
      'platform': 'Mastodon',
      'author': '@fluttercommunity',
      'content': 'Check out this new package for handling animations with ease.',
      'timeAgo': '8h ago',
      'likes': 75,
      'comments': 12,
    },
    {
      'platform': 'Twitter',
      'author': '@dartlang',
      'content': 'Dart 3.0 is here! Pattern matching, records, and more.',
      'timeAgo': '1d ago',
      'likes': 523,
      'comments': 92,
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    // In a real app, sign out from Firebase Auth
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('FeedsTamer'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildFeedTab();
      case 1:
        return _buildPlaceholderTab('Discover');
      case 2:
        return _buildPlaceholderTab('Profile');
      case 3:
        return _buildPlaceholderTab('Analytics');
      default:
        return _buildFeedTab();
    }
  }

  Widget _buildFeedTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _feedItems.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final item = _feedItems[index];
        return _FeedItemCard(
          platform: item['platform'],
          author: item['author'],
          content: item['content'],
          timeAgo: item['timeAgo'],
          likes: item['likes'],
          comments: item['comments'],
        );
      },
    );
  }

  Widget _buildPlaceholderTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '$tabName Tab',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This feature is coming soon!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedItemCard extends StatelessWidget {
  final String platform;
  final String author;
  final String content;
  final String timeAgo;
  final int likes;
  final int comments;

  const _FeedItemCard({
    required this.platform,
    required this.author,
    required this.content,
    required this.timeAgo,
    required this.likes,
    required this.comments,
  });

  IconData _getPlatformIcon() {
    switch (platform) {
      case 'Twitter':
        return Icons.chat_bubble;
      case 'Reddit':
        return Icons.forum;
      case 'Mastodon':
        return Icons.record_voice_over;
      default:
        return Icons.public;
    }
  }

  Color _getPlatformColor() {
    switch (platform) {
      case 'Twitter':
        return Colors.blue;
      case 'Reddit':
        return Colors.deepOrange;
      case 'Mastodon':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform and author info
            Row(
              children: [
                Icon(
                  _getPlatformIcon(),
                  color: _getPlatformColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  platform,
                  style: TextStyle(
                    color: _getPlatformColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  author,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Content
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: '$likes',
                  onPressed: () {},
                ),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '$comments',
                  onPressed: () {},
                ),
                _ActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onPressed: () {},
                ),
                _ActionButton(
                  icon: Icons.bookmark_border,
                  label: 'Save',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}