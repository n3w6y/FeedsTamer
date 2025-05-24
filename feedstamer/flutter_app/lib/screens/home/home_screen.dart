// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:feedstamer/screens/home/feed_screen.dart';
import 'package:feedstamer/screens/discover/discover_screen.dart';
import 'package:feedstamer/screens/profile/profile_screen.dart';
import 'package:feedstamer/screens/analytics/analytics_screen.dart';
import 'package:feedstamer/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  
  final List<Widget> _pages = [
    const FeedScreen(),
    const DiscoverScreen(),
    const ProfileScreen(),
    const AnalyticsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Removed the unused 'theme' variable
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('FeedsTamer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout, // Extracted to a separate method
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.rss_feed),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
  
  // Extracted method for logout with proper context handling
  void _handleLogout() async {
    // Store mounted state before async operation
    final isCurrentlyMounted = mounted;
    
    await _authService.signOut();
    
    // Check if widget is still mounted before using BuildContext
    if (isCurrentlyMounted && mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}