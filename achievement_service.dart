import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/achievement.dart';
import '../models/workout_category.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  final String _achievementsKey = 'user_achievements';
  final String _workoutHistoryKey = 'workout_history';
  final String _streakDataKey = 'workout_streak_data';
  bool _isInitialized = false;

  factory AchievementService() => _instance;

  AchievementService._internal();

  // Safe initialization to handle web platform issues
  void _initializeIfNeeded() {
    if (_isInitialized) return;

    try {
      // Initialize any Firebase or other services here that might cause JS issues
      debugPrint('Achievement service initialized safely');
    } catch (e) {
      debugPrint('Error initializing achievement service: $e');
    }

    _isInitialized = true;
  }

  // Get all user achievements
  Future<List<Achievement>> getAchievements() async {
    _initializeIfNeeded();
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? achievementsJson = prefs.getString(_achievementsKey);

      if (achievementsJson == null) {
        return [];
      }

      final List<dynamic> decodedData = jsonDecode(achievementsJson);
      return decodedData.map((item) => Achievement.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error getting achievements: $e');
      return [];
    }
  }

  // Save achievements to storage
  Future<bool> saveAchievements(List<Achievement> achievements) async {
    _initializeIfNeeded();
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedData = jsonEncode(
          achievements.map((achievement) => achievement.toJson()).toList());
      return await prefs.setString(_achievementsKey, encodedData);
    } catch (e) {
      debugPrint('Error saving achievements: $e');
      return false;
    }
  }

  // Add a new achievement
  Future<bool> addAchievement(Achievement achievement) async {
    _initializeIfNeeded();
    try {
      final achievements = await getAchievements();

      // Check if achievement with same ID already exists
      final existingIndex =
          achievements.indexWhere((a) => a.id == achievement.id);

      if (existingIndex >= 0) {
        // Update existing achievement
        achievements[existingIndex] = achievement;
      } else {
        // Add new achievement
        achievements.add(achievement);
      }

      return await saveAchievements(achievements);
    } catch (e) {
      debugPrint('Error adding achievement: $e');
      return false;
    }
  }

  // Get specific achievement by ID
  Future<Achievement?> getAchievementById(String id) async {
    _initializeIfNeeded();
    try {
      final achievements = await getAchievements();
      return achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      debugPrint('Error getting achievement by ID: $e');
      return null;
    }
  }

  // Record a completed workout
  Future<void> recordWorkoutCompletion(WorkoutCategory workout) async {
    _initializeIfNeeded();
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_workoutHistoryKey);
      List<Map<String, dynamic>> history = [];

      if (historyJson != null) {
        final List<dynamic> decodedData = jsonDecode(historyJson);
        history = List<Map<String, dynamic>>.from(decodedData);
      }

      // Add new workout record
      history.add({
        'name': workout.name,
        'date': DateTime.now().toIso8601String(),
        'difficulty': workout.difficulty.toString(),
        'duration': workout.estimatedDurationMinutes,
        'calories': workout.estimatedCaloriesBurn,
      });

      await prefs.setString(_workoutHistoryKey, jsonEncode(history));

      // Update streak data
      await _updateWorkoutStreak();

      // Check for achievements
      await _checkWorkoutAchievements(history);
    } catch (e) {
      debugPrint('Error recording workout completion: $e');
    }
  }

  // Get workout history
  Future<List<Map<String, dynamic>>> getWorkoutHistory() async {
    _initializeIfNeeded();
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_workoutHistoryKey);

      if (historyJson == null) {
        return [];
      }

      final List<dynamic> decodedData = jsonDecode(historyJson);
      return List<Map<String, dynamic>>.from(decodedData);
    } catch (e) {
      debugPrint('Error getting workout history: $e');
      return [];
    }
  }

  // Update workout streak
  Future<void> _updateWorkoutStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getWorkoutHistory();

      if (history.isEmpty) {
        return;
      }

      // Get streak data or initialize
      final String? streakJson = prefs.getString(_streakDataKey);
      Map<String, dynamic> streakData = {
        'current_streak': 0,
        'longest_streak': 0,
        'last_workout_date': null,
      };

      if (streakJson != null) {
        streakData = Map<String, dynamic>.from(jsonDecode(streakJson));
      }

      // Sort history by date
      history.sort((a, b) =>
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

      final DateTime today = DateTime.now();
      final DateTime todayDate = DateTime(today.year, today.month, today.day);

      // Get latest workout date
      final DateTime latestWorkoutDate = DateTime.parse(history.first['date']);
      final DateTime latestWorkoutDay = DateTime(latestWorkoutDate.year,
          latestWorkoutDate.month, latestWorkoutDate.day);

      // Get previous workout date from saved data
      DateTime? previousWorkoutDate;
      if (streakData['last_workout_date'] != null) {
        previousWorkoutDate = DateTime.parse(streakData['last_workout_date']);
      }

      int currentStreak = streakData['current_streak'] ?? 0;
      int longestStreak = streakData['longest_streak'] ?? 0;

      // Check if this is a workout for today
      if (latestWorkoutDay.isAtSameMomentAs(todayDate)) {
        // Already counted in streak, no need to update
        streakData['last_workout_date'] = latestWorkoutDate.toIso8601String();
      }
      // Check if this workout is one day after the previous workout
      else if (previousWorkoutDate != null) {
        final previousDate = DateTime(previousWorkoutDate.year,
            previousWorkoutDate.month, previousWorkoutDate.day);

        // Workout done one day after previous = streak continues
        if (latestWorkoutDay.difference(previousDate).inDays == 1) {
          currentStreak += 1;
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
        }
        // Workout done same day = no streak change
        else if (latestWorkoutDay.isAtSameMomentAs(previousDate)) {
          // No change to streak
        }
        // Streak broken
        else {
          currentStreak = 1; // Reset streak, today is first day
        }

        streakData['last_workout_date'] = latestWorkoutDate.toIso8601String();
      }
      // First workout ever
      else {
        currentStreak = 1;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
        streakData['last_workout_date'] = latestWorkoutDate.toIso8601String();
      }

      // Update streak data
      streakData['current_streak'] = currentStreak;
      streakData['longest_streak'] = longestStreak;

      await prefs.setString(_streakDataKey, jsonEncode(streakData));

      // Check for streak achievements
      await _checkStreakAchievements(streakData);
    } catch (e) {
      debugPrint('Error updating workout streak: $e');
    }
  }

  // Check for workout-related achievements
  Future<void> _checkWorkoutAchievements(
      List<Map<String, dynamic>> history) async {
    try {
      if (history.isEmpty) return;

      // Achievement: First Workout
      if (history.length == 1) {
        final firstWorkoutAchievement = Achievement(
          id: 'first_workout',
          title: 'First Workout',
          description: 'Completed your first workout',
          icon: Icons.fitness_center,
          color: Colors.green,
          type: AchievementType.workout,
          pointsValue: 10,
          awardedDate: DateTime.now(),
          isUnlocked: true,
        );
        await addAchievement(firstWorkoutAchievement);
      }

      // Achievement: 10 Workouts
      if (history.length == 10) {
        final tenWorkoutsAchievement = Achievement(
          id: 'ten_workouts',
          title: 'Workout Warrior',
          description: 'Completed 10 workouts',
          icon: Icons.fitness_center,
          color: Colors.blue,
          type: AchievementType.milestone,
          pointsValue: 25,
          awardedDate: DateTime.now(),
          isUnlocked: true,
        );
        await addAchievement(tenWorkoutsAchievement);
      }

      // Achievement: 25 Workouts
      if (history.length == 25) {
        final twentyFiveWorkoutsAchievement = Achievement(
          id: 'twentyfive_workouts',
          title: 'Fitness Fanatic',
          description: 'Completed 25 workouts',
          icon: Icons.fitness_center,
          color: Colors.purple,
          type: AchievementType.milestone,
          pointsValue: 50,
          awardedDate: DateTime.now(),
          isUnlocked: true,
        );
        await addAchievement(twentyFiveWorkoutsAchievement);
      }

      // Achievement: First Advanced Workout
      final advancedWorkouts = history
          .where((workout) =>
              workout['difficulty'].toString().contains('advanced'))
          .toList();

      if (advancedWorkouts.length == 1) {
        final advancedWorkoutAchievement = Achievement(
          id: 'first_advanced',
          title: 'Challenge Accepted',
          description: 'Completed your first advanced workout',
          icon: Icons.whatshot,
          color: Colors.orange,
          type: AchievementType.workout,
          pointsValue: 30,
          awardedDate: DateTime.now(),
          isUnlocked: true,
        );
        await addAchievement(advancedWorkoutAchievement);
      }

      // Check for early bird achievement (workout before 8 AM)
      final earlyWorkouts = history.where((workout) {
        final workoutDate = DateTime.parse(workout['date']);
        return workoutDate.hour < 8;
      }).toList();

      if (earlyWorkouts.length == 5) {
        final earlyBirdAchievement = Achievement(
          id: 'early_bird',
          title: 'Early Bird',
          description: 'Completed 5 workouts before 8 AM',
          icon: Icons.wb_sunny,
          color: Colors.amber,
          type: AchievementType.challenge,
          pointsValue: 40,
          awardedDate: DateTime.now(),
          isUnlocked: true,
        );
        await addAchievement(earlyBirdAchievement);
      }
    } catch (e) {
      debugPrint('Error checking workout achievements: $e');
    }
  }

  // Check for streak-related achievements
  Future<void> _checkStreakAchievements(Map<String, dynamic> streakData) async {
    try {
      final currentStreak = streakData['current_streak'] as int;

      // 3-Day Streak Achievement
      if (currentStreak == 3) {
        final threeStreakAchievement = Achievement(
          id: 'three_day_streak',
          title: 'On Fire',
          description: 'Workout streak of 3 days',
          icon: Icons.local_fire_department,
          color: Colors.orange,
          type: AchievementType.streak,
          pointsValue: 15,
          awardedDate: DateTime.now(),
          isUnlocked: true,
        );
        await addAchievement(threeStreakAchievement);
      }

      // 7-Day Streak Achievement
      if (currentStreak == 7) {
        final weekStreakAchievement = Achievement(
          id: 'week_streak',
          title: 'Week Warrior',
          description: 'Workout streak of 7 days',
          icon: Icons.local_fire_department,
          color: Colors.red,
          type: AchievementType.streak,
          pointsValue: 30,
          awardedDate: DateTime.now(),
          isUnlocked: true,
        );
        await addAchievement(weekStreakAchievement);
      }

      // 30-Day Streak Achievement
      if (currentStreak == 30) {
        final monthStreakAchievement = Achievement(
          id: 'month_streak',
          title: 'Consistency King',
          description: 'Workout streak of 30 days',
          icon: Icons.emoji_events,
          color: Colors.purple,
          type: AchievementType.streak,
          pointsValue: 100,
          awardedDate: DateTime.now(),
          isUnlocked: true,
        );
        await addAchievement(monthStreakAchievement);
      }
    } catch (e) {
      debugPrint('Error checking streak achievements: $e');
    }
  }

  // Get preset achievements (locked until earned)
  List<Achievement> getPresetAchievements() {
    final DateTime now = DateTime.now();

    return [
      Achievement(
        id: 'first_workout',
        title: 'First Workout',
        description: 'Complete your first workout',
        icon: Icons.fitness_center,
        color: Colors.green,
        type: AchievementType.workout,
        pointsValue: 10,
        awardedDate: now,
        isUnlocked: false,
      ),
      Achievement(
        id: 'three_day_streak',
        title: 'On Fire',
        description: 'Reach a workout streak of 3 days',
        icon: Icons.local_fire_department,
        color: Colors.orange,
        type: AchievementType.streak,
        pointsValue: 15,
        awardedDate: now,
        isUnlocked: false,
      ),
      Achievement(
        id: 'week_streak',
        title: 'Week Warrior',
        description: 'Reach a workout streak of 7 days',
        icon: Icons.local_fire_department,
        color: Colors.red,
        type: AchievementType.streak,
        pointsValue: 30,
        awardedDate: now,
        isUnlocked: false,
      ),
      Achievement(
        id: 'ten_workouts',
        title: 'Workout Warrior',
        description: 'Complete 10 workouts',
        icon: Icons.fitness_center,
        color: Colors.blue,
        type: AchievementType.milestone,
        pointsValue: 25,
        awardedDate: now,
        isUnlocked: false,
      ),
      Achievement(
        id: 'first_advanced',
        title: 'Challenge Accepted',
        description: 'Complete an advanced workout',
        icon: Icons.whatshot,
        color: Colors.orange,
        type: AchievementType.workout,
        pointsValue: 30,
        awardedDate: now,
        isUnlocked: false,
      ),
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Complete 5 workouts before 8 AM',
        icon: Icons.wb_sunny,
        color: Colors.amber,
        type: AchievementType.challenge,
        pointsValue: 40,
        awardedDate: now,
        isUnlocked: false,
      ),
      Achievement(
        id: 'month_streak',
        title: 'Consistency King',
        description: 'Reach a workout streak of 30 days',
        icon: Icons.emoji_events,
        color: Colors.purple,
        type: AchievementType.streak,
        pointsValue: 100,
        awardedDate: now,
        isUnlocked: false,
      ),
      Achievement(
        id: 'twentyfive_workouts',
        title: 'Fitness Fanatic',
        description: 'Complete 25 workouts',
        icon: Icons.fitness_center,
        color: Colors.purple,
        type: AchievementType.milestone,
        pointsValue: 50,
        awardedDate: now,
        isUnlocked: false,
      ),
    ];
  }

  // Initialize user achievements (for new users)
  Future<void> initializeUserAchievements() async {
    final currentAchievements = await getAchievements();

    // Only initialize if there are no achievements yet
    if (currentAchievements.isEmpty) {
      final presetAchievements = getPresetAchievements();
      await saveAchievements(presetAchievements);
    }
  }
}
