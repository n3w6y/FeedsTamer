import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feedstamer/firebase_options.dart';
import 'package:feedstamer/screens/splash_screen.dart';
import 'package:feedstamer/constants/theme.dart';
import 'package:feedstamer/services/analytics_service.dart';
import 'package:feedstamer/services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logger/logger.dart'; // Added for logging

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logger.i('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Initialize Firebase only on non-web platforms
  bool firebaseInitialized = false;
  if (!kIsWeb) {
    try {
      logger.i('Checking Firebase.apps: ${Firebase.apps.length}');
      if (Firebase.apps.isEmpty) {
        logger.i('Initializing Firebase...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        logger.i('Firebase initialized successfully');
        firebaseInitialized = true;
      } else {
        logger.i('Firebase already initialized, skipping initialization');
        firebaseInitialized = true;
      }
    } catch (e) {
      // Add error catching to prevent crashes
      logger.e('Firebase initialization error: $e');
      // Continue app execution even if Firebase fails
      firebaseInitialized = false;
    }
    
    // Only initialize these services if Firebase initialized successfully
    if (firebaseInitialized) {
      try {
        logger.i('Setting up Firebase Messaging...');
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        
        logger.i('Initializing NotificationService...');
        await NotificationService().init();
        
        logger.i('Initializing AnalyticsService...');
        await AnalyticsService().init();
        
        logger.i('Service initialization complete');
      } catch (e) {
        logger.e('Service initialization error: $e');
        // Continue app execution even if service initialization fails
      }
    } else {
      // Initialize with empty implementations
      logger.i('Initializing services with minimal functionality due to Firebase initialization failure');
      await AnalyticsService().init(); // This will create the dummy observer
    }
  }
  
  runApp(
    const ProviderScope(
      child: FeedsTamerApp(),
    ),
  );
}

class FeedsTamerApp extends ConsumerWidget {
  const FeedsTamerApp({super.key}); // Converted to super parameter

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'FeedsTamer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
      navigatorObservers: [
        if (!kIsWeb) AnalyticsService().getAnalyticsObserver(),
      ],
    );
  }
}