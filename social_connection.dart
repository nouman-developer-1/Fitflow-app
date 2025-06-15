import 'package:cloud_firestore/cloud_firestore.dart';

class SocialConnection {
  final String id;
  final String userId;
  final String connectedUserId;
  final ConnectionType connectionType;
  final DateTime createdAt;
  final ConnectionStatus status;

  SocialConnection({
    required this.id,
    required this.userId,
    required this.connectedUserId,
    required this.connectionType,
    required this.createdAt,
    required this.status,
  });

  factory SocialConnection.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialConnection(
      id: doc.id,
      userId: data['userId'] ?? '',
      connectedUserId: data['connectedUserId'] ?? '',
      connectionType: _connectionTypeFromString(data['connectionType'] ?? 'following'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: _connectionStatusFromString(data['status'] ?? 'pending'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'connectedUserId': connectedUserId,
      'connectionType': connectionType.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
    };
  }

  static ConnectionType _connectionTypeFromString(String type) {
    switch (type) {
      case 'friend':
        return ConnectionType.friend;
      case 'following':
      default:
        return ConnectionType.following;
    }
  }

  static ConnectionStatus _connectionStatusFromString(String status) {
    switch (status) {
      case 'accepted':
        return ConnectionStatus.accepted;
      case 'rejected':
        return ConnectionStatus.rejected;
      case 'pending':
      default:
        return ConnectionStatus.pending;
    }
  }
}

enum ConnectionType { friend, following }
enum ConnectionStatus { pending, accepted, rejected }
