import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/workout_tracker_service.dart';
import '../../widgets/premium_background.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final WorkoutTrackerService _trackerService = WorkoutTrackerService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _workoutHistory = [];
  Map<String, dynamic> _workoutStats = {};
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'week', 'month', 'year'];

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    setState(() => _isLoading = true);

    try {
      final history = await _trackerService.getWorkoutHistory();
      final stats = await _trackerService.getWorkoutStats();

      if (mounted) {
        setState(() {
          _workoutHistory = _filterWorkoutHistory(history, _selectedFilter);
          _workoutStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading workout history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _filterWorkoutHistory(
    List<Map<String, dynamic>> history,
    String filter,
  ) {
    if (filter == 'all' || history.isEmpty) {
      return history;
    }

    final now = DateTime.now();
    late DateTime cutoffDate;

    switch (filter) {
      case 'week':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        cutoffDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'year':
        cutoffDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        return history;
    }

    return history.where((workout) {
      final completedAt = DateTime.parse(workout['completedAt']);
      return completedAt.isAfter(cutoffDate);
    }).toList();
  }

  void _changeFilter(String filter) {
    if (_selectedFilter == filter) return;

    setState(() {
      _selectedFilter = filter;
      _workoutHistory = _filterWorkoutHistory(_workoutHistory, filter);
    });
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final today = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today at ${DateFormat.jm().format(date)}';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday at ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat.yMMMd().add_jm().format(date);
    }
  }

  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final remainingSeconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours hr ${minutes.toString().padLeft(2, '0')} min';
    } else {
      return '$minutes min ${remainingSeconds.toString().padLeft(2, '0')} sec';
    }
  }

  Color _getCategoryColor(String categoryName) {
    const defaultColor = Colors.blueGrey;

    final Map<String, Color> categoryColors = {
      'chest': Colors.redAccent,
      'back': Colors.purpleAccent,
      'arms': Colors.blueAccent,
      'legs': Colors.orangeAccent,
      'shoulders': Colors.greenAccent,
      'core': Colors.tealAccent,
      'cardio': Colors.pinkAccent,
      'yoga': Colors.indigoAccent,
      'hiit': Colors.deepOrangeAccent,
    };

    return categoryColors[categoryName.toLowerCase()] ?? defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          PremiumBackground(
            startColor: theme.colorScheme.primary,
            endColor: theme.colorScheme.primary.withOpacity(0.7),
            child: const SizedBox.expand(),
          ),

          // Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 120,
                  backgroundColor: theme.colorScheme.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Workout History',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadWorkoutData,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),

                // Filter chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter workouts:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ..._filters.map((filter) {
                                final isSelected = _selectedFilter == filter;
                                String label;

                                switch (filter) {
                                  case 'all':
                                    label = 'All Time';
                                    break;
                                  case 'week':
                                    label = 'This Week';
                                    break;
                                  case 'month':
                                    label = 'This Month';
                                    break;
                                  case 'year':
                                    label = 'This Year';
                                    break;
                                  default:
                                    label = filter;
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: FilterChip(
                                    backgroundColor: theme.colorScheme.surface,
                                    selectedColor: theme.colorScheme.primary,
                                    selected: isSelected,
                                    showCheckmark: false,
                                    label: Text(label),
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : null,
                                      fontWeight:
                                          isSelected ? FontWeight.bold : null,
                                    ),
                                    onSelected: (_) => _changeFilter(filter),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats at a glance
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: HDCardBackground(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.insert_chart,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Workout Stats',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_isLoading)
                              const Center(
                                child: CircularProgressIndicator(),
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatItem(
                                      'Total Workouts',
                                      (_workoutStats['totalWorkouts'] ?? 0)
                                          .toString(),
                                      Icons.fitness_center,
                                      theme,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildStatItem(
                                      'Total Minutes',
                                      (_workoutStats['totalDuration'] ?? 0)
                                          .toString(),
                                      Icons.timer,
                                      theme,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildStatItem(
                                      'Calories Burned',
                                      (_workoutStats['totalCaloriesBurned'] ??
                                              0)
                                          .toString(),
                                      Icons.local_fire_department,
                                      theme,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Workout history list
                if (_isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_workoutHistory.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No workout history found',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete a workout to see it here',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final workout = _workoutHistory[index];
                          final categoryName =
                              workout['categoryName'] ?? 'Unknown';
                          final completedAt = workout['completedAt'] ??
                              DateTime.now().toIso8601String();
                          final duration = workout['duration'] ?? 0;
                          final caloriesBurned = workout['caloriesBurned'] ?? 0;
                          final notes = workout['notes'];
                          final difficulty = workout['difficulty'] ?? 'Unknown';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: HDCardBackground(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color:
                                                _getCategoryColor(categoryName)
                                                    .withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.fitness_center,
                                            color:
                                                _getCategoryColor(categoryName),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                categoryName,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                _formatDate(completedAt),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Chip(
                                          label: Text(
                                            difficulty.split('.').last,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor: difficulty
                                                  .toLowerCase()
                                                  .contains('beginner')
                                              ? Colors.green
                                              : difficulty
                                                      .toLowerCase()
                                                      .contains('intermediate')
                                                  ? Colors.orange
                                                  : Colors.red,
                                          labelStyle: const TextStyle(
                                              color: Colors.white),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            const Icon(Icons.timer, size: 20),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDuration(duration),
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Icon(
                                                Icons.local_fire_department,
                                                size: 20),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$caloriesBurned cal',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (notes != null &&
                                        notes.toString().isNotEmpty) ...[
                                      const Divider(height: 24),
                                      Text(
                                        'Notes:',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notes.toString(),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(
                                    duration: 300.ms, delay: (index * 50).ms)
                                .slideY(
                                    begin: 0.1,
                                    end: 0,
                                    duration: 300.ms,
                                    delay: (index * 50).ms),
                          );
                        },
                        childCount: _workoutHistory.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
