import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feedtamer/screens/home/feed_screen.dart';
import 'package:feedtamer/screens/home/accounts_screen.dart';
import 'package:feedtamer/screens/home/analytics_screen.dart';
import 'package:feedtamer/screens/home/settings_screen.dart';
import 'package:feedtamer/services/analytics_service.dart';
import 'package:feedtamer/services/timer_service.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  late TimerService _timerService;
  
  final List<Widget> _screens = [
    const FeedScreen(),
    const AccountsScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize timer service
    _timerService = TimerService();
    _timerService.startSession();
    
    // Log screen view
    AnalyticsService().logScreenView('HomeScreen');
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timerService.endSession();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background
      _timerService.pauseSession();
    } else if (state == AppLifecycleState.resumed) {
      // App coming to foreground
      _timerService.resumeSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);
    
    return Scaffold(
      body: IndexedStack(
        index: selectedTab,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (int index) {
          ref.read(selectedTabProvider.notifier).state = index;
          
          // Log tab change
          AnalyticsService().logEvent(
            'tab_selected',
            parameters: {'tab': _getTabName(index)},
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
  
  String _getTabName(int index) {
    switch (index) {
      case 0: return 'feed';
      case 1: return 'accounts';
      case 2: return 'analytics';
      case 3: return 'settings';
      default: return 'unknown';
    }
  }
}