// lib/models/subscription_tier.dart
import 'package:flutter/foundation.dart';

/// Represents different subscription tiers in the app
@immutable
class SubscriptionTier {
  /// The unique identifier for the subscription tier
  final String id;
  
  /// The display name of the subscription tier
  final String name;
  
  /// The monthly price in USD
  final double monthlyPrice;
  
  /// The annual price in USD (if available)
  final double? annualPrice;
  
  /// Maximum number of accounts that can be followed
  final int maxAccounts;
  
  /// A description of the tier features
  final String description;
  
  /// Whether advanced analytics are available
  final bool hasAdvancedAnalytics;
  
  /// Whether the tier has ad-free experience
  final bool isAdFree;
  
  /// Whether the tier allows unlimited feeds
  final bool hasUnlimitedFeeds;
  
  /// Constructs a SubscriptionTier
  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    this.annualPrice,
    required this.maxAccounts,
    required this.description,
    this.hasAdvancedAnalytics = false,
    this.isAdFree = false,
    this.hasUnlimitedFeeds = false,
  });
  
  /// Free tier
  static const SubscriptionTier free = SubscriptionTier(
    id: 'free',
    name: 'Free',
    monthlyPrice: 0.0,
    maxAccounts: 3,
    description: 'Follow up to 3 accounts across platforms',
    hasAdvancedAnalytics: false,
    isAdFree: false,
    hasUnlimitedFeeds: false,
  );
  
  /// Premium tier
  static const SubscriptionTier premium = SubscriptionTier(
    id: 'premium',
    name: 'Premium',
    monthlyPrice: 6.99,
    annualPrice: 69.99,
    maxAccounts: 10,
    description: 'Follow up to 10 accounts with advanced features',
    hasAdvancedAnalytics: true,
    isAdFree: true,
    hasUnlimitedFeeds: false,
  );
  
  /// Business tier
  static const SubscriptionTier business = SubscriptionTier(
    id: 'business',
    name: 'Business',
    monthlyPrice: 14.99,
    annualPrice: 149.99,
    maxAccounts: 100,
    description: 'Follow up to 100 accounts with all premium features',
    hasAdvancedAnalytics: true,
    isAdFree: true,
    hasUnlimitedFeeds: true,
  );
  
  /// All available tiers
  static const List<SubscriptionTier> allTiers = [free, premium, business];
  
  /// Factory constructor from JSON
  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    return SubscriptionTier(
      id: json['id'] as String,
      name: json['name'] as String,
      monthlyPrice: json['monthly_price'] as double,
      annualPrice: json['annual_price'] as double?,
      maxAccounts: json['max_accounts'] as int,
      description: json['description'] as String,
      hasAdvancedAnalytics: json['has_advanced_analytics'] as bool? ?? false,
      isAdFree: json['is_ad_free'] as bool? ?? false,
      hasUnlimitedFeeds: json['has_unlimited_feeds'] as bool? ?? false,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'monthly_price': monthlyPrice,
      if (annualPrice != null) 'annual_price': annualPrice,
      'max_accounts': maxAccounts,
      'description': description,
      'has_advanced_analytics': hasAdvancedAnalytics,
      'is_ad_free': isAdFree,
      'has_unlimited_feeds': hasUnlimitedFeeds,
    };
  }
  
  /// Get a tier by ID
  static SubscriptionTier? getById(String id) {
    try {
      return allTiers.firstWhere((tier) => tier.id == id);
    } catch (e) {
      return null;
    }
  }
}