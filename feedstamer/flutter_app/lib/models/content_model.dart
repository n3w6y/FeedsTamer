import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Feedstamer/models/account_model.dart';

class ContentModel {
  final String id;
  final String accountId;
  final AccountModel? account;
  final String platform;
  final String contentId;
  final String contentType; // post, tweet, photo, video, story, article, comment
  final String? text;
  final List<String> mediaUrls;
  final String? mediaType; // image, video, gif, audio, link, none
  final String? link;
  final DateTime publishedAt;
  final DateTime retrievedAt;
  final ContentEngagementStats? engagementStats;
  final List<ContentUserInteraction> userInteractions;
  final Map<String, dynamic>? rawData;
  
  ContentModel({
    required this.id,
    required this.accountId,
    this.account,
    required this.platform,
    required this.contentId,
    required this.contentType,
    this.text,
    required this.mediaUrls,
    this.mediaType,
    this.link,
    required this.publishedAt,
    required this.retrievedAt,
    this.engagementStats,
    required this.userInteractions,
    this.rawData,
  });
  
  factory ContentModel.fromMap(Map<String, dynamic> map, {required String id, AccountModel? account}) {
    List<ContentUserInteraction> interactions = [];
    
    if (map['userInteractions'] != null) {
      interactions = (map['userInteractions'] as List)
        .map((item) => ContentUserInteraction.fromMap(item))
        .toList();
    }
    
    return ContentModel(
      id: id,
      accountId: map['accountId'] ?? '',
      account: account,
      platform: map['platform'] ?? '',
      contentId: map['contentId'] ?? '',
      contentType: map['contentType'] ?? '',
      text: map['text'],
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      mediaType: map['mediaType'],
      link: map['link'],
      publishedAt: (map['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      retrievedAt: (map['retrievedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      engagementStats: map['engagementStats'] != null 
        ? ContentEngagementStats.fromMap(map['engagementStats']) 
        : null,
      userInteractions: interactions,
      rawData: map['rawData'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'platform': platform,
      'contentId': contentId,
      'contentType': contentType,
      'text': text,
      'mediaUrls': mediaUrls,
      'mediaType': mediaType,
      'link': link,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'retrievedAt': Timestamp.fromDate(retrievedAt),
      'engagementStats': engagementStats?.toMap(),
      'userInteractions': userInteractions.map((item) => item.toMap()).toList(),
      'rawData': rawData,
    };
  }
  
  ContentModel copyWith({
    String? id,
    String? accountId,
    AccountModel? account,
    String? platform,
    String? contentId,
    String? contentType,
    String? text,
    List<String>? mediaUrls,
    String? mediaType,
    String? link,
    DateTime? publishedAt,
    DateTime? retrievedAt,
    ContentEngagementStats? engagementStats,
    List<ContentUserInteraction>? userInteractions,
    Map<String, dynamic>? rawData,
  }) {
    return ContentModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      account: account ?? this.account,
      platform: platform ?? this.platform,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      text: text ?? this.text,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaType: mediaType ?? this.mediaType,
      link: link ?? this.link,
      publishedAt: publishedAt ?? this.publishedAt,
      retrievedAt: retrievedAt ?? this.retrievedAt,
      engagementStats: engagementStats ?? this.engagementStats,
      userInteractions: userInteractions ?? this.userInteractions,
      rawData: rawData ?? this.rawData,
    );
  }
  
  // Helper methods
  bool isSeenByUser(String userId) {
    final interaction = userInteractions.firstWhere(
      (item) => item.userId == userId,
      orElse: () => ContentUserInteraction(userId: userId),
    );
    return interaction.seen;
  }
  
  bool isSavedByUser(String userId) {
    final interaction = userInteractions.firstWhere(
      (item) => item.userId == userId,
      orElse: () => ContentUserInteraction(userId: userId),
    );
    return interaction.saved;
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
  
  // For displaying timeframe
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}

class ContentEngagementStats {
  final int? likes;
  final int? comments;
  final int? shares;
  final int? views;
  
  ContentEngagementStats({
    this.likes,
    this.comments,
    this.shares,
    this.views,
  });
  
  factory ContentEngagementStats.fromMap(Map<String, dynamic> map) {
    return ContentEngagementStats(
      likes: map['likes'],
      comments: map['comments'],
      shares: map['shares'],
      views: map['views'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
    };
  }
}

class ContentUserInteraction {
  final String userId;
  final bool seen;
  final DateTime? seenAt;
  final bool saved;
  final DateTime? savedAt;
  final Map<String, bool>? interaction;
  
  ContentUserInteraction({
    required this.userId,
    this.seen = false,
    this.seenAt,
    this.saved = false,
    this.savedAt,
    this.interaction,
  });
  
  factory ContentUserInteraction.fromMap(Map<String, dynamic> map) {
    return ContentUserInteraction(
      userId: map['userId'] ?? '',
      seen: map['seen'] ?? false,
      seenAt: (map['seenAt'] as Timestamp?)?.toDate(),
      saved: map['saved'] ?? false,
      savedAt: (map['savedAt'] as Timestamp?)?.toDate(),
      interaction: map['interaction'] != null
        ? Map<String, bool>.from(map['interaction'])
        : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'seen': seen,
      'seenAt': seenAt != null ? Timestamp.fromDate(seenAt!) : null,
      'saved': saved,
      'savedAt': savedAt != null ? Timestamp.fromDate(savedAt!) : null,
      'interaction': interaction,
    };
  }
}