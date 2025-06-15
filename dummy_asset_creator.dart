import 'dart:io';
import 'package:flutter/material.dart';

/// Utility class to create dummy asset files when needed
class DummyAssetCreator {
  /// Check if required asset directories exist and create them if they don't
  static Future<void> ensureAssetDirectoriesExist() async {
    try {
      // Create directories if they don't exist
      await Directory('assets/images').create(recursive: true);
      await Directory('assets/videos').create(recursive: true);

      debugPrint('Asset directories created successfully');
    } catch (e) {
      debugPrint('Error creating asset directories: $e');
    }
  }

  /// Create a dummy video file if no videos are available
  static Future<void> createDummyVideo() async {
    try {
      final videoFile = File('assets/videos/default_workout.mp4');
      if (!await videoFile.exists()) {
        // Create an empty file as a placeholder
        await videoFile.writeAsBytes([]);
        debugPrint('Created dummy video file');
      }
    } catch (e) {
      debugPrint('Error creating dummy video: $e');
    }
  }

  /// Create dummy image files for workouts
  static Future<void> createDummyImages() async {
    try {
      final categories = [
        'cardio',
        'yoga',
        'hiit',
        'strength',
        'core',
        'full_body',
        'fitness_default'
      ];

      for (final category in categories) {
        final imageFile = File('assets/images/$category.jpeg');
        if (!await imageFile.exists()) {
          // Create an empty file as a placeholder
          await imageFile.writeAsBytes([]);
          debugPrint('Created dummy image for $category');
        }
      }

      // Create the actual used image files
      final usedImages = [
        'fitnessphoto.jpeg',
        'fitnessphoto1.jpeg',
        'fitness3.jpeg',
        'fintessphoto2.jpeg'
      ];

      for (final imageName in usedImages) {
        final imageFile = File('assets/images/$imageName');
        if (!await imageFile.exists()) {
          // Create an empty file as a placeholder
          await imageFile.writeAsBytes([]);
          debugPrint('Created dummy image file: $imageName');
        }
      }
    } catch (e) {
      debugPrint('Error creating dummy images: $e');
    }
  }
}
