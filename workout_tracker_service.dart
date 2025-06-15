import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'dart:convert';
import '../models/workout_category.dart';
import '../models/workout.dart';
import '../models/user_statistics.dart';

/// Service for tracking user workout progress and history
class WorkoutTrackerService {
  // Singleton instance
  static final WorkoutTrackerService _instance =
      WorkoutTrackerService._internal();
  factory WorkoutTrackerService() => _instance;
  WorkoutTrackerService._internal();

  // Firebase instances - handle safe initialization
  FirebaseFirestore? _firestore;
  firebase.FirebaseAuth? _auth;
  bool _isInitialized = false;

  // Constants
  static const String _localWorkoutHistoryKey = 'workout_history';
  static const String _localWorkoutStatsKey = 'workout_stats';
  static const String _firestoreWorkoutCollection = 'workout_history';
  static const String _firestoreStatsCollection = 'workout_stats';

  // Get current user ID (or anonymous ID if not signed in)
  String get _userId {
    _initializeIfNeeded();
    final user = _auth?.currentUser;
    return user?.uid ?? 'anonymous_user';
  }

  // Safe initialization to handle web platform issues
  void _initializeIfNeeded() {
    if (_isInitialized) return;

    try {
      if (!kIsWeb) {
        // On mobile platforms, initialize Firebase normally
        _firestore = FirebaseFirestore.instance;
        _auth = firebase.FirebaseAuth.instance;
      } else {
        // On web platform, we'll skip Firebase for this demo
        debugPrint('Skipping Firebase initialization on web platform');
        _firestore = null;
        _auth = null;
      }
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      _firestore = null;
      _auth = null;
    }

    _isInitialized = true;
  }

  // Records a completed workout
  Future<void> recordWorkout({
    required WorkoutCategory category,
    required Duration duration,
    required int caloriesBurned,
    required DateTime completedAt,
    String? notes,
  }) async {
    _initializeIfNeeded();

    try {
      final workoutData = {
        'userId': _userId,
        'categoryId': category.name,
        'categoryName': category.name,
        'difficulty': category.difficulty.toString(),
        'duration': duration.inSeconds,
        'caloriesBurned': caloriesBurned,
        'completedAt': completedAt.toIso8601String(),
        'notes': notes,
      };

      // Try to save to Firebase if available
      if (_firestore != null && _auth?.currentUser != null) {
        await _firestore!
            .collection(_firestoreWorkoutCollection)
            .add(workoutData);

        debugPrint('Workout saved to Firestore');
      } else {
        debugPrint('Firebase not available, saving workout locally only');
      }

      // Always save locally as a backup
      await _saveWorkoutLocally(workoutData);

      // Update stats
      await _updateWorkoutStats(category, duration, caloriesBurned);

      debugPrint('Workout recorded successfully');
    } catch (e) {
      debugPrint('Error recording workout: $e');
      // Ensure we at least try to save locally
      try {
        final workoutData = {
          'userId': _userId,
          'categoryId': category.name,
          'categoryName': category.name,
          'difficulty': category.difficulty.toString(),
          'duration': duration.inSeconds,
          'caloriesBurned': caloriesBurned,
          'completedAt': completedAt.toIso8601String(),
          'notes': notes,
        };
        await _saveWorkoutLocally(workoutData);
      } catch (localError) {
        debugPrint('Failed to save workout even locally: $localError');
      }
    }
  }

  // Save workout data to SharedPreferences
  Future<void> _saveWorkoutLocally(Map<String, dynamic> workoutData) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing workouts
    final List<String> workoutStrings =
        prefs.getStringList(_localWorkoutHistoryKey) ?? [];

    // Add new workout
    workoutStrings.add(json.encode(workoutData));

    // Save back to prefs
    await prefs.setStringList(_localWorkoutHistoryKey, workoutStrings);
    debugPrint('Workout saved locally');
  }

  // Update workout statistics
  Future<void> _updateWorkoutStats(
    WorkoutCategory category,
    Duration duration,
    int caloriesBurned,
  ) async {
    _initializeIfNeeded();

    try {
      // Get existing stats
      final stats = await getWorkoutStats();

      // Update stats
      final updatedStats = {
        'totalWorkouts': (stats['totalWorkouts'] ?? 0) + 1,
        'totalDuration': (stats['totalDuration'] ?? 0) + duration.inMinutes,
        'totalCaloriesBurned':
            (stats['totalCaloriesBurned'] ?? 0) + caloriesBurned,
        'lastWorkoutDate': DateTime.now().toIso8601String(),
        'workoutsByCategory': _updateCategoryStats(
          stats['workoutsByCategory'] ?? {},
          category.name,
        ),
      };

      // Try to save to Firebase if available
      if (_firestore != null && _auth?.currentUser != null) {
        await _firestore!
            .collection(_firestoreStatsCollection)
            .doc(_userId)
            .set(updatedStats);

        debugPrint('Workout stats updated in Firestore');
      } else {
        debugPrint('Firebase not available, saving stats locally only');
      }

      // Always save locally as a backup
      await _saveStatsLocally(updatedStats);
    } catch (e) {
      debugPrint('Error updating workout stats: $e');
      // Try saving locally
      try {
        final stats = await getWorkoutStats();
        final updatedStats = {
          'totalWorkouts': (stats['totalWorkouts'] ?? 0) + 1,
          'totalDuration': (stats['totalDuration'] ?? 0) + duration.inMinutes,
          'totalCaloriesBurned':
              (stats['totalCaloriesBurned'] ?? 0) + caloriesBurned,
          'lastWorkoutDate': DateTime.now().toIso8601String(),
          'workoutsByCategory': _updateCategoryStats(
            stats['workoutsByCategory'] ?? {},
            category.name,
          ),
        };
        await _saveStatsLocally(updatedStats);
      } catch (localError) {
        debugPrint('Failed to update stats even locally: $localError');
      }
    }
  }

  // Helper to update category-specific statistics
  Map<String, dynamic> _updateCategoryStats(
    Map<String, dynamic> currentCategoryStats,
    String categoryName,
  ) {
    final updatedCategoryStats =
        Map<String, dynamic>.from(currentCategoryStats);
    final count = updatedCategoryStats[categoryName] ?? 0;
    updatedCategoryStats[categoryName] = count + 1;
    return updatedCategoryStats;
  }

  // Save stats to SharedPreferences
  Future<void> _saveStatsLocally(Map<String, dynamic> stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localWorkoutStatsKey, json.encode(stats));
    debugPrint('Workout stats saved locally');
  }

  // Get workout history
  Future<List<Map<String, dynamic>>> getWorkoutHistory() async {
    _initializeIfNeeded();

    try {
      final List<Map<String, dynamic>> workouts = [];

      // Try to get from Firebase first
      if (_firestore != null && _auth?.currentUser != null) {
        final snapshot = await _firestore!
            .collection(_firestoreWorkoutCollection)
            .where('userId', isEqualTo: _userId)
            .orderBy('completedAt', descending: true)
            .get();

        for (var doc in snapshot.docs) {
          workouts.add(doc.data());
        }

        if (workouts.isNotEmpty) {
          debugPrint('Loaded ${workouts.length} workouts from Firestore');
          return workouts;
        }
      }

      // Fallback to local storage
      debugPrint('Falling back to local workout history');
      final prefs = await SharedPreferences.getInstance();
      final List<String> workoutStrings =
          prefs.getStringList(_localWorkoutHistoryKey) ?? [];

      for (var workoutString in workoutStrings) {
        workouts.add(json.decode(workoutString));
      }

      // Sort by completedAt (most recent first)
      workouts.sort((a, b) => DateTime.parse(b['completedAt'])
          .compareTo(DateTime.parse(a['completedAt'])));

      return workouts;
    } catch (e) {
      debugPrint('Error getting workout history: $e');
      return [];
    }
  }

  // Get workout stats
  Future<Map<String, dynamic>> getWorkoutStats() async {
    _initializeIfNeeded();

    try {
      // Try to get from Firebase if available
      if (_firestore != null && _auth?.currentUser != null) {
        final docSnapshot = await _firestore!
            .collection(_firestoreStatsCollection)
            .doc(_userId)
            .get();

        if (docSnapshot.exists) {
          return docSnapshot.data() ??
              {
                'totalWorkouts': 0,
                'totalDuration': 0,
                'totalCaloriesBurned': 0,
                'workoutsByCategory': {},
              };
        }
      }

      // Fall back to local storage
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString(_localWorkoutStatsKey);
      if (statsString != null) {
        return json.decode(statsString);
      }

      // Return empty stats if nothing found
      return {
        'totalWorkouts': 0,
        'totalDuration': 0,
        'totalCaloriesBurned': 0,
        'workoutsByCategory': {},
      };
    } catch (e) {
      debugPrint('Error getting workout stats: $e');
      return {
        'totalWorkouts': 0,
        'totalDuration': 0,
        'totalCaloriesBurned': 0,
        'workoutsByCategory': {},
      };
    }
  }

  /// Get user statistics in a user-friendly format
  Future<UserStatistics> getUserStatistics() async {
    final stats = await getWorkoutStats();

    return UserStatistics(
      totalWorkouts: stats['totalWorkouts'] ?? 0,
      totalMinutes: stats['totalDuration'] ?? 0,
      totalCaloriesBurned: stats['totalCaloriesBurned'] ?? 0,
    );
  }

  /// Get recommended workouts for the user
  Future<List<Workout>> getRecommendedWorkouts() async {
    try {
      // In a real app, these could come from Firebase based on user preferences/history
      return [
        Workout(
          name: 'Morning Energizer',
          duration: '15 min',
          difficulty: 'Beginner',
          caloriesBurn: '120 kcal',
          type: 'HIIT',
          description:
              'Start your day with this quick but intense morning routine to boost your energy.',
        ),
        Workout(
          name: 'Full Body Strength',
          duration: '45 min',
          difficulty: 'Intermediate',
          caloriesBurn: '350 kcal',
          type: 'Strength',
          description:
              'A complete strength workout targeting all major muscle groups for balanced fitness.',
        ),
        Workout(
          name: 'Yoga Flow',
          duration: '30 min',
          difficulty: 'Beginner',
          caloriesBurn: '150 kcal',
          type: 'Yoga',
          description:
              'Improve flexibility and mindfulness with this calming yoga sequence.',
        ),
        Workout(
          name: 'Core Crusher',
          duration: '20 min',
          difficulty: 'Advanced',
          caloriesBurn: '220 kcal',
          type: 'Core',
          description:
              'Focus on building core strength with this intense abdominal and back workout.',
        ),
        Workout(
          name: 'Cardio Blast',
          duration: '25 min',
          difficulty: 'Intermediate',
          caloriesBurn: '280 kcal',
          type: 'Cardio',
          description:
              'Get your heart rate up with this high-energy cardio session to burn calories.',
        ),
      ];
    } catch (e) {
      debugPrint('Error getting recommended workouts: $e');
      return [];
    }
  }

  // Sync local data with Firebase (call when user signs in)
  Future<void> syncLocalDataWithFirebase() async {
    if (_firestore == null || _auth == null) {
      debugPrint('Cannot sync with Firebase: Not available or not signed in');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Sync workout history
      final List<String> workoutStrings =
          prefs.getStringList(_localWorkoutHistoryKey) ?? [];
      for (var workoutString in workoutStrings) {
        final workout = json.decode(workoutString);
        if (workout['userId'] == 'anonymous_user') {
          // Update to current user ID
          workout['userId'] = _userId;
        }

        // Add to Firestore
        await _firestore!.collection(_firestoreWorkoutCollection).add(workout);
      }

      // Sync workout stats
      final statsString = prefs.getString(_localWorkoutStatsKey);
      if (statsString != null) {
        final stats = json.decode(statsString);

        // Get existing Firebase stats
        final docSnapshot = await _firestore!
            .collection(_firestoreStatsCollection)
            .doc(_userId)
            .get();

        if (docSnapshot.exists) {
          // Merge local and Firebase stats
          final firebaseStats = docSnapshot.data() ?? {};
          final mergedStats = _mergeStats(firebaseStats, stats);
          await _firestore!
              .collection(_firestoreStatsCollection)
              .doc(_userId)
              .set(mergedStats);
        } else {
          // Just set local stats
          await _firestore!
              .collection(_firestoreStatsCollection)
              .doc(_userId)
              .set(stats);
        }
      }

      debugPrint('Synced local workout data with Firebase');
    } catch (e) {
      debugPrint('Error syncing with Firebase: $e');
    }
  }

  // Helper to merge local and Firebase stats
  Map<String, dynamic> _mergeStats(
    Map<String, dynamic> firebaseStats,
    Map<String, dynamic> localStats,
  ) {
    // Create a copy to modify
    final Map<String, dynamic> merged = Map.from(firebaseStats);

    // Merge simple numeric values
    merged['totalWorkouts'] =
        (merged['totalWorkouts'] ?? 0) + (localStats['totalWorkouts'] ?? 0);
    merged['totalDuration'] =
        (merged['totalDuration'] ?? 0) + (localStats['totalDuration'] ?? 0);
    merged['totalCaloriesBurned'] = (merged['totalCaloriesBurned'] ?? 0) +
        (localStats['totalCaloriesBurned'] ?? 0);

    // Keep most recent workout date
    final firebaseDate = merged['lastWorkoutDate'] != null
        ? DateTime.parse(merged['lastWorkoutDate'])
        : DateTime(1970);
    final localDate = localStats['lastWorkoutDate'] != null
        ? DateTime.parse(localStats['lastWorkoutDate'])
        : DateTime(1970);

    merged['lastWorkoutDate'] =
        (firebaseDate.isAfter(localDate) ? firebaseDate : localDate)
            .toIso8601String();

    // Merge category stats
    if (localStats['workoutsByCategory'] != null) {
      merged['workoutsByCategory'] = merged['workoutsByCategory'] ?? {};
      final Map<String, dynamic> mergedCategoryStats =
          Map.from(merged['workoutsByCategory']);

      for (var entry in (localStats['workoutsByCategory'] as Map).entries) {
        final categoryName = entry.key;
        final localCount = entry.value;
        final firebaseCount = mergedCategoryStats[categoryName] ?? 0;
        mergedCategoryStats[categoryName] = firebaseCount + localCount;
      }

      merged['workoutsByCategory'] = mergedCategoryStats;
    }

    return merged;
  }
}
