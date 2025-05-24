import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountStatus { active, deactivated, suspended }

class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final AccountStatus status;
  final int streakCount;
  final DateTime? lastActiveDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> preferences;
  final List<String> followedAccounts;
  final String? subscriptionTier;
  final DateTime? subscriptionExpiry;

  UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.status = AccountStatus.active,
    this.streakCount = 0,
    this.lastActiveDate,
    required this.createdAt,
    required this.updatedAt,
    this.preferences = const {},
    this.followedAccounts = const [],
    this.subscriptionTier,
    this.subscriptionExpiry,
  });

  // Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserProfile(
      uid: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      photoUrl: data['photoURL'],
      emailVerified: data['emailVerified'] ?? false,
      status: _parseStatus(data['status']),
      streakCount: data['streakCount'] ?? 0,
      lastActiveDate: data['lastActiveDate'] != null 
          ? (data['lastActiveDate'] as Timestamp).toDate() 
          : null,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      preferences: data['preferences'] ?? {},
      followedAccounts: data['followedAccounts'] != null 
          ? List<String>.from(data['followedAccounts']) 
          : [],
      subscriptionTier: data['subscriptionTier'],
      subscriptionExpiry: data['subscriptionExpiry'] != null 
          ? (data['subscriptionExpiry'] as Timestamp).toDate() 
          : null,
    );
  }

  // Create from Firebase user
  factory UserProfile.fromFirebaseUser(Map<String, dynamic> userData, String uid) {
    final now = DateTime.now();
    
    return UserProfile(
      uid: uid,
      email: userData['email'],
      displayName: userData['displayName'],
      photoUrl: userData['photoURL'],
      emailVerified: userData['emailVerified'] ?? false,
      createdAt: now,
      updatedAt: now,
      lastActiveDate: now,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoUrl,
      'emailVerified': emailVerified,
      'status': status.toString().split('.').last,
      'streakCount': streakCount,
      'lastActiveDate': lastActiveDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'preferences': preferences,
      'followedAccounts': followedAccounts,
      'subscriptionTier': subscriptionTier,
      'subscriptionExpiry': subscriptionExpiry,
    };
  }

  // Create copy with new values
  UserProfile copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    AccountStatus? status,
    int? streakCount,
    DateTime? lastActiveDate,
    Map<String, dynamic>? preferences,
    List<String>? followedAccounts,
    String? subscriptionTier,
    DateTime? subscriptionExpiry,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      status: status ?? this.status,
      streakCount: streakCount ?? this.streakCount,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      preferences: preferences ?? this.preferences,
      followedAccounts: followedAccounts ?? this.followedAccounts,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
    );
  }

  // Update streak based on current date
  UserProfile updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // First login ever
    if (lastActiveDate == null) {
      return copyWith(
        streakCount: 1,
        lastActiveDate: now,
      );
    }
    
    final lastActive = DateTime(
      lastActiveDate!.year,
      lastActiveDate!.month,
      lastActiveDate!.day,
    );
    
    // Calculate difference in days
    final difference = today.difference(lastActive).inDays;
    
    // Same day - no change
    if (difference == 0) {
      return this;
    }
    
    // Yesterday - increase streak
    if (difference == 1) {
      return copyWith(
        streakCount: streakCount + 1,
        lastActiveDate: now,
      );
    }
    
    // More than one day - reset streak
    return copyWith(
      streakCount: 1,
      lastActiveDate: now,
    );
  }

  // Helper to parse status from string
  static AccountStatus _parseStatus(String? status) {
    if (status == null) return AccountStatus.active;
    
    switch (status.toLowerCase()) {
      case 'deactivated':
        return AccountStatus.deactivated;
      case 'suspended':
        return AccountStatus.suspended;
      default:
        return AccountStatus.active;
    }
  }
}