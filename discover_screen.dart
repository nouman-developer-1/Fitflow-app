import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../workouts/workout_details_screen.dart';
import '../../models/workout_category.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Short',
    'Long'
  ];

  final List<Map<String, dynamic>> _workouts = [
    {
      'name': 'Chest Workout',
      'category': 'Chest',
      'duration': '35 min',
      'difficulty': 'Intermediate',
      'calories': '350 cal',
      'image': 'assets/images/fitnessphoto.jpeg',
    },
    {
      'name': 'Arms Builder',
      'category': 'Arms',
      'duration': '25 min',
      'difficulty': 'Beginner',
      'calories': '220 cal',
      'image': 'assets/images/fitnessphoto1.jpeg',
    },
    {
      'name': 'Back Strengthening',
      'category': 'Back',
      'duration': '40 min',
      'difficulty': 'Advanced',
      'calories': '400 cal',
      'image': 'assets/images/fitness3.jpeg',
    },
    {
      'name': 'Leg Day Routine',
      'category': 'Legs',
      'duration': '45 min',
      'difficulty': 'Intermediate',
      'calories': '450 cal',
      'image': 'assets/images/fintessphoto2.jpeg',
    },
    {
      'name': 'Shoulder Blaster',
      'category': 'Shoulders',
      'duration': '30 min',
      'difficulty': 'Advanced',
      'calories': '320 cal',
      'image': 'assets/images/Fitness Gym Instagram Post.png',
    },
    {
      'name': 'Quick Triceps Routine',
      'category': 'Triceps',
      'duration': '20 min',
      'difficulty': 'Beginner',
      'calories': '180 cal',
      'image': 'assets/images/Gym Fitness.png',
    },
  ];

  List<Map<String, dynamic>> get _filteredWorkouts {
    return _workouts.where((workout) {
      // First check if workout matches search query
      final matchesQuery =
          workout['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              workout['category']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());

      // Then check if it matches the filter
      bool matchesFilter = true;
      if (_selectedFilter != 'All') {
        if (_selectedFilter == 'Short') {
          matchesFilter = int.parse(workout['duration'].split(' ')[0]) <= 30;
        } else if (_selectedFilter == 'Long') {
          matchesFilter = int.parse(workout['duration'].split(' ')[0]) > 30;
        } else {
          matchesFilter = workout['difficulty'] == _selectedFilter;
        }
      }

      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Discover Workouts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search workouts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final delay = index * 0.2;
                      final value = math.max(0.0,
                          math.min(1.0, _animationController.value - delay));

                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            checkmarkColor:
                                Theme.of(context).colorScheme.primary,
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredWorkouts.isEmpty
                ? const Center(
                    child: Text(
                      'No workouts found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = _filteredWorkouts[index];

                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final startPosition = 0.2 + (index * 0.1);
                          final animationValue = math.max(
                              0.0,
                              math.min(
                                  1.0,
                                  (_animationController.value - startPosition) *
                                      2));

                          return Transform.translate(
                            offset: Offset(0, 20.0 * (1.0 - animationValue)),
                            child: Opacity(
                              opacity: animationValue,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: DiscoverWorkoutCard(workout: workout),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DiscoverWorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;

  const DiscoverWorkoutCard({
    super.key,
    required this.workout,
  });

  void _navigateToWorkoutDetails(BuildContext context) {
    // Create a WorkoutCategory object from the workout map
    final workoutCategory = WorkoutCategory(
      name: workout['name'],
      icon: Icons.fitness_center, // Default icon
      color: _getDifficultyColor(workout['difficulty']),
      description:
          'Detailed workout program to help you reach your fitness goals.',
      exercises: [], // Empty exercises list as we don't have that data in the map
      difficulty: _getDifficultyFromString(workout['difficulty']),
      estimatedDurationMinutes: _getDurationMinutes(workout['duration']),
      estimatedCaloriesBurn: _getCalories(workout['calories']),
      videoPath: 'default_workout', // Default video path
      imagePath: workout['image'],
      targetMuscleGroups: [],
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutDetailsScreen(
          workoutCategory: workoutCategory,
        ),
      ),
    );
  }

  // Helper method to convert difficulty string to DifficultyLevel enum
  DifficultyLevel _getDifficultyFromString(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return DifficultyLevel.beginner;
      case 'intermediate':
        return DifficultyLevel.intermediate;
      case 'advanced':
        return DifficultyLevel.advanced;
      default:
        return DifficultyLevel.beginner;
    }
  }

  // Helper method to extract minutes from duration string (e.g., "30 mins" -> 30)
  int _getDurationMinutes(String duration) {
    // Extract numbers from string
    final RegExp regex = RegExp(r'\d+');
    final match = regex.firstMatch(duration);
    if (match != null) {
      return int.tryParse(match.group(0) ?? '30') ?? 30;
    }
    return 30; // Default to 30 minutes
  }

  // Helper method to extract calories from string (e.g., "250 cal" -> 250)
  int _getCalories(String calories) {
    // Extract numbers from string
    final RegExp regex = RegExp(r'\d+');
    final match = regex.firstMatch(calories);
    if (match != null) {
      return int.tryParse(match.group(0) ?? '200') ?? 200;
    }
    return 200; // Default to 200 calories
  }

  Color _getDifficultyColor(String difficulty) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                workout['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      workout['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(workout['difficulty']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        workout['difficulty'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  workout['category'],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      workout['duration'],
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      workout['calories'],
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _navigateToWorkoutDetails(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Start Workout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
