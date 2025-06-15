import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitflow/models/social_connection.dart';
import 'package:fitflow/models/user_model.dart';
import 'package:flutter/foundation.dart';

class SocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _connectionsCollection =>
      _firestore.collection('social_connections');

  // Get user's connections (friends/following)
  Future<List<SocialConnection>> getUserConnections(String userId,
      {ConnectionType? type}) async {
    try {
      QuerySnapshot snapshot = await _connectionsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: ConnectionStatus.accepted.name)
          .get();

      List<SocialConnection> connections = snapshot.docs
          .map((doc) => SocialConnection.fromFirestore(doc))
          .toList();

      if (type != null) {
        connections =
            connections.where((conn) => conn.connectionType == type).toList();
      }

      return connections;
    } catch (e) {
      debugPrint('Error getting user connections: $e');
      return [];
    }
  }

  // Get connection requests (pending)
  Future<List<SocialConnection>> getPendingRequests(String userId) async {
    try {
      QuerySnapshot snapshot = await _connectionsCollection
          .where('connectedUserId', isEqualTo: userId)
          .where('status', isEqualTo: ConnectionStatus.pending.name)
          .get();

      return snapshot.docs
          .map((doc) => SocialConnection.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting pending requests: $e');
      return [];
    }
  }

  // Send connection request
  Future<bool> sendConnectionRequest(
      String currentUserId, String targetUserId, ConnectionType type) async {
    try {
      // Check if connection already exists
      QuerySnapshot existingConnections = await _connectionsCollection
          .where('userId', isEqualTo: currentUserId)
          .where('connectedUserId', isEqualTo: targetUserId)
          .get();

      if (existingConnections.docs.isNotEmpty) {
        debugPrint('Connection already exists');
        return false;
      }

      // Create new connection
      await _connectionsCollection.add(
        SocialConnection(
          id: '',
          userId: currentUserId,
          connectedUserId: targetUserId,
          connectionType: type,
          createdAt: DateTime.now(),
          status: type == ConnectionType.following
              ? ConnectionStatus.accepted // Auto-accept follows
              : ConnectionStatus.pending, // Friends need acceptance
        ).toMap(),
      );

      return true;
    } catch (e) {
      debugPrint('Error sending connection request: $e');
      return false;
    }
  }

  // Accept connection request
  Future<bool> acceptConnectionRequest(String connectionId) async {
    try {
      await _connectionsCollection.doc(connectionId).update({
        'status': ConnectionStatus.accepted.name,
      });

      return true;
    } catch (e) {
      debugPrint('Error accepting connection request: $e');
      return false;
    }
  }

  // Reject connection request
  Future<bool> rejectConnectionRequest(String connectionId) async {
    try {
      await _connectionsCollection.doc(connectionId).update({
        'status': ConnectionStatus.rejected.name,
      });

      return true;
    } catch (e) {
      debugPrint('Error rejecting connection request: $e');
      return false;
    }
  }

  // Remove connection
  Future<bool> removeConnection(String connectionId) async {
    try {
      await _connectionsCollection.doc(connectionId).delete();
      return true;
    } catch (e) {
      debugPrint('Error removing connection: $e');
      return false;
    }
  }

  // Search users
  Future<List<User>> searchUsers(String query, String currentUserId) async {
    try {
      if (query.length < 3) return [];

      QuerySnapshot snapshot = await _usersCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      List<User> users = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return User(
              uid: doc.id,
              email: data['email'] ?? '',
              name: data['name'],
              age: data['age'],
              weight: data['weight'],
              height: data['height'],
              fitnessGoal: data['fitnessGoal'],
            );
          })
          .where((user) => user.uid != currentUserId) // Exclude current user
          .toList();

      return users;
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return User(
          uid: doc.id,
          email: data['email'] ?? '',
          name: data['name'],
          age: data['age'],
          weight: data['weight'],
          height: data['height'],
          fitnessGoal: data['fitnessGoal'],
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }
}
