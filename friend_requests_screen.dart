import 'package:flutter/material.dart';
import 'package:fitflow/models/social_connection.dart';
import 'package:fitflow/models/user_model.dart';
import 'package:fitflow/providers/user_provider.dart';
import 'package:fitflow/services/social_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fitflow/screens/social/user_profile_screen.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final SocialService _socialService = SocialService();
  List<_PendingRequest> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() {
      _isLoading = true;
    });

    final userId = Provider.of<UserProvider>(context, listen: false).user!.uid;
    final requests = await _socialService.getPendingRequests(userId);

    // Get user details for each request
    List<_PendingRequest> pendingRequests = [];
    for (var request in requests) {
      final user = await _socialService.getUserById(request.userId);
      if (user != null) {
        pendingRequests.add(_PendingRequest(
          connection: request,
          user: user,
        ));
      }
    }

    setState(() {
      _pendingRequests = pendingRequests;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No pending requests',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _pendingRequests.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final request = _pendingRequests[index];
                    return FriendRequestCard(
                      request: request,
                      onAccept: () async {
                        await _socialService
                            .acceptConnectionRequest(request.connection.id);
                        _loadPendingRequests();
                      },
                      onReject: () async {
                        await _socialService
                            .rejectConnectionRequest(request.connection.id);
                        _loadPendingRequests();
                      },
                      onProfileTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileScreen(userId: request.user.uid),
                          ),
                        );
                      },
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                        .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 300.ms,
                            delay: (50 * index).ms);
                  },
                ),
    );
  }
}

class _PendingRequest {
  final SocialConnection connection;
  final User user;

  _PendingRequest({
    required this.connection,
    required this.user,
  });
}

class FriendRequestCard extends StatelessWidget {
  final _PendingRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onProfileTap;

  const FriendRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onProfileTap,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      request.user.name?.isNotEmpty == true
                          ? request.user.name![0]
                          : '?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.user.name ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          request.user.email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Wants to connect with you',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
