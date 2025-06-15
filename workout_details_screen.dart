import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../models/workout_category.dart';
import 'workout_video_screen.dart';
import '../../services/achievement_service.dart';
import '../../screens/achievements/achievements_screen.dart';
import '../../widgets/optimized_background.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final WorkoutCategory workoutCategory;

  const WorkoutDetailsScreen({
    super.key,
    required this.workoutCategory,
  });

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _isPlayingVideo = false;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.workoutCategory.videoPath != null) {
      try {
        String videoAsset =
            'assets/videos/${widget.workoutCategory.videoPath}.mp4';
        _videoPlayerController = VideoPlayerController.asset(videoAsset);
        await _videoPlayerController!.initialize();
        setState(() {
          _isVideoInitialized = true;
        });
      } catch (e) {
        debugPrint('Error initializing video: $e');
        // Fall back to default video
        try {
          _videoPlayerController = VideoPlayerController.asset(
              'assets/Videos/10 Best Effective Exercises To Build A Perfect Chest.mp4');
          await _videoPlayerController!.initialize();
          setState(() {
            _isVideoInitialized = true;
          });
        } catch (e) {
          debugPrint('Error initializing default video: $e');
          setState(() {
            _isVideoInitialized = false;
          });
        }
      }
    }
  }

  // Record completed workout
  Future<void> _markWorkoutComplete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Record workout completion in the achievement service
      final achievementService = AchievementService();
      await achievementService.recordWorkoutCompletion(widget.workoutCategory);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Workout completed!'),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AchievementsScreen(),
                    ),
                  );
                },
                child: const Text('VIEW ACHIEVEMENTS'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint('Error recording workout completion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to record workout completion.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _toggleVideo() {
    setState(() {
      _isPlayingVideo = !_isPlayingVideo;
      if (_isPlayingVideo) {
        _videoPlayerController?.play();
      } else {
        _videoPlayerController?.pause();
      }
    });
  }

  // Get color based on difficulty level
  Color _getDifficultyColor(BuildContext context) {
    final theme = Theme.of(context);

    switch (widget.workoutCategory.difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  void _navigateToWorkoutVideoScreen() {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutVideoScreen(
            title: widget.workoutCategory.name,
            videoPath: widget.workoutCategory.videoPath ?? 'default_workout',
            category: widget.workoutCategory.name.toLowerCase(),
          ),
        ),
      );
    } catch (e) {
      // Show a helpful error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Error loading workout video. Please try another workout.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            floating: false,
            backgroundColor: widget.workoutCategory.color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.workoutCategory.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image with gradient overlay
                  OptimizedImage(
                    imagePath: widget.workoutCategory.resolvedImagePath,
                    applyDarkGradient: true,
                  ),
                  // Play button for video
                  if (widget.workoutCategory.hasVideo)
                    Positioned.fill(
                      child: Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => WorkoutVideoScreen(
                                    title: widget.workoutCategory.name,
                                    videoPath:
                                        widget.workoutCategory.videoPath!,
                                    category: widget.workoutCategory.name
                                        .toLowerCase(),
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(40),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            )
                                .animate()
                                .scale(
                                  duration: 600.ms,
                                  curve: Curves.elasticOut,
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1.0, 1.0),
                                )
                                .shimmer(
                                  duration: 1200.ms,
                                  color: Colors.white.withOpacity(0.5),
                                  delay: 500.ms,
                                ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Workout metadata cards
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              _buildInfoCard(
                                Icons.trending_up,
                                'Difficulty',
                                _getDifficultyText(
                                    widget.workoutCategory.difficulty),
                              ),
                              _buildInfoCard(
                                Icons.timer,
                                'Duration',
                                _getFormattedDuration(widget
                                    .workoutCategory.estimatedDurationMinutes),
                              ),
                              _buildInfoCard(
                                Icons.local_fire_department,
                                'Calories',
                                '${widget.workoutCategory.estimatedCaloriesBurn} cal',
                              ),
                            ],
                          ),
                        ),

                        // Workout description
                        Text(
                          'About this workout',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.workoutCategory.description,
                          style: theme.textTheme.bodyMedium,
                        ),

                        // Target muscle groups
                        if (widget
                            .workoutCategory.targetMuscleGroups.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Target Muscle Groups',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.workoutCategory.targetMuscleGroups
                                .map((muscle) {
                              return Chip(
                                backgroundColor:
                                    theme.colorScheme.primary.withOpacity(0.15),
                                label: Text(muscle),
                                avatar:
                                    const Icon(Icons.fitness_center, size: 16),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Tab bar for exercises
                  TabBar(
                    controller: _tabController,
                    labelColor: theme.colorScheme.primary,
                    indicatorColor: theme.colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Exercises'),
                      Tab(text: 'Instructions'),
                      Tab(text: 'Tips'),
                    ],
                  ),
                  SizedBox(
                    height: isTablet
                        ? 600
                        : MediaQuery.of(context).size.height * 0.6,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Exercises tab
                        _buildExercisesList(theme),

                        // Instructions tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How to perform this workout',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInstructionStep(
                                1,
                                'Warm up',
                                'Start with 5 minutes of light cardio and dynamic stretching to prepare your muscles.',
                                Icons.favorite,
                              ),
                              _buildInstructionStep(
                                2,
                                'Complete the circuit',
                                'Perform each exercise in order with minimal rest between exercises.',
                                Icons.loop,
                              ),
                              _buildInstructionStep(
                                3,
                                'Rest between sets',
                                'Take 1-2 minutes rest between completing all exercises (one full circuit).',
                                Icons.hourglass_bottom,
                              ),
                              _buildInstructionStep(
                                4,
                                'Stay hydrated',
                                'Drink water between sets to stay properly hydrated throughout your workout.',
                                Icons.water_drop,
                              ),
                              _buildInstructionStep(
                                5,
                                'Cool down',
                                'Finish with 5-10 minutes of static stretching to improve flexibility and recovery.',
                                Icons.accessibility_new,
                              ),
                            ],
                          ),
                        ),

                        // Tips tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tips for better results',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTipItem(
                                'Focus on form',
                                'Always prioritize proper form over weight or speed to prevent injuries and maximize results.',
                                Icons.fitness_center,
                              ),
                              _buildTipItem(
                                'Progressive overload',
                                'Gradually increase the weight, reps, or intensity over time to continue seeing improvements.',
                                Icons.trending_up,
                              ),
                              _buildTipItem(
                                'Track your progress',
                                'Keep a workout journal or use the app to track your progress and stay motivated.',
                                Icons.edit_note,
                              ),
                              _buildTipItem(
                                'Nutrition matters',
                                'Pair your workout routine with proper nutrition for optimal results and recovery.',
                                Icons.restaurant,
                              ),
                              _buildTipItem(
                                'Recovery is key',
                                'Ensure adequate rest between workouts to allow your muscles to recover and grow stronger.',
                                Icons.bedtime,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildActionButtons(),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _getDifficultyColor(context),
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _navigateToWorkoutVideoScreen,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Workout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _markWorkoutComplete,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onSecondary,
                        strokeWidth: 2,
                      ))
                  : const Icon(Icons.check_circle),
              label: Text(_isLoading ? 'Saving...' : 'Complete'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.workoutCategory.exercises.length,
      itemBuilder: (context, index) {
        final exercise = widget.workoutCategory.exercises[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise image
              if (exercise.imagePath != null)
                AspectRatioImage(
                  imagePath: exercise.imagePath!,
                  aspectRatio: 16 / 9,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  applyDarkGradient: false,
                ),

              // Exercise details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      exercise.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Sets and reps
                    Row(
                      children: [
                        Icon(
                          Icons.repeat,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${exercise.sets} sets × ${exercise.reps}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Description
                    if (exercise.description.isNotEmpty)
                      Text(
                        exercise.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: (50 * index).ms).slideY(
                begin: 0.1,
                end: 0,
                duration: 400.ms,
                delay: (50 * index).ms,
                curve: Curves.easeOutQuad,
              ),
        );
      },
    );
  }

  Widget _buildInstructionStep(
    int step,
    String title,
    String description,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon,
                        color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  // Get difficulty text from enum
  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      default:
        return 'Intermediate';
    }
  }

  // Get formatted duration
  String _getFormattedDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return hours > 0
          ? '${hours}h ${remainingMinutes > 0 ? '${remainingMinutes}m' : ''}'
          : '$minutes min';
    }
  }
}
