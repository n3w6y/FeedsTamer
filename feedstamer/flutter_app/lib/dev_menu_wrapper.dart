import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/splash_screen.dart';

class DevMenuWrapper extends StatefulWidget {
  final Widget child;

  const DevMenuWrapper({super.key, required this.child});

  @override
  _DevMenuWrapperState createState() => _DevMenuWrapperState();
}

class _DevMenuWrapperState extends State<DevMenuWrapper> {
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main app content
        widget.child,

        // Persistent floating developer menu button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            mini: true,
            child: const Icon(Icons.developer_mode),
            onPressed: () {
              setState(() {
                _showMenu = !_showMenu;
              });
            },
          ),
        ),

        // Developer menu panel
        if (_showMenu)
          Positioned.fill(
            child: Material(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Developer Menu',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Divider(),
                      _buildNavigationSection(context),
                      const Divider(),
                      _buildPreferencesSection(context),
                      const Divider(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _showMenu = false;
                          });
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Navigation',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _navButton(context, 'Splash', SplashScreen()),
            _navButton(context, 'Onboarding', OnboardingScreen()),
            _navButton(context, 'Login', LoginScreen()),
            _navButton(context, 'Home', HomeScreen()),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset Onboarding'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('onboarding_completed', false);
                setState(() {
                  _showMenu = false;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Onboarding reset. Restart the app to see it.')),
                  );
                }
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Clear Auth'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_logged_in');
                setState(() {
                  _showMenu = false;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Auth state cleared.')),
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text('Reset All'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                setState(() {
                  _showMenu = false;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All preferences reset. Restart the app.')),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _navButton(BuildContext context, String label, Widget destination) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _showMenu = false;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Text(label),
    );
  }
}