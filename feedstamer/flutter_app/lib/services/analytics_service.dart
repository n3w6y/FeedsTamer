import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

// Create a logger instance for this service
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

class AnalyticsService {
  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  // Make this nullable instead of late
  FirebaseAnalyticsObserver? _observer;
  
  Future<void> init() async {
    try {
      // Initialize observer
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);
      
      // Enable analytics collection
      await _analytics.setAnalyticsCollectionEnabled(true);
    } catch (e) {
      // Gracefully handle initialization errors
      logger.e('Analytics service initialization error: $e');
      // Create a dummy observer that does nothing if initialization fails
      _observer = null;
    }
  }
  
  // Get analytics observer for navigator - handle null case
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    // Return a dummy observer if the real one isn't initialized
    return _observer ?? FirebaseAnalyticsObserver(analytics: _analytics);
  }
  
  // Log a screen view
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }
  
  // Log user login
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }
  
  // Log user signup
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }
  
  // Log a custom event
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters?.cast<String, Object>() ?? <String, Object>{},
    );
  }
  
  // Log session start
  Future<void> logSessionStart() async {
    await _analytics.logEvent(
      name: 'session_start',
      parameters: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Log session end
  Future<void> logSessionEnd({required int durationSeconds}) async {
    await _analytics.logEvent(
      name: 'session_end',
      parameters: {
        'duration_seconds': durationSeconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Log content view
  Future<void> logContentView({
    required String contentId,
    required String contentType,
    required String platform,
    required String accountId,
  }) async {
    await _analytics.logEvent(
      name: 'content_view',
      parameters: {
        'content_id': contentId,
        'content_type': contentType,
        'platform': platform,
        'account_id': accountId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Log content interaction
  Future<void> logContentInteraction({
    required String contentId,
    required String interactionType, // like, save, share
    required String platform,
  }) async {
    await _analytics.logEvent(
      name: 'content_interaction',
      parameters: {
        'content_id': contentId,
        'interaction_type': interactionType,
        'platform': platform,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Log account follow
  Future<void> logAccountFollow({
    required String accountId,
    required String platform,
  }) async {
    await _analytics.logEvent(
      name: 'account_follow',
      parameters: {
        'account_id': accountId,
        'platform': platform,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Log account unfollow
  Future<void> logAccountUnfollow({
    required String accountId,
    required String platform,
  }) async {
    await _analytics.logEvent(
      name: 'account_unfollow',
      parameters: {
        'account_id': accountId,
        'platform': platform,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Log focus session
  Future<void> logFocusSession({
    required int durationMinutes,
    required bool completed,
  }) async {
    await _analytics.logEvent(
      name: 'focus_session',
      parameters: {
        'duration_minutes': durationMinutes,
        'completed': completed,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Log subscription start
  Future<void> logSubscription({
    required String plan, // free, premium, family, enterprise
    required String method, // annual, monthly
    double? value,
  }) async {
    await _analytics.logEvent(
      name: 'subscription',
      parameters: {
        'plan': plan,
        'method': method,
        'value': value ?? 0.0, // Default to 0.0 if null
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Set user properties
  Future<void> setUserProperty({required String name, required String? value}) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
  
  // Set user ID
  Future<void> setUserId(String? id) async {
    await _analytics.setUserId(id: id);
  }
}