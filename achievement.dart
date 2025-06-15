import 'package:flutter/material.dart';

enum AchievementType { workout, streak, milestone, challenge, personal }

/// Model representing a user achievement or badge
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementType type;
  final int pointsValue;
  final DateTime awardedDate;
  final bool isUnlocked;
  final Map<String, dynamic>? additionalData;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    this.pointsValue = 10,
    required this.awardedDate,
    this.isUnlocked = false,
    this.additionalData,
  });

  /// Create an achievement from JSON data
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: _getIconFromString(json['icon'] ?? 'trophy'),
      color: _getColorFromString(json['color'] ?? 'orange'),
      type: _getTypeFromString(json['type'] ?? 'workout'),
      pointsValue: json['points_value'] ?? 10,
      awardedDate: json['awarded_date'] != null
          ? DateTime.parse(json['awarded_date'])
          : DateTime.now(),
      isUnlocked: json['is_unlocked'] ?? false,
      additionalData: json['additional_data'],
    );
  }

  /// Convert achievement to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': _getStringFromIcon(icon),
      'color': _getStringFromColor(color),
      'type': _getStringFromType(type),
      'points_value': pointsValue,
      'awarded_date': awardedDate.toIso8601String(),
      'is_unlocked': isUnlocked,
      'additional_data': additionalData,
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'trophy':
        return Icons.emoji_events;
      case 'fire':
        return Icons.local_fire_department;
      case 'fitness':
        return Icons.fitness_center;
      case 'run':
        return Icons.directions_run;
      case 'star':
        return Icons.star;
      case 'trending_up':
        return Icons.trending_up;
      case 'trending_down':
        return Icons.trending_down;
      case 'heart':
        return Icons.favorite;
      case 'bolt':
        return Icons.bolt;
      case 'timer':
        return Icons.timer;
      case 'calendar':
        return Icons.calendar_today;
      case 'medal':
        return Icons.workspace_premium;
      case 'sun':
        return Icons.wb_sunny;
      default:
        return Icons.emoji_events;
    }
  }

  static String _getStringFromIcon(IconData icon) {
    if (icon == Icons.emoji_events) return 'trophy';
    if (icon == Icons.local_fire_department) return 'fire';
    if (icon == Icons.fitness_center) return 'fitness';
    if (icon == Icons.directions_run) return 'run';
    if (icon == Icons.star) return 'star';
    if (icon == Icons.trending_up) return 'trending_up';
    if (icon == Icons.trending_down) return 'trending_down';
    if (icon == Icons.favorite) return 'heart';
    if (icon == Icons.bolt) return 'bolt';
    if (icon == Icons.timer) return 'timer';
    if (icon == Icons.calendar_today) return 'calendar';
    if (icon == Icons.workspace_premium) return 'medal';
    if (icon == Icons.wb_sunny) return 'sun';
    return 'trophy';
  }

  static Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.orange;
    }
  }

  static String _getStringFromColor(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.teal) return 'teal';
    return 'orange';
  }

  static AchievementType _getTypeFromString(String typeName) {
    switch (typeName) {
      case 'workout':
        return AchievementType.workout;
      case 'streak':
        return AchievementType.streak;
      case 'milestone':
        return AchievementType.milestone;
      case 'challenge':
        return AchievementType.challenge;
      case 'personal':
        return AchievementType.personal;
      default:
        return AchievementType.workout;
    }
  }

  static String _getStringFromType(AchievementType type) {
    switch (type) {
      case AchievementType.workout:
        return 'workout';
      case AchievementType.streak:
        return 'streak';
      case AchievementType.milestone:
        return 'milestone';
      case AchievementType.challenge:
        return 'challenge';
      case AchievementType.personal:
        return 'personal';
    }
  }
}
