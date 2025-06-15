import 'package:cloud_firestore/cloud_firestore.dart';

class SocialActivity {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final ActivityType type;
  final String title;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final List<String> likedByUsers;
  final List<ActivityComment> comments;

  SocialActivity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.type,
    required this.title,
    required this.description,
    required this.metadata,
    required this.createdAt,
    required this.likedByUsers,
    required this.comments,
  });

  factory SocialActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    List<ActivityComment> comments = [];
    if (data['comments'] != null) {
      comments = (data['comments'] as List)
          .map((commentData) => ActivityComment.fromMap(commentData))
          .toList();
    }
    
    return SocialActivity(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      type: _activityTypeFromString(data['type'] ?? ''),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      metadata: data['metadata'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likedByUsers: List<String>.from(data['likedByUsers'] ?? []),
      comments: comments,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'type': type.name,
      'title': title,
      'description': description,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedByUsers': likedByUsers,
      'comments': comments.map((comment) => comment.toMap()).toList(),
    };
  }

  static ActivityType _activityTypeFromString(String type) {
    switch (type) {
      case 'workout_completed':
        return ActivityType.workoutCompleted;
      case 'achievement_unlocked':
        return ActivityType.achievementUnlocked;
      case 'milestone_reached':
        return ActivityType.milestoneReached;
      case 'challenge_started':
        return ActivityType.challengeStarted;
      case 'challenge_completed':
        return ActivityType.challengeCompleted;
      case 'shared_workout':
        return ActivityType.sharedWorkout;
      default:
        return ActivityType.general;
    }
  }
  
  // Create a workout completion activity
  static SocialActivity createWorkoutActivity({
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required String workoutName,
    required int duration,
    required int caloriesBurnt,
  }) {
    return SocialActivity(
      id: '',
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      type: ActivityType.workoutCompleted,
      title: 'Completed a Workout',
      description: 'Completed $workoutName workout',
      metadata: {
        'workoutName': workoutName,
        'duration': duration,
        'caloriesBurnt': caloriesBurnt,
      },
      createdAt: DateTime.now(),
      likedByUsers: [],
      comments: [],
    );
  }
  
  // Create an achievement activity
  static SocialActivity createAchievementActivity({
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required String achievementName,
    required String achievementDescription,
    required String achievementIcon,
  }) {
    return SocialActivity(
      id: '',
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      type: ActivityType.achievementUnlocked,
      title: 'Unlocked an Achievement',
      description: 'Unlocked: $achievementName',
      metadata: {
        'achievementName': achievementName,
        'achievementDescription': achievementDescription,
        'achievementIcon': achievementIcon,
      },
      createdAt: DateTime.now(),
      likedByUsers: [],
      comments: [],
    );
  }
}

class ActivityComment {
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String text;
  final DateTime createdAt;

  ActivityComment({
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  factory ActivityComment.fromMap(Map<String, dynamic> data) {
    return ActivityComment(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum ActivityType {
  general,
  workoutCompleted,
  achievementUnlocked,
  milestoneReached,
  challengeStarted,
  challengeCompleted,
  sharedWorkout,
}
