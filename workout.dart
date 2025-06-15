import 'package:flutter/material.dart';

/// Model class representing a workout in the application
class Workout {
  final String name;
  final String duration;
  final String difficulty;
  final String caloriesBurn;
  final String? description;
  final String? videoPath;
  final String? imagePath;
  final String type;
  final int durationMinutes;

  Workout({
    required this.name,
    required this.duration,
    required this.difficulty,
    required this.caloriesBurn,
    this.description,
    this.videoPath,
    this.imagePath,
    this.type = '',
    int? durationMinutes,
  }) : durationMinutes = durationMinutes ?? _parseDurationMinutes(duration);

  /// Create a workout from JSON data
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      name: json['name'] ?? '',
      duration: json['duration'] ?? '',
      difficulty: json['difficulty'] ?? '',
      caloriesBurn: json['calories_burn'] ?? '',
      description: json['description'],
      videoPath: json['video_path'],
      imagePath: json['image_path'],
      type: json['type'] ?? '',
      durationMinutes: json['duration_minutes'],
    );
  }

  /// Convert workout to JSON data
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration': duration,
      'difficulty': difficulty,
      'calories_burn': caloriesBurn,
      'description': description,
      'video_path': videoPath,
      'image_path': imagePath,
      'type': type,
      'duration_minutes': durationMinutes,
    };
  }

  /// Get the color representation for the workout difficulty
  Color getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  /// Get appropriate icon for the workout type
  IconData getTypeIcon() {
    final lowercaseType = name.toLowerCase();
    if (lowercaseType.contains('yoga')) return Icons.self_improvement;
    if (lowercaseType.contains('hiit')) return Icons.flash_on;
    if (lowercaseType.contains('core')) return Icons.fitness_center;
    if (lowercaseType.contains('cardio')) return Icons.directions_run;
    return Icons.sports_gymnastics;
  }
  
  /// Parse duration string to minutes
  static int _parseDurationMinutes(String duration) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(duration);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }
}
