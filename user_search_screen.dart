import 'package:flutter/material.dart';
import 'package:fitflow/models/user_model.dart';
import 'package:fitflow/providers/user_provider.dart';
import 'package:fitflow/services/social_service.dart';
import 'package:provider/provider.dart';
import 'package:fitflow/screens/social/user_profile_screen.dart';
import 'package:fitflow/models/social_connection.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final SocialService _socialService = SocialService();
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final currentUserId =
        Provider.of<UserProvider>(context, listen: false).user!.uid;
    final results = await _socialService.searchUsers(query, currentUserId);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Friends'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: _searchUsers,
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            if (_searchController.text.length < 3)
                              const Text(
                                'Type at least 3 characters to search',
                                style: TextStyle(color: Colors.grey),
                              )
                            else
                              const Text(
                                'No users found',
                                style: TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          return UserListItem(
                            user: user,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfileScreen(userId: user.uid),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class UserListItem extends StatefulWidget {
  final User user;
  final VoidCallback onTap;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  State<UserListItem> createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  final SocialService _socialService = SocialService();
  bool _isConnecting = false;

  Future<void> _sendRequest() async {
    setState(() {
      _isConnecting = true;
    });

    final currentUserId =
        Provider.of<UserProvider>(context, listen: false).user!.uid;
    await _socialService.sendConnectionRequest(
      currentUserId,
      widget.user.uid,
      ConnectionType.friend,
    );

    setState(() {
      _isConnecting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Friend request sent to ${widget.user.name ?? "User"}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          widget.user.name?.isNotEmpty == true ? widget.user.name![0] : '?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(widget.user.name ?? 'User'),
      subtitle: Text(widget.user.email),
      trailing: _isConnecting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : ElevatedButton(
              onPressed: _sendRequest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 36),
              ),
              child: const Text('Add Friend'),
            ),
    );
  }
}
