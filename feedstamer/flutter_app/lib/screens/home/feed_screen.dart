import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Feedstamer/models/account_model.dart';
import 'package:Feedstamer/models/content_model.dart';
import 'package:Feedstamer/services/analytics_service.dart';
import 'package:Feedstamer/services/content_service.dart';
import 'package:Feedstamer/widgets/content_card.dart';
import 'package:Feedstamer/widgets/platform_filter.dart';
import 'package:Feedstamer/widgets/pomodoro_timer.dart';
import 'package:Feedstamer/widgets/empty_state.dart';
import 'package:Feedstamer/widgets/loading_indicator.dart';

final selectedPlatformProvider = StateProvider<String?>((ref) => null);
final FeedsViewProvider = StateProvider<String>((ref) => 'unified');

final FeedsContentProvider = StreamProvider<List<ContentModel>>((ref) {
  final selectedPlatform = ref.watch(selectedPlatformProvider);
  final FeedsView = ref.watch(FeedsViewProvider);
  
  return ContentService().getContentFeeds(
    platform: selectedPlatform,
    view: FeedsView,
  );
});

class FeedsScreen extends ConsumerStatefulWidget {
  const FeedsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends ConsumerState<FeedsScreen> {
  bool _showPomodoroTimer = false;
  
  @override
  void initState() {
    super.initState();
    AnalyticsService().logScreenView('FeedsScreen');
  }
  
  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(FeedsContentProvider);
    final selectedPlatform = ref.watch(selectedPlatformProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Feeds'),
        actions: [
          IconButton(
            icon: Icon(
              _showPomodoroTimer ? Icons.timer : Icons.timer_outlined,
              color: _showPomodoroTimer 
                ? Theme.of(context).colorScheme.primary 
                : null,
            ),
            tooltip: 'Focus Timer',
            onPressed: () {
              setState(() {
                _showPomodoroTimer = !_showPomodoroTimer;
              });
              
              AnalyticsService().logEvent(
                'pomodoro_timer_toggled',
                parameters: {'visible': _showPomodoroTimer},
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Pomodoro timer (collapsible)
          if (_showPomodoroTimer)
            const PomodoroTimer(),
            
          // Platform filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: PlatformFilter(
              selectedPlatform: selectedPlatform,
              onPlatformSelected: (platform) {
                ref.read(selectedPlatformProvider.notifier).state = platform;
                
                AnalyticsService().logEvent(
                  'platform_filter_changed',
                  parameters: {'platform': platform ?? 'all'},
                );
              },
            ),
          ),
          
          // Main content
          Expanded(
            child: contentAsync.when(
              data: (contentList) {
                if (contentList.isEmpty) {
                  return EmptyState(
                    icon: Icons.Feeds_outlined,
                    title: 'No content yet',
                    message: selectedPlatform == null
                        ? 'Follow some accounts to see content here'
                        : 'No content from $selectedPlatform accounts',
                    actionLabel: 'Find Accounts',
                    onAction: () {
                      // Navigate to accounts screen
                      ref.read(selectedTabProvider.notifier).state = 1;
                    },
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    // Force refresh content
                    ref.refresh(FeedsContentProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: contentList.length,
                    itemBuilder: (context, index) {
                      final content = contentList[index];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ContentCard(
                          content: content,
                          onContentViewed: (contentId) {
                            // Mark content as seen
                            ContentService().markContentAsSeen(contentId);
                          },
                          onContentSaved: (contentId, isSaved) {
                            // Toggle save status
                            ContentService().toggleSaveContent(contentId, isSaved);
                            
                            AnalyticsService().logEvent(
                              isSaved ? 'content_saved' : 'content_unsaved',
                              parameters: {'content_id': contentId},
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error loading content: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}