import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart'; // Added for logging

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

class UserPreferences {
  final bool isFirstLaunch;
  final String theme; // 'light', 'dark', 'system'
  final bool notificationsEnabled;
  final String defaultView; // 'unified', 'platform'
  final String contentOrder; // 'chronological', 'platform'
  final bool showReadPosts;
  final bool sessionLimitsEnabled;
  final int dailyLimitMinutes;
  final int reminderIntervalMinutes;

  UserPreferences({
    this.isFirstLaunch = true,
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.defaultView = 'unified',
    this.contentOrder = 'chronological',
    this.showReadPosts = false,
    this.sessionLimitsEnabled = false,
    this.dailyLimitMinutes = 60,
    this.reminderIntervalMinutes = 20,
  });

  // Convert preferences to JSON
  Map<String, dynamic> toJson() {
    return {
      'isFirstLaunch': isFirstLaunch,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'defaultView': defaultView,
      'contentOrder': contentOrder,
      'showReadPosts': showReadPosts,
      'sessionLimitsEnabled': sessionLimitsEnabled,
      'dailyLimitMinutes': dailyLimitMinutes,
      'reminderIntervalMinutes': reminderIntervalMinutes,
    };
  }

  // Create preferences from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isFirstLaunch: json['isFirstLaunch'] ?? true,
      theme: json['theme'] ?? 'system',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      defaultView: json['defaultView'] ?? 'unified',
      contentOrder: json['contentOrder'] ?? 'chronological',
      showReadPosts: json['showReadPosts'] ?? false,
      sessionLimitsEnabled: json['sessionLimitsEnabled'] ?? false,
      dailyLimitMinutes: json['dailyLimitMinutes'] ?? 60,
      reminderIntervalMinutes: json['reminderIntervalMinutes'] ?? 20,
    );
  }

  // Create a copy with updated values
  UserPreferences copyWith({
    bool? isFirstLaunch,
    String? theme,
    bool? notificationsEnabled,
    String? defaultView,
    String? contentOrder,
    bool? showReadPosts,
    bool? sessionLimitsEnabled,
    int? dailyLimitMinutes,
    int? reminderIntervalMinutes,
  }) {
    return UserPreferences(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultView: defaultView ?? this.defaultView,
      contentOrder: contentOrder ?? this.contentOrder,
      showReadPosts: showReadPosts ?? this.showReadPosts,
      sessionLimitsEnabled: sessionLimitsEnabled ?? this.sessionLimitsEnabled,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      reminderIntervalMinutes: reminderIntervalMinutes ?? this.reminderIntervalMinutes,
    );
  }
}

class PreferenceService {
  // Singleton pattern
  static final PreferenceService _instance = PreferenceService._internal();
  factory PreferenceService() => _instance;
  PreferenceService._internal();

  // Keys for SharedPreferences
  static const String _preferencesKey = 'user_preferences';

  // Get user preferences
  Future<UserPreferences> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if preferences exist
    if (prefs.containsKey(_preferencesKey)) {
      // Get preferences from storage
      final String prefsJson = prefs.getString(_preferencesKey) ?? '{}';
      
      try {
        final Map<String, dynamic> prefsMap = jsonDecode(prefsJson);
        return UserPreferences.fromJson(prefsMap);
      } catch (e) {
        logger.e('Error parsing preferences: $e'); // Replaced print() with logger
        return UserPreferences();
      }
    } else {
      // Return default preferences
      return UserPreferences();
    }
  }

  // Save user preferences
  Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    
    final String prefsJson = jsonEncode(preferences.toJson());
    await prefs.setString(_preferencesKey, prefsJson);
  }

  // Update first launch status
  Future<void> setFirstLaunchComplete() async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(isFirstLaunch: false));
  }

  // Update theme preference
  Future<void> setTheme(String theme) async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(theme: theme));
  }

  // Update notifications preference
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(notificationsEnabled: enabled));
  }

  // Update default view preference
  Future<void> setDefaultView(String view) async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(defaultView: view));
  }

  // Update content order preference
  Future<void> setContentOrder(String order) async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(contentOrder: order));
  }

  // Update show read posts preference
  Future<void> setShowReadPosts(bool show) async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(showReadPosts: show));
  }

  // Update session limits preferences
  Future<void> setSessionLimits({
    required bool enabled,
    required int dailyLimit,
    required int reminderInterval,
  }) async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(
      sessionLimitsEnabled: enabled,
      dailyLimitMinutes: dailyLimit,
      reminderIntervalMinutes: reminderInterval,
    ));
  }

  // Clear all preferences
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preferencesKey);
  }
}