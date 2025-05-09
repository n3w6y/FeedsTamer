import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {
  final String id;
  final String userId;
  final String platform;
  final String accountId;
  final String username;
  final String displayName;
  final String profilePicture;
  final String description;
  final String? category;
  final List<String> categories;
  final List<String> tags;
  final int? followerCount;
  final int? followingCount;
  final int? postCount;
  final bool isVerified;
  final DateTime lastUpdated;
  final bool isActive;
  final bool pinned;
  final int? pinnedOrder;
  final AccountNotificationSettings notificationSettings;
  final AccountStats? stats;
  final DateTime createdAt;
  
  AccountModel({
    required this.id,
    required this.userId,
    required this.platform,
    required this.accountId,
    required this.username,
    required this.displayName,
    required this.profilePicture,
    required this.description,
    this.category,
    required this.categories,
    required this.tags,
    this.followerCount,
    this.followingCount,
    this.postCount,
    required this.isVerified,
    required this.lastUpdated,
    required this.isActive,
    required this.pinned,
    this.pinnedOrder,
    required this.notificationSettings,
    this.stats,
    required this.createdAt,
  });
  
  factory AccountModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return AccountModel(
      id: id,
      userId: map['userId'] ?? '',
      platform: map['platform'] ?? '',
      accountId: map['accountId'] ?? '',
      username: map['username'] ?? '',
      displayName: map['displayName'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      description: map['description'] ?? '',
      category: map['category'],
      categories: List<String>.from(map['categories'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      followerCount: map['followerCount'],
      followingCount: map['followingCount'],
      postCount: map['postCount'],
      isVerified: map['isVerified'] ?? false,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      pinned: map['pinned'] ?? false,
      pinnedOrder: map['pinnedOrder'],
      notificationSettings: AccountNotificationSettings.fromMap(
        map['notificationSettings'] ?? {},
      ),
      stats: map['stats'] != null ? AccountStats.fromMap(map['stats']) : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'platform': platform,
      'accountId': accountId,
      'username': username,
      'displayName': displayName,
      'profilePicture': profilePicture,
      'description': description,
      'category': category,
      'categories': categories,
      'tags': tags,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'postCount': postCount,
      'isVerified': isVerified,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isActive': isActive,
      'pinned': pinned,
      'pinnedOrder': pinnedOrder,
      'notificationSettings': notificationSettings.toMap(),
      'stats': stats?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  AccountModel copyWith({
    String? id,
    String? userId,
    String? platform,
    String? accountId,
    String? username,
    String? displayName,
    String? profilePicture,
    String? description,
    String? category,
    List<String>? categories,
    List<String>? tags,
    int? followerCount,
    int? followingCount,
    int? postCount,
    bool? isVerified,
    DateTime? lastUpdated,
    bool? isActive,
    bool? pinned,
    int? pinnedOrder,
    AccountNotificationSettings? notificationSettings,
    AccountStats? stats,
    DateTime? createdAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      platform: platform ?? this.platform,
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profilePicture: profilePicture ?? this.profilePicture,
      description: description ?? this.description,
      category: category ?? this.category,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      postCount: postCount ?? this.postCount,
      isVerified: isVerified ?? this.isVerified,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      pinned: pinned ?? this.pinned,
      pinnedOrder: pinnedOrder ?? this.pinnedOrder,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // Platform-specific icon
  String get platformIcon {
    switch (platform) {
      case 'twitter':
        return 'assets/icons/twitter.png';
      case 'instagram':
        return 'assets/icons/instagram.png';
      case 'youtube':
        return 'assets/icons/youtube.png';
      case 'reddit':
        return 'assets/icons/reddit.png';
      case 'linkedin':
        return 'assets/icons/linkedin.png';
      default:
        return 'assets/icons/link.png';
    }
  }
  
  // Platform name formatted
  String get platformName {
    switch (platform) {
      case 'twitter':
        return 'Twitter';
      case 'instagram':
        return 'Instagram';
      case 'youtube':
        return 'YouTube';
      case 'reddit':
        return 'Reddit';
      case 'linkedin':
        return 'LinkedIn';
      default:
        return platform.substring(0, 1).toUpperCase() + platform.substring(1);
    }
  }
}

class AccountNotificationSettings {
  final bool enabled;
  final String frequency; // all, daily, none
  
  AccountNotificationSettings({
    required this.enabled,
    required this.frequency,
  });
  
  factory AccountNotificationSettings.fromMap(Map<String, dynamic> map) {
    return AccountNotificationSettings(
      enabled: map['enabled'] ?? true,
      frequency: map['frequency'] ?? 'all',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'frequency': frequency,
    };
  }
}

class AccountStats {
  final double? averagePostsPerWeek;
  final double? averageEngagementRate;
  final double? readPercentage;
  final DateTime? lastInteraction;
  
  AccountStats({
    this.averagePostsPerWeek,
    this.averageEngagementRate,
    this.readPercentage,
    this.lastInteraction,
  });
  
  factory AccountStats.fromMap(Map<String, dynamic> map) {
    return AccountStats(
      averagePostsPerWeek: map['averagePostsPerWeek'],
      averageEngagementRate: map['averageEngagementRate'],
      readPercentage: map['readPercentage'],
      lastInteraction: (map['lastInteraction'] as Timestamp?)?.toDate(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'averagePostsPerWeek': averagePostsPerWeek,
      'averageEngagementRate': averageEngagementRate,
      'readPercentage': readPercentage,
      'lastInteraction': lastInteraction != null ? Timestamp.fromDate(lastInteraction!) : null,
    };
  }
}