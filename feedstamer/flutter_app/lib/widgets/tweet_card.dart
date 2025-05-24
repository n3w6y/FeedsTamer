import 'package:flutter/material.dart';
import 'package:feedstamer/models/tweet.dart';
import 'package:intl/intl.dart';

class TweetCard extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback? onTap;
  
  const TweetCard({
    super.key,
    required this.tweet,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd().add_jm();
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: tweet.isRead 
          ? theme.colorScheme.surface 
          : theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: tweet.author.profileImageUrl != null
                        ? NetworkImage(tweet.author.profileImageUrl!)
                        : null,
                    child: tweet.author.profileImageUrl == null
                        ? Text(tweet.author.displayName[0])
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tweet.author.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${tweet.author.username}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    dateFormat.format(tweet.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Tweet text
              Text(tweet.text),
              
              // Media if available
              if (tweet.mediaUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    tweet.mediaUrls.first,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              
              // Engagement stats
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildEngagementButton(
                    context,
                    Icons.chat_bubble_outline,
                    tweet.replyCount,
                    () {},
                  ),
                  _buildEngagementButton(
                    context,
                    Icons.repeat,
                    tweet.retweetCount,
                    () {},
                  ),
                  _buildEngagementButton(
                    context,
                    Icons.favorite_border,
                    tweet.likeCount,
                    () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEngagementButton(
    BuildContext context,
    IconData icon,
    int count,
    VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(count > 0 ? count.toString() : ''),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}