// lib/screens/dev_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:feedstamer/services/preference_service.dart';
import 'package:feedstamer/services/auth_service.dart';
import 'package:feedstamer/services/social_service.dart';
import 'package:feedstamer/services/subscription_service.dart';
import 'package:feedstamer/screens/auth/login_screen.dart';
import 'package:feedstamer/screens/onboarding/onboarding_screen.dart';
import 'package:feedstamer/screens/home/home_screen.dart';
import 'package:feedstamer/screens/splash/splash_screen.dart';

/// Developer menu for easily navigating and testing different app states
class DevMenuScreen extends StatefulWidget {
  const DevMenuScreen({super.key});

  @override
  State<DevMenuScreen> createState() => _DevMenuScreenState();
}

class _DevMenuScreenState extends State<DevMenuScreen> {
  final Logger _logger = Logger();
  final PreferencesService _preferencesService = PreferencesService();
  final AuthService _authService = AuthService();
  bool _onboardingComplete = false;
  bool _devMenuEnabled = true;
  Map<String, dynamic> _preferences = {};
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final onboardingComplete = await _preferencesService.hasCompletedOnboarding();
    final devMenuEnabled = await _preferencesService.isDevMenuEnabled();
    final allPrefs = await _preferencesService.getAllPreferences();
    
    if (mounted) {
      setState(() {
        _onboardingComplete = onboardingComplete;
        _devMenuEnabled = devMenuEnabled;
        _preferences = allPrefs;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Menu'),
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNavigationSection(),
              const Divider(),
              _buildStateSection(),
              const Divider(),
              _buildTestSection(),
              const Divider(),
              _buildPreferencesSection(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavigationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Navigation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _navButton('Splash', () => _navigateTo(const SplashScreen())),
            _navButton('Onboarding', () => _navigateTo(const OnboardingScreen())),
            _navButton('Login', () => _navigateTo(const LoginScreen())),
            _navButton('Home', () => _navigateTo(const HomeScreen())),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'App State',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Onboarding completed:'),
            const SizedBox(width: 8),
            Switch(
              value: _onboardingComplete,
              onChanged: (value) {
                _preferencesService.setOnboardingComplete(complete: value).then((_) {
                  if (mounted) {
                    setState(() {
                      _onboardingComplete = value;
                    });
                    _loadPreferences();
                  }
                });
              },
            ),
          ],
        ),
        Row(
          children: [
            const Text('Dev menu enabled:'),
            const SizedBox(width: 8),
            Switch(
              value: _devMenuEnabled,
              onChanged: (value) {
                _preferencesService.setDevMenuEnabled(value).then((_) {
                  if (mounted) {
                    setState(() {
                      _devMenuEnabled = value;
                    });
                    _loadPreferences();
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            _preferencesService.clearAllPreferences().then((_) {
              _loadPreferences();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All preferences cleared')),
                );
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Reset All Preferences'),
        ),
      ],
    );
  }
  
  Widget _buildTestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test Features',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _actionButton('Test Free Tier', () => _testSubscriptionTier('free')),
            _actionButton('Test Premium', () => _testSubscriptionTier('premium')),
            _actionButton('Test Business', () => _testSubscriptionTier('business')),
            _actionButton('Record Streak', _testStreak),
            _actionButton('Sign Out', _signOut),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Preferences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _preferences.entries.map((entry) {
              return Text('${entry.key}: ${entry.value}');
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _loadPreferences,
          child: const Text('Refresh Preferences'),
        ),
      ],
    );
  }
  
  Widget _navButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
      child: Text(label),
    );
  }
  
  Widget _actionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
      ),
      child: Text(label),
    );
  }
  
  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
  
  Future<void> _testSubscriptionTier(String tierId) async {
    try {
      await SubscriptionService.instance.setTestSubscription(
        tierId,
        durationDays: 30,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Set to $tierId tier for 30 days')),
        );
      }
    } catch (e) {
      _logger.e('Error setting test subscription: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  Future<void> _testStreak() async {
    try {
      final success = await SocialService.instance.recordDailyActivity();
      final streakInfo = SocialService.instance.getStreakInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Streak recorded: Day ${streakInfo['current_streak']}'
                  : 'Streak already recorded today',
            ),
          ),
        );
      }
    } catch (e) {
      _logger.e('Error recording streak: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
        
        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _logger.e('Error signing out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}