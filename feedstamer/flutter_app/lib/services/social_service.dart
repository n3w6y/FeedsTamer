// lib/services/social_service.dart
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:feedstamer/services/analytics_service.dart';

/// Service for handling social features like streaks and social sharing
class SocialService {
  final Logger _logger = Logger();
  
  // Streak tracking
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastActivityDate;
  bool _isStreakBroken = false;
  
  // Achievements
  Map<String, bool> _achievements = {};
  
  // Singleton instance
  static final SocialService _instance = SocialService._internal();
  static SocialService get instance => _instance;
  
  // Private constructor
  SocialService._internal();
  
  /// Initialize the social service
  Future<void> initialize() async {
    try {
      await _loadStreakData();
      await _loadAchievements();
      
      // Configure analytics for social events
      await AnalyticsService.instance.configure(enabled: true);
      
      _logger.i('Social service initialized');
    } catch (e) {
      _logger.e('Error initializing social service: $e');
    }
  }
  
  /// Record daily activity to maintain streak
  Future<bool> recordDailyActivity() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // If this is the first activity
      if (_lastActivityDate == null) {
        _currentStreak = 1;
        _lastActivityDate = today;
        _isStreakBroken = false;
        
        await _saveStreakData();
        await _checkAndUpdateAchievements();
        
        return true;
      }
      
      // Convert lastActivityDate to date-only (no time)
      final lastDate = DateTime(
        _lastActivityDate!.year, 
        _lastActivityDate!.month, 
        _lastActivityDate!.day
      );
      
      // Calculate days difference
      final difference = today.difference(lastDate).inDays;
      
      // Same day, already recorded
      if (difference == 0) {
        return false;
      }
      // Next day, streak continues
      else if (difference == 1) {
        _currentStreak++;
        _isStreakBroken = false;
      }
      // More than one day passed, streak broken
      else {
        _currentStreak = 1;
        _isStreakBroken = true;
      }
      
      // Update longest streak if current is higher
      if (_currentStreak > _longestStreak) {
        _longestStreak = _currentStreak;
      }
      
      // Update last activity date
      _lastActivityDate = today;
      
      // Save updated streak data
      await _saveStreakData();
      
      // Check for streak-related achievements
      await _checkAndUpdateAchievements();
      
      // Track streak in analytics
      await AnalyticsService.instance.trackFeatureUsage('streak_day_$_currentStreak');
      
      return true;
    } catch (e) {
      _logger.e('Error recording daily activity: $e');
      return false;
    }
  }
  
  /// Get current streak information
  Map<String, dynamic> getStreakInfo() {
    return {
      'current_streak': _currentStreak,
      'longest_streak': _longestStreak,
      'last_activity_date': _lastActivityDate?.toIso8601String(),
      'is_streak_broken': _isStreakBroken,
    };
  }
  
  /// Check if user has a specific achievement
  bool hasAchievement(String achievementId) {
    return _achievements[achievementId] == true;
  }
  
  /// Get all achievements with their status
  Map<String, bool> getAllAchievements() {
    return Map.unmodifiable(_achievements);
  }
  
  /// Reset streaks (for testing)
  Future<void> resetStreaks() async {
    _currentStreak = 0;
    _longestStreak = 0;
    _lastActivityDate = null;
    _isStreakBroken = false;
    
    await _saveStreakData();
  }
  
  /// Share activity or achievement (placeholder)
  Future<bool> shareActivity(String type, {Map<String, dynamic>? data}) async {
    try {
      // This would integrate with device sharing APIs
      // For now, just log and track the action
      _logger.i('Shared $type: $data');
      
      // Track sharing in analytics
      await AnalyticsService.instance.trackFeatureUsage('share_$type');
      
      return true;
    } catch (e) {
      _logger.e('Error sharing activity: $e');
      return false;
    }
  }
  
  /// Load streak data from shared preferences
  Future<void> _loadStreakData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _currentStreak = prefs.getInt('streak_current') ?? 0;
      _longestStreak = prefs.getInt('streak_longest') ?? 0;
      
      final lastActivityStr = prefs.getString('streak_last_activity');
      if (lastActivityStr != null) {
        _lastActivityDate = DateTime.parse(lastActivityStr);
      }
      
      _isStreakBroken = prefs.getBool('streak_is_broken') ?? false;
      
      _logger.i('Loaded streak data: current=$_currentStreak, longest=$_longestStreak');
    } catch (e) {
      _logger.e('Error loading streak data: $e');
    }
  }
  
  /// Save streak data to shared preferences
  Future<void> _saveStreakData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('streak_current', _currentStreak);
      await prefs.setInt('streak_longest', _longestStreak);
      
      if (_lastActivityDate != null) {
        await prefs.setString('streak_last_activity', _lastActivityDate!.toIso8601String());
      }
      
      await prefs.setBool('streak_is_broken', _isStreakBroken);
    } catch (e) {
      _logger.e('Error saving streak data: $e');
    }
  }
  
  /// Load achievements from shared preferences
  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final achievementsJson = prefs.getString('achievements');
      if (achievementsJson != null) {
        final Map<String, dynamic> data = json.decode(achievementsJson);
        _achievements = Map<String, bool>.from(data);
      } else {
        // Initialize with default achievements (all false)
        _achievements = {
          'streak_3_days': false,
          'streak_7_days': false,
          'streak_30_days': false,
          'streak_100_days': false,
          'first_share': false,
          'follow_5_accounts': false,
          'follow_10_accounts': false,
        };
        
        await _saveAchievements();
      }
    } catch (e) {
      _logger.e('Error loading achievements: $e');
    }
  }
  
  /// Save achievements to shared preferences
  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('achievements', json.encode(_achievements));
    } catch (e) {
      _logger.e('Error saving achievements: $e');
    }
  }
  
  /// Check and update achievements based on current state
  Future<void> _checkAndUpdateAchievements() async {
    bool achievementsUpdated = false;
    
    // Streak achievements
    if (_currentStreak >= 3 && _achievements['streak_3_days'] != true) {
      _achievements['streak_3_days'] = true;
      achievementsUpdated = true;
    }
    
    if (_currentStreak >= 7 && _achievements['streak_7_days'] != true) {
      _achievements['streak_7_days'] = true;
      achievementsUpdated = true;
    }
    
    if (_currentStreak >= 30 && _achievements['streak_30_days'] != true) {
      _achievements['streak_30_days'] = true;
      achievementsUpdated = true;
    }
    
    if (_currentStreak >= 100 && _achievements['streak_100_days'] != true) {
      _achievements['streak_100_days'] = true;
      achievementsUpdated = true;
    }
    
    if (achievementsUpdated) {
      await _saveAchievements();
      
      // Track achievement unlocks in analytics
      for (final entry in _achievements.entries) {
        if (entry.value) {
          await AnalyticsService.instance.trackFeatureUsage('achievement_${entry.key}');
        }
      }
    }
  }
}