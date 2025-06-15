import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitflow/models/social_activity.dart';
import 'package:fitflow/models/social_connection.dart';
import 'package:fitflow/models/user_model.dart';
import 'package:fitflow/providers/user_provider.dart';
import 'package:fitflow/services/social_activity_service.dart';
import 'package:fitflow/services/social_service.dart';
import 'package:fitflow/widgets/activity_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final SocialService _socialService = SocialService();
  final SocialActivityService _activityService = SocialActivityService();

  User? _user;
  List<SocialActivity> _activities = [];
  SocialConnection? _connection;
  bool _isLoading = true;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    // Get user profile
    final user = await _socialService.getUserById(widget.userId);

    if (mounted) {
      setState(() {
        _user = user;
      });
    }

    if (user != null) {
      // Get user activities
      final activities =
          await _activityService.getUserActivities(widget.userId);

      // Check if current user is connected to this user
      final currentUserId =
          Provider.of<UserProvider>(context, listen: false).user!.uid;
      final connections =
          await _socialService.getUserConnections(currentUserId);
      final connection = connections
          .where((c) => c.connectedUserId == widget.userId)
          .firstOrNull;

      if (mounted) {
        setState(() {
          _activities = activities;
          _connection = connection;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendConnectionRequest() async {
    final currentUserId =
        Provider.of<UserProvider>(context, listen: false).user!.uid;

    setState(() {
      _isConnecting = true;
    });

    await _socialService.sendConnectionRequest(
      currentUserId,
      widget.userId,
      ConnectionType.friend,
    );

    // Refresh connection status
    final connections = await _socialService.getUserConnections(currentUserId);
    final connection = connections
        .where((c) => c.connectedUserId == widget.userId)
        .firstOrNull;

    setState(() {
      _connection = connection;
      _isConnecting = false;
    });
  }

  Future<void> _removeConnection() async {
    if (_connection == null) return;

    setState(() {
      _isConnecting = true;
    });

    await _socialService.removeConnection(_connection!.id);

    setState(() {
      _connection = null;
      _isConnecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'User not found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(_user!.name ?? 'User'),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  child: Text(
                                    _user!.name?.isNotEmpty == true
                                        ? _user!.name![0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _user!.name ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_user!.fitnessGoal != null)
                                  Text(
                                    _user!.fitnessGoal!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildConnectionButton(),
                            const SizedBox(height: 24),
                            Text(
                              'Activities',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    _activities.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.hourglass_empty,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No activities yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return ActivityCard(
                                    activity: _activities[index],
                                    onLike: () {
                                      final userId = Provider.of<UserProvider>(
                                              context,
                                              listen: false)
                                          .user!
                                          .uid;
                                      final activity = _activities[index];

                                      if (activity.likedByUsers
                                          .contains(userId)) {
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
                                          userPhotoUrl: '',
                                          text: text,
                                          createdAt: DateTime.now(),
                                        ),
                                      );
                                      _loadUserData(); // Refresh to show new comment
                                    },
                                  ).animate().fadeIn(
                                      duration: 300.ms, delay: (50 * index).ms);
                                },
                                childCount: _activities.length,
                              ),
                            ),
                          ),
                  ],
                ),
    );
  }

  Widget _buildConnectionButton() {
    final currentUserId = Provider.of<UserProvider>(context).user!.uid;

    // Don't show connection button for own profile
    if (widget.userId == currentUserId) {
      return const SizedBox.shrink();
    }

    if (_isConnecting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Already connected
    if (_connection != null) {
      return Center(
        child: OutlinedButton.icon(
          icon: const Icon(Icons.person_remove),
          label: const Text('Remove Friend'),
          onPressed: _removeConnection,
        ),
      );
    }

    // Not connected yet
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.person_add),
        label: const Text('Add Friend'),
        onPressed: _sendConnectionRequest,
      ),
    );
  }
}
