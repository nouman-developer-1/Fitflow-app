import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class to resolve asset paths and handle missing assets
class AssetResolver {
  /// Maps short video paths to actual asset paths
  static String resolveVideoPath(String? videoPath) {
    // If videoPath is null, return a default path
    if (videoPath == null) {
      debugPrint('AssetResolver: Null video path provided, using default');
      return 'assets/Videos/10 Best Effective Exercises To Build A Perfect Chest.mp4';
    }

    // If the path already includes 'assets/', return it as is
    if (videoPath.startsWith('assets/')) {
      return videoPath;
    }

    // Default mapping for video paths - using the user's properly categorized workout videos
    final Map<String, String> videoPathMap = {
      'cardio':
          'assets/Videos/7 BEST LEG EXERCISES TO GET WIDE THIGH WORKOUT !🎯.mp4',
      'yoga': 'assets/Videos/14 Best Workout To Get Big And Perfect Arms.mp4',
      'hiit': 'assets/Videos/9 Exercise For Bigger SHOULDER AND TRAPS.mp4',
      'strength':
          'assets/Videos/6 Exercises To Build Bigger Back - Back Workout.mp4',
      'core':
          'assets/Videos/TRICEPS Exercises WITH DUMBBELLS AT HOME AND GYM.mp4',
      'chest':
          'assets/Videos/10 Best Effective Exercises To Build A Perfect Chest.mp4',
      'back':
          'assets/Videos/6 Exercises To Build Bigger Back - Back Workout.mp4',
      'arms': 'assets/Videos/14 Best Workout To Get Big And Perfect Arms.mp4',
      'legs':
          'assets/Videos/7 BEST LEG EXERCISES TO GET WIDE THIGH WORKOUT !🎯.mp4',
      'shoulders': 'assets/Videos/9 Exercise For Bigger SHOULDER AND TRAPS.mp4',
      'full_body':
          'assets/Videos/10 Best Effective Exercises To Build A Perfect Chest.mp4',
    };

    // Return mapped path or fallback to a default
    final String resolvedPath = videoPathMap[videoPath.toLowerCase()] ??
        'assets/Videos/10 Best Effective Exercises To Build A Perfect Chest.mp4';

    if (!videoPathMap.containsKey(videoPath.toLowerCase())) {
      debugPrint(
          'AssetResolver: Unknown video category "$videoPath", using default');
    }

    return resolvedPath;
  }

  /// Network URLs for fallback videos when local assets aren't available
  static final Map<String, String> networkFallbackVideos = {
    'default':
        'assets/Videos/10 Best Effective Exercises To Build A Perfect Chest.mp4',
    'cardio':
        'assets/Videos/7 BEST LEG EXERCISES TO GET WIDE THIGH WORKOUT !🎯.mp4',
    'yoga': 'assets/Videos/14 Best Workout To Get Big And Perfect Arms.mp4',
    'strength':
        'assets/Videos/6 Exercises To Build Bigger Back - Back Workout.mp4',
    'hiit': 'assets/Videos/9 Exercise For Bigger SHOULDER AND TRAPS.mp4',
    'core':
        'assets/Videos/TRICEPS Exercises WITH DUMBBELLS AT HOME AND GYM.mp4',
    'chest':
        'assets/Videos/10 Best Effective Exercises To Build A Perfect Chest.mp4',
    'back': 'assets/Videos/6 Exercises To Build Bigger Back - Back Workout.mp4',
    'arms': 'assets/Videos/14 Best Workout To Get Big And Perfect Arms.mp4',
    'legs':
        'assets/Videos/7 BEST LEG EXERCISES TO GET WIDE THIGH WORKOUT !🎯.mp4',
    'shoulders': 'assets/Videos/9 Exercise For Bigger SHOULDER AND TRAPS.mp4',
  };

  /// Get a fallback network video URL
  static String getFallbackNetworkVideo(String category) {
    final String fallback = networkFallbackVideos[category.toLowerCase()] ??
        networkFallbackVideos['default']!;

    if (!networkFallbackVideos.containsKey(category.toLowerCase())) {
      debugPrint(
          'AssetResolver: No fallback network video for "$category", using default');
    }

    // Now returning local video paths instead of URLs
    return fallback;
  }

  /// Checks if an asset exists
  static Future<bool> checkAssetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      debugPrint('Asset not found: $assetPath');
      return false;
    }
  }

  /// Get a list of available video paths for fallback
  static List<String> getAvailableVideoPaths() {
    return [
      'assets/Videos/10 Best Effective Exercises To Build A Perfect Chest.mp4',
      'assets/Videos/14 Best Workout To Get Big And Perfect Arms.mp4',
      'assets/Videos/6 Exercises To Build Bigger Back - Back Workout.mp4',
      'assets/Videos/7 BEST LEG EXERCISES TO GET WIDE THIGH WORKOUT !🎯.mp4',
      'assets/Videos/9 Exercise For Bigger SHOULDER AND TRAPS.mp4',
      'assets/Videos/TRICEPS Exercises WITH DUMBBELLS AT HOME AND GYM.mp4',
    ];
  }

  /// Resolves image paths for workout categories
  static String resolveImagePath(String? category) {
    if (category == null || category.isEmpty) {
      debugPrint('AssetResolver: Null or empty image category, using default');
      return 'assets/Usersignupand login page pics add/image1.jpeg';
    }

    // Updated mapping for image paths to use workout-specific images that actually exist
    final Map<String, String> imagePathMap = {
      'chest': 'assets/workouts/chest workout pic.jpeg',
      'back': 'assets/workouts/back wokrout pic.jpeg',
      'arms': 'assets/workouts/Arms workout image.jpeg',
      'legs': 'assets/workouts/leg workout pic.jpeg',
      'shoulders': 'assets/workouts/shoulder workouy.jpeg',
      'core': 'assets/workouts/abs wrokout.jpg',
      // Use different images from assets/images for these categories
      'cardio': 'assets/images/fitnessphoto.jpeg',
      'yoga': 'assets/images/fitnessphoto1.jpeg',
      'hiit': 'assets/images/fitness3.jpeg',
      'strength': 'assets/images/fintnsess 4.jpeg',
      'full_body': 'assets/images/Gym Fitness.png',
      'functional': 'assets/images/fintessphoto2.jpeg',
      'profile': 'assets/images/profile_placeholder.jpg',
    };

    final String resolvedPath = imagePathMap[category.toLowerCase()] ??
        'assets/Usersignupand login page pics add/image1.jpeg';

    if (!imagePathMap.containsKey(category.toLowerCase())) {
      debugPrint(
          'AssetResolver: Unknown image category "$category", using default');
    }

    return resolvedPath;
  }

  /// Get network fallback images for categories
  static final Map<String, String> networkFallbackImages = {
    'default': 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
    'cardio': 'https://images.unsplash.com/photo-1594737625785-a6cbdabd333c',
    'yoga': 'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b',
    'hiit': 'https://images.unsplash.com/photo-1599058917212-d750089bc07e',
    'strength': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e',
    'core': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    'full_body': 'https://images.unsplash.com/photo-1518310383802-640c2de311b2',
    'chest': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    'back': 'https://images.unsplash.com/photo-1603287681836-b174ce5074c2',
    'arms': 'https://images.unsplash.com/photo-1590507621108-433608c97823',
    'legs': 'https://images.unsplash.com/photo-1434608519344-49d77a699e1d',
    'shoulders': 'https://images.unsplash.com/photo-1581009137042-c552e485697a',
    'profile': 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5',
    'fitness_background':
        'https://images.unsplash.com/photo-1517838277536-f5f99be501cd',
  };

  /// Get a fallback network image URL
  static String getFallbackNetworkImage(String category) {
    final String fallback = networkFallbackImages[category.toLowerCase()] ??
        networkFallbackImages['default']!;

    if (!networkFallbackImages.containsKey(category.toLowerCase())) {
      debugPrint(
          'AssetResolver: No fallback network image for "$category", using default');
    }

    return fallback;
  }

  /// Attempt to load asset image, fallback to network image
  static Widget getImageWithFallback(
    String localAssetPath,
    String fallbackCategory, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    return Image.asset(
      localAssetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint(
            'AssetResolver: Failed to load local image "$localAssetPath", trying network fallback');
        // Try to load from network
        final networkUrl = getFallbackNetworkImage(fallbackCategory);
        return Image.network(
          networkUrl,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              color: Colors.grey.shade800,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint(
                'AssetResolver: Failed to load network image "$networkUrl", using error widget');
            // If network also fails, show error widget
            if (errorWidget != null) {
              return errorWidget;
            }
            return Container(
              width: width,
              height: height,
              color: Colors.grey.shade800,
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey.shade400,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Pre-cache common images to improve performance
  static Future<void> precacheCommonImages(BuildContext context) async {
    try {
      final commonCategories = [
        'profile',
        'fitness_background',
        'cardio',
        'strength'
      ];

      for (final category in commonCategories) {
        final path = resolveImagePath(category);
        try {
          await precacheImage(AssetImage(path), context);
        } catch (e) {
          debugPrint('AssetResolver: Failed to precache $path: $e');
          // Try to precache network image instead
          final networkUrl = getFallbackNetworkImage(category);
          try {
            await precacheImage(NetworkImage(networkUrl), context);
          } catch (e) {
            debugPrint(
                'AssetResolver: Failed to precache network image too: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('AssetResolver: Error in precaching: $e');
    }
  }

  /// Get a video player with proper error handling for a specific workout category
  static String getWorkoutVideo(String category) {
    final String resolvedPath = resolveVideoPath(category);

    // Verify if the video path exists and log result
    checkAssetExists(resolvedPath).then((exists) {
      debugPrint(
          'Video for $category ${exists ? "exists" : "does not exist"}: $resolvedPath');
    });

    return resolvedPath;
  }
}
