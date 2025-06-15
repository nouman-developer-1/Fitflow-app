import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import '../../widgets/premium_background.dart';
import '../../utils/asset_resolver.dart';
import '../../utils/ui_helper.dart';
import '../workouts/workout_completion_screen.dart';
import '../../models/workout_category.dart';
import '../../services/video_cache_service.dart';

class WorkoutVideoScreen extends StatefulWidget {
  final String title;
  final String videoPath;
  final String category;

  const WorkoutVideoScreen({
    super.key,
    required this.title,
    required this.videoPath,
    this.category = 'default',
  });

  @override
  State<WorkoutVideoScreen> createState() => _WorkoutVideoScreenState();
}

class _WorkoutVideoScreenState extends State<WorkoutVideoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  // ignore: unused_field
  bool _isFullScreen = false;  // Used in routePageBuilder for fullscreen mode
  bool _usingNetworkFallback = false;
  final _videoCacheService = VideoCacheService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));

    _scaleAnimation =
        Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();

    // Apply immersive UI for video
    UIHelper.setImmersiveUI(isDark: true);

    _initializePlayer();
  }

  @override
  void dispose() {
    // Restore UI based on current theme when leaving the screen
    final themeMode = Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    UIHelper.updateSystemUIForTheme(themeMode);

    _animationController.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    setState(() => _isLoading = true);

    try {
      String resolvedPath = widget.videoPath.startsWith('assets/')
          ? widget.videoPath
          : AssetResolver.resolveVideoPath(widget.videoPath);

      debugPrint('Attempting to load video from path: $resolvedPath');

      // Get cached path if it's a network video
      resolvedPath = await _videoCacheService.getVideoPath(resolvedPath);

      // First try: load the specified video
      try {
        _videoPlayerController = resolvedPath.startsWith('assets/')
            ? VideoPlayerController.asset(resolvedPath)
            : VideoPlayerController.file(File(resolvedPath));
            
        await _videoPlayerController!.initialize();
        debugPrint('Video loaded successfully from: $resolvedPath');
      } catch (e) {
        debugPrint('Error loading primary video: $e');

        // Second try: Check for a category-specific fallback
        final categoryPath = AssetResolver.resolveVideoPath(widget.category);
        if (categoryPath != resolvedPath) {
          try {
            debugPrint('Trying category fallback: $categoryPath');
            _videoPlayerController?.dispose();
            _videoPlayerController = VideoPlayerController.asset(categoryPath);
            await _videoPlayerController!.initialize();
            debugPrint('Category fallback video loaded successfully');
          } catch (e) {
            debugPrint('Error loading category fallback: $e');

            // Third try: Use one of the specific workout videos
            try {
              final specificVideos = [
                'assets/videos/10 Best Effective Exercises To Build A Perfect Chest.mp4',
                'assets/videos/14 Best Workout To Get Big And Perfect Arms.mp4',
                'assets/videos/6 Exercises To Build Bigger Back - Back Workout.mp4',
              ];

              for (final specificVideo in specificVideos) {
                try {
                  debugPrint('Trying specific video: $specificVideo');
                  _videoPlayerController?.dispose();
                  _videoPlayerController =
                      VideoPlayerController.asset(specificVideo);
                  await _videoPlayerController!.initialize();
                  debugPrint('Specific video loaded successfully');
                  break;
                } catch (specificError) {
                  debugPrint('Error loading specific video: $specificError');
                  continue;
                }
              }

              // If we're here and controller is still not initialized, try network fallback
              if (_videoPlayerController == null ||
                  !_videoPlayerController!.value.isInitialized) {
                throw Exception('Failed to load any local video');
              }
            } catch (specificError) {
              // Final try: Use network fallback
              debugPrint('Trying network fallback...');
              final networkUrl =
                  AssetResolver.getFallbackNetworkVideo(widget.category);
              _videoPlayerController?.dispose();
              _videoPlayerController =
                  VideoPlayerController.network(networkUrl);
              await _videoPlayerController!.initialize();
              _usingNetworkFallback = true;
              debugPrint('Network fallback video loaded successfully');
            }
          }
        } else {
          // If category path is the same as the original path that failed, go straight to network
          debugPrint('Trying network fallback directly...');
          final networkUrl =
              AssetResolver.getFallbackNetworkVideo(widget.category);
          _videoPlayerController?.dispose();
          _videoPlayerController = VideoPlayerController.network(networkUrl);
          await _videoPlayerController!.initialize();
          _usingNetworkFallback = true;
          debugPrint('Network fallback video loaded successfully');
        }
      }

      // If we've made it here, we have a working video player
      final screenSize = MediaQuery.of(context).size;
      final isSmallScreen = screenSize.width < 400;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: isSmallScreen
            ? 16 / 9 // Force 16:9 aspect for small screens
            : _videoPlayerController!.value.aspectRatio,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Error playing video: $errorMessage',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _initializePlayer,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        },
        placeholder: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              const Text('Preparing your workout video...'),
            ],
          ),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).colorScheme.secondary,
          handleColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          bufferedColor:
              Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        ),
        fullScreenByDefault: false,
        routePageBuilder: (context, animation, secondaryAnimation, child) {
          _isFullScreen = true;
          // Apply immersive UI when entering fullscreen
          UIHelper.setImmersiveUI(isDark: true);

          animation.addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              _isFullScreen = false;
              // Restore UI based on theme when exiting fullscreen
              final themeMode = Theme.of(context).brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light;
              UIHelper.updateSystemUIForTheme(themeMode);
            }
          });

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) => Scaffold(
              body: Container(
                alignment: Alignment.center,
                color: Colors.black,
                child: child,
              ),
            ),
            child: child,
          );
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // HD Background
          PremiumBackground(
            startColor: theme.colorScheme.primary,
            endColor: theme.colorScheme.primary.withOpacity(0.7),
            useDarkOverlay: true,
            child: const SizedBox.expand(),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () => _showVideoSettingsDialog(),
                      ),
                    ],
                  ),
                ),

                // Video section
                if (_isLoading)
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Loading workout video...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (_hasError)
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: HDCardBackground(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red, size: 64),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Failed to load video',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _hasError = false;
                                            _isLoading = true;
                                          });
                                          _initializePlayer();
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Try Again'),
                                      ),
                                      const SizedBox(width: 16),
                                      OutlinedButton.icon(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.arrow_back),
                                        label: const Text('Go Back'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (_chewieController != null)
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Chewie(controller: _chewieController!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text('No video available',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),

                // Video info card at bottom
                if (!_isLoading && !_hasError && _chewieController != null)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: HDCardBackground(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Workout Tips',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    if (_usingNetworkFallback)
                                      const Spacer()
                                    else
                                      const SizedBox.shrink(),
                                    if (_usingNetworkFallback)
                                      Chip(
                                        label: const Text('Network Video'),
                                        avatar:
                                            const Icon(Icons.cloud, size: 14),
                                        backgroundColor: theme
                                            .colorScheme.secondary
                                            .withOpacity(0.2),
                                        labelStyle: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Focus on proper form rather than speed',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Keep breathing throughout the exercises',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Complete all exercises for maximum results',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      _chewieController?.enterFullScreen();
                                    },
                                    icon: const Icon(Icons.fullscreen),
                                    label: const Text('WATCH FULLSCREEN'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !_isLoading &&
              !_hasError &&
              _chewieController != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FloatingActionButton(
                    heroTag: 'play_pause',
                    onPressed: () {
                      if (_videoPlayerController!.value.isPlaying) {
                        _videoPlayerController!.pause();
                      } else {
                        _videoPlayerController!.play();
                      }
                      setState(() {});
                    },
                    child: Icon(
                      _videoPlayerController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FloatingActionButton.extended(
                    heroTag: 'complete',
                    onPressed: () {
                      // Calculate approximate calories burned based on video duration
                      final int durationMinutes =
                          (_videoPlayerController!.value.duration.inSeconds / 60)
                              .round();

                      // Estimate calories - this would ideally be based on user's weight/height/age
                      int estimatedCalories = 0;

                      // Use category's estimated calories if possible
                      if (widget.category == 'cardio') {
                        estimatedCalories = durationMinutes * 10;
                      } else if (widget.category == 'hiit') {
                        estimatedCalories = durationMinutes * 12;
                      } else if (widget.category == 'yoga') {
                        estimatedCalories = durationMinutes * 6;
                      } else if (widget.category == 'strength') {
                        estimatedCalories = durationMinutes * 8;
                      } else {
                        // Default estimator
                        estimatedCalories = durationMinutes * 7;
                      }

                      // Get a WorkoutCategory instance by name
                      final categoryList = WorkoutCategory.getAllCategories();
                      WorkoutCategory? workoutCategory;

                      for (final category in categoryList) {
                        if (category.name.toLowerCase() ==
                            widget.category.toLowerCase()) {
                          workoutCategory = category;
                          break;
                        }
                      }

                      // Fallback to first category if none found
                      workoutCategory ??= categoryList.first;

                      // Navigate to workout completion screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WorkoutCompletionScreen(
                            category: workoutCategory!,
                            duration: _videoPlayerController!.value.duration,
                            caloriesBurned: estimatedCalories,
                          ),
                        ),
                      );
                    },
                    backgroundColor: Colors.green,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('COMPLETE'),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  void _showVideoSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Playback Speed'),
              subtitle: const Text('Adjust video speed'),
              onTap: () {
                Navigator.pop(context);
                _showPlaybackSpeedDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.fit_screen),
              title: const Text('Full Screen'),
              subtitle: const Text('Toggle fullscreen mode'),
              onTap: () {
                Navigator.pop(context);
                _chewieController?.enterFullScreen();
              },
            ),
            if (_videoPlayerController != null) ...[
              const Divider(),
              ListTile(
                leading: Icon(
                  _videoPlayerController!.value.volume > 0
                      ? Icons.volume_up
                      : Icons.volume_off,
                ),
                title: const Text('Toggle Mute'),
                subtitle: Text(_videoPlayerController!.value.volume > 0
                    ? 'Currently: Unmuted'
                    : 'Currently: Muted'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    if (_videoPlayerController!.value.volume > 0) {
                      _videoPlayerController!.setVolume(0);
                    } else {
                      _videoPlayerController!.setVolume(1.0);
                    }
                  });
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showPlaybackSpeedDialog() {
    if (_videoPlayerController == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('0.5x'),
              onTap: () {
                _videoPlayerController!.setPlaybackSpeed(0.5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Normal (1x)'),
              onTap: () {
                _videoPlayerController!.setPlaybackSpeed(1.0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('1.5x'),
              onTap: () {
                _videoPlayerController!.setPlaybackSpeed(1.5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('2x'),
              onTap: () {
                _videoPlayerController!.setPlaybackSpeed(2.0);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
