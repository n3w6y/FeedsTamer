import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Feedstamer/firebase_options.dart';
import 'package:Feedstamer/screens/splash_screen.dart';
import 'package:Feedstamer/constants/theme.dart';
import 'package:Feedstamer/services/analytics_service.dart';
import 'package:Feedstamer/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize services
  await NotificationService().init();
  await AnalyticsService().init();
  
  runApp(
    const ProviderScope(
      child: FeedstamerApp(),
    ),
  );
}

class FeedstamerApp extends ConsumerWidget {
  const FeedstamerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Feedstamer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
      navigatorObservers: [
        AnalyticsService().getAnalyticsObserver(),
      ],
    );
  }
}

// Note: Create firebase_options.dart by running:
// flutterfire configure
// This file is not included in this code.