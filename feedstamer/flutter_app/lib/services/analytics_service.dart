// lib/services/analytics_service.dart
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for tracking user analytics and app usage
class AnalyticsService {
  final Logger _logger = Logger();
  bool _isInitialized = false;
  bool _isEnabled = true;
  
  // Usage tracking
  Map<String, int> _screenViews = {};
  Map<String, int> _featureUsage = {};
  int _appOpenCount = 0;
  int _totalSessionTime = 0; // in seconds
  DateTime? _sessionStartTime;
  
  // Singleton instance
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;
  
  // Private constructor
  AnalyticsService._internal();
  
  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load analytics preferences
      _isEnabled = prefs.getBool('analytics_enabled') ?? true;
      
      // Load stored analytics data
      final screenViewsJson = prefs.getString('analytics_screen_views');
      if (screenViewsJson != null) {
        final Map<String, dynamic> data = json.decode(screenViewsJson);
        _screenViews = Map<String, int>.from(data);
      }
      
      final featureUsageJson = prefs.getString('analytics_feature_usage');
      if (featureUsageJson != null) {
        final Map<String, dynamic> data = json.decode(featureUsageJson);
        _featureUsage = Map<String, int>.from(data);
      }
      
      _appOpenCount = prefs.getInt('analytics_app_open_count') ?? 0;
      _totalSessionTime = prefs.getInt('analytics_total_session_time') ?? 0;
      
      // Increment app open count
      _appOpenCount++;
      await prefs.setInt('analytics_app_open_count', _appOpenCount);
      
      // Start session timer
      _sessionStartTime = DateTime.now();
      
      _isInitialized = true;
      _logger.i('Analytics service initialized');
    } catch (e) {
      _logger.e('Error initializing analytics service: $e');
    }
  }
  
  /// Configure analytics settings
  Future<void> configure({required bool enabled}) async {
    _isEnabled = enabled;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('analytics_enabled', enabled);
      _logger.i('Analytics ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.e('Error configuring analytics: $e');
    }
  }
  
  /// Track a screen view
  Future<void> trackScreenView(String screenName) async {
    if (!_isEnabled || !_isInitialized) return;
    
    try {
      _screenViews[screenName] = (_screenViews[screenName] ?? 0) + 1;
      await _saveAnalyticsData();
    } catch (e) {
      _logger.e('Error tracking screen view: $e');
    }
  }
  
  /// Track feature usage
  Future<void> trackFeatureUsage(String featureName) async {
    if (!_isEnabled || !_isInitialized) return;
    
    try {
      _featureUsage[featureName] = (_featureUsage[featureName] ?? 0) + 1;
      await _saveAnalyticsData();
    } catch (e) {
      _logger.e('Error tracking feature usage: $e');
    }
  }
  
  /// End the current session and update session time
  Future<void> endSession() async {
    if (!_isEnabled || !_isInitialized || _sessionStartTime == null) return;
    
    try {
      final sessionEnd = DateTime.now();
      final sessionDuration = sessionEnd.difference(_sessionStartTime!).inSeconds;
      _totalSessionTime += sessionDuration;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('analytics_total_session_time', _totalSessionTime);
      
      _sessionStartTime = null;
      _logger.i('Session ended, duration: $sessionDuration seconds');
    } catch (e) {
      _logger.e('Error ending session: $e');
    }
  }
  
  /// Get screen view statistics
  Map<String, int> getScreenViewStats() {
    return Map.unmodifiable(_screenViews);
  }
  
  /// Get feature usage statistics
  Map<String, int> getFeatureUsageStats() {
    return Map.unmodifiable(_featureUsage);
  }
  
  /// Get total app usage statistics
  Map<String, dynamic> getUsageStats() {
    final now = DateTime.now();
    final currentSessionTime = _sessionStartTime != null 
        ? now.difference(_sessionStartTime!).inSeconds 
        : 0;
    
    return {
      'app_open_count': _appOpenCount,
      'total_session_time': _totalSessionTime + currentSessionTime,
      'average_session_time': _appOpenCount > 0 
          ? (_totalSessionTime + currentSessionTime) / _appOpenCount 
          : 0,
    };
  }
  
  /// Clear all analytics data
  Future<void> clearAnalyticsData() async {
    try {
      _screenViews.clear();
      _featureUsage.clear();
      _appOpenCount = 0;
      _totalSessionTime = 0;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('analytics_screen_views');
      await prefs.remove('analytics_feature_usage');
      await prefs.remove('analytics_app_open_count');
      await prefs.remove('analytics_total_session_time');
      
      _logger.i('Analytics data cleared');
    } catch (e) {
      _logger.e('Error clearing analytics data: $e');
    }
  }
  
  /// Save analytics data to shared preferences
  Future<void> _saveAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('analytics_screen_views', json.encode(_screenViews));
      await prefs.setString('analytics_feature_usage', json.encode(_featureUsage));
    } catch (e) {
      _logger.e('Error saving analytics data: $e');
    }
  }
}