import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitflow/models/social_activity.dart';
import 'package:fitflow/providers/user_provider.dart';
import 'package:fitflow/services/social_activity_service.dart';
import 'package:fitflow/widgets/activity_card.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fitflow/screens/social/user_search_screen.dart';
import 'package:fitflow/screens/social/friend_requests_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final SocialActivityService _activityService = SocialActivityService();
  List<SocialActivity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      final activities = await _activityService.getFeed(userProvider.user!.uid);

      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserSearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FriendRequestsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeed,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _activities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your feed is empty',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Follow friends to see their activities',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: const Text('Find Friends'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserSearchScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      itemCount: _activities.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: ActivityCard(
                                activity: _activities[index],
                                onLike: () {
                                  final userId = Provider.of<UserProvider>(
                                          context,
                                          listen: false)
                                      .user!
                                      .uid;
                                  final activity = _activities[index];

                                  if (activity.likedByUsers.contains(userId)) {
                                    _activityService.unlikeActivity(
                                        activity.id, userId);
                                    setState(() {
                                      _activities[index]
                                          .likedByUsers
                                          .remove(userId);
                                    });
                                  } else {
                                    _activityService.likeActivity(
                                        activity.id, userId);
                                    setState(() {
                                      _activities[index]
                                          .likedByUsers
                                          .add(userId);
                                    });
                                  }
                                },
                                onComment: (String text) async {
                                  final user = Provider.of<UserProvider>(
                                          context,
                                          listen: false)
                                      .user!;
                                  await _activityService.commentOnActivity(
                                    _activities[index].id,
                                    ActivityComment(
                                      userId: user.uid,
                                      userName: user.name ?? 'User',
                                      userPhotoUrl:
                                          '', // We don't have this field yet
                                      text: text,
                                      createdAt: DateTime.now(),
                                    ),
                                  );
                                  _loadFeed(); // Refresh to show new comment
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
