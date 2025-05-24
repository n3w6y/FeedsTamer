// lib/services/preference_service.dart
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences and app settings
class PreferencesService {
  final Logger _logger = Logger();
  
  // Keys for preferences
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyUseSystemTheme = 'use_system_theme';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyDevMenuEnabled = 'dev_menu_enabled';
  static const String _keyLastSeen = 'last_seen';
  
  // Singleton instance
  static final PreferencesService _instance = PreferencesService._internal();
  
  // Factory constructor
  factory PreferencesService() {
    return _instance;
  }
  
  // Private constructor
  PreferencesService._internal();
  
  /// Check if this is the first launch of the app
  Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !prefs.containsKey(_keyFirstLaunch) || prefs.getBool(_keyFirstLaunch) == true;
    } catch (e) {
      _logger.e('Error checking first launch: $e');
      return true; // Default to true if error
    }
  }
  
  /// Set first launch to complete
  Future<void> setFirstLaunchComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyFirstLaunch, false);
    } catch (e) {
      _logger.e('Error setting first launch complete: $e');
    }
  }
  
  /// Check if onboarding has been completed
  Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyOnboardingComplete) ?? false;
    } catch (e) {
      _logger.e('Error checking onboarding completion: $e');
      return false; // Default to false if error
    }
  }
  
  /// Set onboarding as completed
  Future<void> setOnboardingComplete({bool complete = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboardingComplete, complete);
    } catch (e) {
      _logger.e('Error setting onboarding complete: $e');
    }
  }
  
  /// Get the theme mode preference (0 = light, 1 = dark)
  Future<int> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyThemeMode) ?? 0; // Default to light theme
    } catch (e) {
      _logger.e('Error getting theme mode: $e');
      return 0; // Default to light theme if error
    }
  }
  
  /// Set the theme mode preference
  Future<void> setThemeMode(int mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyThemeMode, mode);
    } catch (e) {
      _logger.e('Error setting theme mode: $e');
    }
  }
  
  /// Check if system theme should be used
  Future<bool> useSystemTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyUseSystemTheme) ?? true; // Default to true
    } catch (e) {
      _logger.e('Error checking system theme usage: $e');
      return true; // Default to true if error
    }
  }
  
  /// Set whether to use system theme
  Future<void> setUseSystemTheme(bool use) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyUseSystemTheme, use);
    } catch (e) {
      _logger.e('Error setting system theme usage: $e');
    }
  }
  
  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyNotificationsEnabled) ?? true; // Default to true
    } catch (e) {
      _logger.e('Error checking notifications status: $e');
      return true; // Default to true if error
    }
  }
  
  /// Set notifications enabled status
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNotificationsEnabled, enabled);
    } catch (e) {
      _logger.e('Error setting notifications status: $e');
    }
  }
  
  /// Get language code preference
  Future<String> getLanguageCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyLanguageCode) ?? 'en'; // Default to English
    } catch (e) {
      _logger.e('Error getting language code: $e');
      return 'en'; // Default to English if error
    }
  }
  
  /// Set language code preference
  Future<void> setLanguageCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguageCode, code);
    } catch (e) {
      _logger.e('Error setting language code: $e');
    }
  }
  
  /// Check if developer menu is enabled
  Future<bool> isDevMenuEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyDevMenuEnabled) ?? true; // Default to true in development
    } catch (e) {
      _logger.e('Error checking dev menu status: $e');
      return true; // Default to true if error
    }
  }
  
  /// Set developer menu enabled status
  Future<void> setDevMenuEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDevMenuEnabled, enabled);
    } catch (e) {
      _logger.e('Error setting dev menu status: $e');
    }
  }
  
  /// Update last seen timestamp
  Future<void> updateLastSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastSeen, DateTime.now().toIso8601String());
    } catch (e) {
      _logger.e('Error updating last seen: $e');
    }
  }
  
  /// Get last seen timestamp
  Future<DateTime?> getLastSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSeenStr = prefs.getString(_keyLastSeen);
      if (lastSeenStr != null) {
        return DateTime.parse(lastSeenStr);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting last seen: $e');
      return null;
    }
  }
  
  /// Clear all preferences (for testing/reset)
  Future<void> clearAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _logger.i('All preferences cleared');
    } catch (e) {
      _logger.e('Error clearing preferences: $e');
    }
  }
  
  /// Get all preferences as a map (for debugging)
  Future<Map<String, dynamic>> getAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'first_launch': prefs.getBool(_keyFirstLaunch),
        'onboarding_complete': prefs.getBool(_keyOnboardingComplete),
        'theme_mode': prefs.getInt(_keyThemeMode),
        'use_system_theme': prefs.getBool(_keyUseSystemTheme),
        'notifications_enabled': prefs.getBool(_keyNotificationsEnabled),
        'language_code': prefs.getString(_keyLanguageCode),
        'dev_menu_enabled': prefs.getBool(_keyDevMenuEnabled),
        'last_seen': prefs.getString(_keyLastSeen),
      };
    } catch (e) {
      _logger.e('Error getting all preferences: $e');
      return {};
    }
  }
}