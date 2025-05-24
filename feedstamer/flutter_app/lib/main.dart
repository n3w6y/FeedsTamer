// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import 'package:feedstamer/firebase_options.dart';
import 'package:feedstamer/screens/auth/login_screen.dart';
import 'package:feedstamer/screens/auth/verify_email_screen.dart';
import 'package:feedstamer/screens/home/home_screen.dart';
import 'package:feedstamer/screens/onboarding/onboarding_screen.dart';
import 'package:feedstamer/screens/splash/splash_screen.dart';
import 'package:feedstamer/services/auth_service.dart';
import 'package:feedstamer/services/analytics_service.dart';
import 'package:feedstamer/services/preferences_service.dart';
import 'package:feedstamer/theme/app_theme.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i('Firebase initialized successfully');
  } catch (e) {
    logger.e('Firebase initialization error: $e');
    // Continue with minimal functionality
  }

  // Initialize services
  final authService = AuthService();
  await authService.initialize();
  
  // Initialize other services
  try {
    await AnalyticsService.instance.initialize();
    logger.i('Analytics service initialized successfully');
  } catch (e) {
    logger.i('Analytics service initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FeedsTamer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const AppStartupHandler(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class AppStartupHandler extends StatefulWidget {
  const AppStartupHandler({super.key});

  @override
  State<AppStartupHandler> createState() => _AppStartupHandlerState();
}

class _AppStartupHandlerState extends State<AppStartupHandler> {
  final AuthService _authService = AuthService();
  final PreferencesService _preferencesService = PreferencesService();

  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for at least 2 seconds
    
    if (!mounted) return;

    // Check if user has completed onboarding
    final hasCompletedOnboarding = await _preferencesService.hasCompletedOnboarding();
    
    if (!hasCompletedOnboarding) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
      return;
    }

    // Check if user is signed in
    final currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      // User is not signed in, go to login screen
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // User is signed in
      
      // Check if email verification is required
      if (!currentUser.emailVerified && currentUser.email != null) {
        // Email is not verified, go to verification screen
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VerifyEmailScreen(email: currentUser.email!),
          ),
        );
      } else {
        // User is signed in and email is verified, go to home screen
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}