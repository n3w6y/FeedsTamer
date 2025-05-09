import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String profilePicture;
  final SubscriptionModel subscription;
  final PreferencesModel preferences;
  final DateTime createdAt;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.profilePicture,
    required this.subscription,
    required this.preferences,
    required this.createdAt,
  });
  
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      subscription: SubscriptionModel.fromMap(map['subscription'] ?? {}),
      preferences: PreferencesModel.fromMap(map['preferences'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePicture': profilePicture,
      'subscription': subscription.toMap(),
      'preferences': preferences.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? profilePicture,
    SubscriptionModel? subscription,
    PreferencesModel? preferences,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      subscription: subscription ?? this.subscription,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SubscriptionModel {
  final String type; // 'free', 'premium', 'family', 'enterprise'
  final String status; // 'active', 'cancelled', 'expired'
  final DateTime? startDate;
  final DateTime? endDate;
  
  SubscriptionModel({
    required this.type,
    required this.status,
    this.startDate,
    this.endDate,
  });
  
  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      type: map['type'] ?? 'free',
      status: map['status'] ?? 'active',
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'status': status,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    };
  }
  
  bool get isPremium => type != 'free';
  
  bool get isActive => status == 'active';
}

class PreferencesModel {
  final String theme; // 'light', 'dark', 'system'
  final NotificationsPreferencesModel notifications;
  final FeedsSettingsModel FeedsSettings;
  final SessionLimitsModel sessionLimits;
  
  PreferencesModel({
    required this.theme,
    required this.notifications,
    required this.FeedsSettings,
    required this.sessionLimits,
  });
  
  factory PreferencesModel.fromMap(Map<String, dynamic> map) {
    return PreferencesModel(
      theme: map['theme'] ?? 'system',
      notifications: NotificationsPreferencesModel.fromMap(map['notifications'] ?? {}),
      FeedsSettings: FeedsSettingsModel.fromMap(map['FeedsSettings'] ?? {}),
      sessionLimits: SessionLimitsModel.fromMap(map['sessionLimits'] ?? {}),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'notifications': notifications.toMap(),
      'FeedsSettings': FeedsSettings.toMap(),
      'sessionLimits': sessionLimits.toMap(),
    };
  }
  
  PreferencesModel copyWith({
    String? theme,
    NotificationsPreferencesModel? notifications,
    FeedsSettingsModel? FeedsSettings,
    SessionLimitsModel? sessionLimits,
  }) {
    return PreferencesModel(
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      FeedsSettings: FeedsSettings ?? this.FeedsSettings,
      sessionLimits: sessionLimits ?? this.sessionLimits,
    );
  }
}

class NotificationsPreferencesModel {
  final bool enabled;
  final Map<String, bool> types;
  
  NotificationsPreferencesModel({
    required this.enabled,
    required this.types,
  });
  
  factory NotificationsPreferencesModel.fromMap(Map<String, dynamic> map) {
    final typesMap = map['types'];
    Map<String, bool> typesData = {};
    
    if (typesMap is Map) {
      typesMap.forEach((key, value) {
        if (value is bool) {
          typesData[key] = value;
        }
      });
    }
    
    return NotificationsPreferencesModel(
      enabled: map['enabled'] ?? true,
      types: typesData.isEmpty 
        ? {
            'newContent': true,
            'accountActivity': true,
            'usageReminders': true,
          }
        : typesData,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'types': types,
    };
  }
}

class FeedsSettingsModel {
  final String defaultView; // 'unified', 'platform'
  final String contentOrder; // 'chronological', 'platform'
  final bool showReadPosts;
  
  FeedsSettingsModel({
    required this.defaultView,
    required this.contentOrder,
    required this.showReadPosts,
  });
  
  factory FeedsSettingsModel.fromMap(Map<String, dynamic> map) {
    return FeedsSettingsModel(
      defaultView: map['defaultView'] ?? 'unified',
      contentOrder: map['contentOrder'] ?? 'chronological',
      showReadPosts: map['showReadPosts'] ?? false,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'defaultView': defaultView,
      'contentOrder': contentOrder,
      'showReadPosts': showReadPosts,
    };
  }
}

class SessionLimitsModel {
  final bool enabled;
  final int dailyLimit; // minutes
  final int reminderInterval; // minutes
  
  SessionLimitsModel({
    required this.enabled,
    required this.dailyLimit,
    required this.reminderInterval,
  });
  
  factory SessionLimitsModel.fromMap(Map<String, dynamic> map) {
    return SessionLimitsModel(
      enabled: map['enabled'] ?? false,
      dailyLimit: map['dailyLimit'] ?? 60,
      reminderInterval: map['reminderInterval'] ?? 20,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'dailyLimit': dailyLimit,
      'reminderInterval': reminderInterval,
    };
  }
}