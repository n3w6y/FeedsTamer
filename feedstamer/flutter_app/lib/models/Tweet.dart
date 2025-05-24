import 'package:feedstamer/models/twitter_user.dart';

class Tweet {
  final String id;
  final String text;
  final DateTime createdAt;
  final TwitterUser author;
  final List<String> mediaUrls;
  final int likeCount;
  final int retweetCount;
  final int replyCount;
  final bool isRead;
  
  const Tweet({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.author,
    this.mediaUrls = const [],
    this.likeCount = 0,
    this.retweetCount = 0,
    this.replyCount = 0,
    this.isRead = false,
  });
  
  Tweet markAsRead() {
    return Tweet(
      id: id,
      text: text,
      createdAt: createdAt,
      author: author,
      mediaUrls: mediaUrls,
      likeCount: likeCount,
      retweetCount: retweetCount,
      replyCount: replyCount,
      isRead: true,
    );
  }
  
  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      author: TwitterUser.fromJson(json['author'] ?? {}),
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      likeCount: json['like_count'] ?? 0,
      retweetCount: json['retweet_count'] ?? 0,
      replyCount: json['reply_count'] ?? 0,
      isRead: json['is_read'] ?? false,
    );
  }
}