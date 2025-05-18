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
  if (!kIsWeb) {
    if (Firebase.apps.isEmpty) { // Guard against duplicate initialization
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    // Set up Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Initialize services that depend on Firebase
    await NotificationService().init();
    await AnalyticsService().init();
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