// lib/services/subscription_service.dart
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:convert';
import 'package:feedstamer/models/subscription_tier.dart';

/// Service for managing subscription tiers and in-app purchases
class SubscriptionService {
  final Logger _logger = Logger();
  
  // Current subscription tier
  SubscriptionTier _currentTier = SubscriptionTier.free;
  
  // Subscription expiration
  DateTime? _expirationDate;
  
  // Singleton instance
  static final SubscriptionService _instance = SubscriptionService._internal();
  static SubscriptionService get instance => _instance;
  
  // Private constructor
  SubscriptionService._internal();
  
  /// Initialize the subscription service
  Future<void> initialize() async {
    try {
      await _loadSubscriptionData();
      _logger.i('Subscription service initialized with tier: ${_currentTier.name}');
    } catch (e) {
      _logger.e('Error initializing subscription service: $e');
    }
  }
  
  /// Get the current subscription tier
  SubscriptionTier get currentTier => _currentTier;
  
  /// Check if the user has an active premium subscription
  bool get isPremium => _currentTier.id != SubscriptionTier.free.id && !isSubscriptionExpired();
  
  /// Check if the user has an active business subscription
  bool get isBusiness => _currentTier.id == SubscriptionTier.business.id && !isSubscriptionExpired();
  
  /// Get the subscription expiration date
  DateTime? get expirationDate => _expirationDate;
  
  /// Check if the subscription has expired
  bool isSubscriptionExpired() {
    if (_expirationDate == null) {
      return _currentTier.id != SubscriptionTier.free.id;
    }
    return DateTime.now().isAfter(_expirationDate!);
  }
  
  /// Get available subscription tiers
  List<SubscriptionTier> getAvailableTiers() {
    return SubscriptionTier.allTiers;
  }
  
  /// Update subscription tier (would connect to in-app purchase in real app)
  Future<bool> updateSubscriptionTier(String tierId, {int durationMonths = 1}) async {
    try {
      final tier = SubscriptionTier.getById(tierId);
      if (tier == null) {
        _logger.e('Invalid subscription tier ID: $tierId');
        return false;
      }
      
      _currentTier = tier;
      
      // Set expiration date if not free tier
      if (tier.id != SubscriptionTier.free.id) {
        final now = DateTime.now();
        _expirationDate = DateTime(
          now.year, 
          now.month + durationMonths, 
          now.day,
          now.hour,
          now.minute,
          now.second
        );
      } else {
        _expirationDate = null;
      }
      
      await _saveSubscriptionData();
      _logger.i('Subscription updated to ${tier.name}, expires: $_expirationDate');
      
      return true;
    } catch (e) {
      _logger.e('Error updating subscription tier: $e');
      return false;
    }
  }
  
  /// Restore purchases (would connect to in-app purchase in real app)
  Future<bool> restorePurchases() async {
    try {
      // This would integrate with platform-specific IAP restore
      _logger.i('Restoring purchases...');
      
      // For demo, just load from storage
      await _loadSubscriptionData();
      
      return true;
    } catch (e) {
      _logger.e('Error restoring purchases: $e');
      return false;
    }
  }
  
  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    try {
      // This would integrate with platform-specific IAP cancellation
      _logger.i('Cancelling subscription...');
      
      // Keep premium until expiration date
      // Don't change current tier or expiration date, just log the cancellation
      _logger.i('Subscription cancelled, premium until: $_expirationDate');
      
      return true;
    } catch (e) {
      _logger.e('Error cancelling subscription: $e');
      return false;
    }
  }
  
  /// Check if a feature is available with current subscription
  bool isFeatureAvailable(String featureId) {
    switch (featureId) {
      case 'unlimited_accounts':
        return isBusiness;
        
      case 'advanced_analytics':
        return isPremium;
        
      case 'ad_free':
        return isPremium;
        
      case 'custom_themes':
        return isPremium;
        
      case 'data_export':
        return isPremium;
        
      default:
        return true; // Free features available to all
    }
  }
  
  /// Get the maximum number of accounts allowed with current subscription
  int getMaxAccounts() {
    if (isSubscriptionExpired()) {
      return SubscriptionTier.free.maxAccounts;
    }
    return _currentTier.maxAccounts;
  }
  
  /// Get subscription info as a map
  Map<String, dynamic> getSubscriptionInfo() {
    return {
      'tier_id': _currentTier.id,
      'tier_name': _currentTier.name,
      'is_premium': isPremium,
      'is_business': isBusiness,
      'expiration_date': _expirationDate?.toIso8601String(),
      'is_expired': isSubscriptionExpired(),
      'max_accounts': getMaxAccounts(),
    };
  }
  
  /// Set a test subscription (for development only)
  Future<void> setTestSubscription(String tierId, {int durationDays = 30}) async {
    final tier = SubscriptionTier.getById(tierId);
    if (tier != null) {
      _currentTier = tier;
      
      if (tier.id != SubscriptionTier.free.id) {
        final now = DateTime.now();
        _expirationDate = now.add(Duration(days: durationDays));
      } else {
        _expirationDate = null;
      }
      
      await _saveSubscriptionData();
      _logger.i('Test subscription set to ${tier.name}, expires: $_expirationDate');
    }
  }
  
  /// Reset subscription to free tier (for development only)
  Future<void> resetSubscription() async {
    _currentTier = SubscriptionTier.free;
    _expirationDate = null;
    
    await _saveSubscriptionData();
    _logger.i('Subscription reset to free tier');
  }
  
  /// Load subscription data from shared preferences
  Future<void> _loadSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final tierId = prefs.getString('subscription_tier_id');
      if (tierId != null) {
        final tier = SubscriptionTier.getById(tierId);
        if (tier != null) {
          _currentTier = tier;
        }
      }
      
      final expirationStr = prefs.getString('subscription_expiration');
      if (expirationStr != null) {
        _expirationDate = DateTime.parse(expirationStr);
      }
      
      // Check if expired and reset to free if needed
      if (isSubscriptionExpired()) {
        _logger.i('Subscription expired, resetting to free tier');
        _currentTier = SubscriptionTier.free;
        _expirationDate = null;
        await _saveSubscriptionData();
      }
    } catch (e) {
      _logger.e('Error loading subscription data: $e');
    }
  }
  
  /// Save subscription data to shared preferences
  Future<void> _saveSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('subscription_tier_id', _currentTier.id);
      
      if (_expirationDate != null) {
        await prefs.setString('subscription_expiration', _expirationDate!.toIso8601String());
      } else {
        await prefs.remove('subscription_expiration');
      }
    } catch (e) {
      _logger.e('Error saving subscription data: $e');
    }
  }
}