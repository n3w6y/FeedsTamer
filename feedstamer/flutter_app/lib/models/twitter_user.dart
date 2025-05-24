class TwitterUser {
  final String id;
  final String username;
  final String displayName;
  final String? profileImageUrl;
  final String? bio;
  
  const TwitterUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.profileImageUrl,
    this.bio,
  });
  
  factory TwitterUser.fromJson(Map<String, dynamic> json) {
    return TwitterUser(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['display_name'] ?? json['name'] ?? '',
      profileImageUrl: json['profile_image_url'],
      bio: json['bio'],
    );
  }
}