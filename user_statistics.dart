/// Model class for representing user workout statistics
class UserStatistics {
  /// Total number of workouts completed
  final int totalWorkouts;
  
  /// Total minutes spent working out
  final int totalMinutes;
  
  /// Total calories burned across all workouts
  final int totalCaloriesBurned;
  
  UserStatistics({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalCaloriesBurned,
  });
}
