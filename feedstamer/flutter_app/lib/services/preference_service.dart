// lib/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class PreferencesService {
  // Singleton pattern
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();
  
  final Logger logger = Logger();
  
  // Preferences keys
  static const String _completedOnboardingKey = 'completed_onboarding';
  static const String _darkModeKey = 'dark_mode';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _lastRefreshKey = 'last_refresh';
  static const String _developerModeKey = 'developer_mode';
  
  // Check if onboarding has been completed
  Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_completedOnboardingKey) ?? false;
    } catch (e) {
      logger.e('Error checking onboarding status: $e');
      return false;
    }
  }
  
  // Set onboarding as completed
  Future<void> setOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_completedOnboardingKey, true);
    } catch (e) {
      logger.e('Error setting onboarding as completed: $e');
    }
  }
  
  // Reset onboarding status (for development)
  Future<void> resetOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_completedOnboardingKey, false);
    } catch (e) {
      logger.e('Error resetting onboarding status: $e');
    }
  }
  
  // Get dark mode preference
  Future<bool> isDarkModeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_darkModeKey) ?? false;
    } catch (e) {
      logger.e('Error getting dark mode preference: $e');
      return false;
    }
  }
  
  // Set dark mode preference
  Future<void> setDarkModeEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, enabled);
    } catch (e) {
      logger.e('Error setting dark mode preference: $e');
    }
  }
  
  // Get notifications preference
  Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationsEnabledKey) ?? true;
    } catch (e) {
      logger.e('Error getting notifications preference: $e');
      return true;
    }
  }
  
  // Set notifications preference
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);
    } catch (e) {
      logger.e('Error setting notifications preference: $e');
    }
  }
  
  // Get last refresh time
  Future<DateTime?> getLastRefreshTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRefreshMillis = prefs.getInt(_lastRefreshKey);
      
      if (lastRefreshMillis == null) {
        return null;
      }
      
      return DateTime.fromMillisecondsSinceEpoch(lastRefreshMillis);
    } catch (e) {
      logger.e('Error getting last refresh time: $e');
      return null;
    }
  }
  
  // Set last refresh time
  Future<void> setLastRefreshTime(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastRefreshKey, time.millisecondsSinceEpoch);
    } catch (e) {
      logger.e('Error setting last refresh time: $e');
    }
  }
  
  // Get developer mode status
  Future<bool> isDeveloperModeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_developerModeKey) ?? false;
    } catch (e) {
      logger.e('Error getting developer mode status: $e');
      return false;
    }
  }
  
  // Set developer mode status
  Future<void> setDeveloperModeEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_developerModeKey, enabled);
    } catch (e) {
      logger.e('Error setting developer mode status: $e');
    }
  }
  
  // Clear all preferences (for logout or testing)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      logger.e('Error clearing preferences: $e');
    }
  }
}