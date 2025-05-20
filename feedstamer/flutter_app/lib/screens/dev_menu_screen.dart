import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:feedstamer/services/preference_service.dart';
import 'package:feedstamer/screens/auth/login_screen.dart';
import 'package:feedstamer/screens/home/home_screen.dart';
import 'package:feedstamer/screens/onboarding/onboarding_screen.dart';

/// A developer menu for navigation during development.
/// This screen should only be used during development and testing.
class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Menu'),
        backgroundColor: Colors.red.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(title: 'Navigation'),
            _NavButton(
              title: 'Onboarding Screen',
              icon: Icons.start,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                );
              },
            ),
            _NavButton(
              title: 'Login Screen',
              icon: Icons.login,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
            _NavButton(
              title: 'Home Screen',
              icon: Icons.home,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            
            const SizedBox(height: 16),
            const _Header(title: 'Preferences'),
            _NavButton(
              title: 'Mark Onboarding as Completed',
              icon: Icons.check_circle,
              onPressed: () async {
                await PreferenceService().setFirstLaunchComplete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Onboarding marked as completed')),
                  );
                }
              },
            ),
            _NavButton(
              title: 'Reset Onboarding (First Launch)',
              icon: Icons.refresh,
              onPressed: () async {
                final preferences = await PreferenceService().getPreferences();
                await PreferenceService().savePreferences(
                  preferences.copyWith(isFirstLaunch: true),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Onboarding reset - app will show onboarding again')),
                  );
                }
              },
            ),
            _NavButton(
              title: 'Clear All Preferences',
              icon: Icons.delete_forever,
              color: Colors.red,
              onPressed: () async {
                await PreferenceService().clearPreferences();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All preferences cleared')),
                  );
                }
              },
            ),
            
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'This menu is only available in debug mode.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows this dev menu when in debug mode, otherwise shows the provided child widget
class DevMenuWrapper extends StatelessWidget {
  final Widget child;
  final bool forceShowDevMenu;
  
  const DevMenuWrapper({
    super.key, 
    required this.child,
    this.forceShowDevMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only show the dev menu in debug mode or when forced
    if (kDebugMode || forceShowDevMenu) {
      return Scaffold(
        body: child,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red.shade900,
          child: const Icon(Icons.developer_mode),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const DevMenuScreen()),
            );
          },
        ),
      );
    }
    
    // In release mode, just show the child widget
    return child;
  }
}

class _Header extends StatelessWidget {
  final String title;
  
  const _Header({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  
  const _NavButton({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}