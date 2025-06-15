import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitflow/models/social_activity.dart';
import 'package:fitflow/models/social_connection.dart';
import 'package:fitflow/services/social_service.dart';
import 'package:flutter/foundation.dart';

class SocialActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SocialService _socialService = SocialService();

  // Collection references
  CollectionReference get _activitiesCollection => _firestore.collection('social_activities');
  
  // Post a new activity
  Future<bool> postActivity(SocialActivity activity) async {
    try {
      await _activitiesCollection.add(activity.toMap());
      return true;
    } catch (e) {
      debugPrint('Error posting activity: $e');
      return false;
    }
  }
  
  // Get feed for user (activities from user and their connections)
  Future<List<SocialActivity>> getFeed(String userId, {int limit = 20}) async {
    try {
      // Get user's connections
      List<SocialConnection> connections = await _socialService.getUserConnections(userId);
      List<String> followingIds = connections.map((conn) => conn.connectedUserId).toList();
      
      // Add current user to see their own activities
      followingIds.add(userId);
      
      // Get activities from these users
      QuerySnapshot snapshot = await _activitiesCollection
          .where('userId', whereIn: followingIds)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => SocialActivity.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting feed: $e');
      return [];
    }
  }
  
  // Get user's activities
  Future<List<SocialActivity>> getUserActivities(String userId, {int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _activitiesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => SocialActivity.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting user activities: $e');
      return [];
    }
  }
  
  // Like an activity
  Future<bool> likeActivity(String activityId, String userId) async {
    try {
      await _activitiesCollection.doc(activityId).update({
        'likedByUsers': FieldValue.arrayUnion([userId]),
      });
      return true;
    } catch (e) {
      debugPrint('Error liking activity: $e');
      return false;
    }
  }
  
  // Unlike an activity
  Future<bool> unlikeActivity(String activityId, String userId) async {
    try {
      await _activitiesCollection.doc(activityId).update({
        'likedByUsers': FieldValue.arrayRemove([userId]),
      });
      return true;
    } catch (e) {
      debugPrint('Error unliking activity: $e');
      return false;
    }
  }
  
  // Comment on an activity
  Future<bool> commentOnActivity(
    String activityId, 
    ActivityComment comment,
  ) async {
    try {
      await _activitiesCollection.doc(activityId).update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
      });
      return true;
    } catch (e) {
      debugPrint('Error commenting on activity: $e');
      return false;
    }
  }
  
  // Delete activity
  Future<bool> deleteActivity(String activityId) async {
    try {
      await _activitiesCollection.doc(activityId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting activity: $e');
      return false;
    }
  }
  
  // Helper method to create and post workout activity
  Future<bool> postWorkoutActivity({
    required String userId,
    required String userName,
    String userPhotoUrl = '',
    required String workoutName,
    required int duration,
    required int caloriesBurnt,
  }) async {
    try {
      SocialActivity activity = SocialActivity.createWorkoutActivity(
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        workoutName: workoutName,
        duration: duration,
        caloriesBurnt: caloriesBurnt,
      );
      
      return await postActivity(activity);
    } catch (e) {
      debugPrint('Error posting workout activity: $e');
      return false;
    }
  }
  
  // Helper method to create and post achievement activity
  Future<bool> postAchievementActivity({
    required String userId,
    required String userName,
    String userPhotoUrl = '',
    required String achievementName,
    required String achievementDescription,
    required String achievementIcon,
  }) async {
    try {
      SocialActivity activity = SocialActivity.createAchievementActivity(
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        achievementName: achievementName,
        achievementDescription: achievementDescription,
        achievementIcon: achievementIcon,
      );
      
      return await postActivity(activity);
    } catch (e) {
      debugPrint('Error posting achievement activity: $e');
      return false;
    }
  }
}
