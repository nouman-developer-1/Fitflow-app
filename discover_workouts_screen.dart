import 'package:flutter/material.dart';
import 'package:fitflow/config/theme_config.dart';
import 'package:fitflow/models/workout_category.dart';
import 'package:fitflow/screens/workouts/workout_details_screen.dart';
import 'package:fitflow/widgets/optimized_background.dart';

class DiscoverWorkoutsScreen extends StatefulWidget {
  const DiscoverWorkoutsScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverWorkoutsScreen> createState() => _DiscoverWorkoutsScreenState();
}

class _DiscoverWorkoutsScreenState extends State<DiscoverWorkoutsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  List<WorkoutCategory> _allWorkouts = [];
  List<WorkoutCategory> _filteredWorkouts = [];
  bool _isLoading = true;

  final List<String> _difficultyFilters = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadWorkouts() {
    setState(() => _isLoading = true);

    // Get workouts from model
    final workouts = WorkoutCategory.getAllCategories();

    setState(() {
      _allWorkouts = workouts;
      _filteredWorkouts = workouts;
      _isLoading = false;
    });
  }

  void _filterWorkouts(String difficulty) {
    setState(() {
      _selectedFilter = difficulty;

      if (difficulty == 'All') {
        _filteredWorkouts = _allWorkouts;
      } else {
        _filteredWorkouts = _allWorkouts
            .where((workout) =>
                workout.difficulty.toString().toLowerCase() ==
                difficulty.toLowerCase())
            .toList();
      }
    });
  }

  void _searchWorkouts(String query) {
    if (query.isEmpty) {
      _filterWorkouts(_selectedFilter);
      return;
    }

    final searchResults = _allWorkouts.where((workout) {
      final nameMatch =
          workout.name.toLowerCase().contains(query.toLowerCase());
      final descMatch =
          workout.description?.toLowerCase().contains(query.toLowerCase()) ??
              false;
      final targetMatch = workout.targetMuscleGroups
          .any((muscle) => muscle.toLowerCase().contains(query.toLowerCase()));

      return nameMatch || descMatch || targetMatch;
    }).toList();

    setState(() {
      _filteredWorkouts = searchResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: ThemeConfig.secondaryColor,
      appBar: AppBar(
        backgroundColor: ThemeConfig.secondaryColor,
        elevation: 0,
        title: Text(
          'Discover Workouts',
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    _buildSearchBar(),
                    const SizedBox(height: 16),

                    // Filters
                    _buildFilters(),
                    const SizedBox(height: 16),

                    // Workout list
                    Expanded(
                      child: _filteredWorkouts.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              padding:
                                  EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: size.width > 600 ? 3 : 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: _filteredWorkouts.length,
                              itemBuilder: (context, index) {
                                final workout = _filteredWorkouts[index];
                                return _buildWorkoutCard(workout);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: ThemeConfig.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchWorkouts,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search workouts...',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _difficultyFilters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => _filterWorkouts(filter),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ThemeConfig.primaryColor
                      : ThemeConfig.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutCategory workout) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return GestureDetector(
      onTap: () => _navigateToWorkoutDetails(workout),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeConfig.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with difficulty label
            Expanded(
              flex: 3,
              child: AspectRatioImage(
                imagePath: workout.imagePath ??
                    'assets/images/workouts/default_workout.jpg',
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                applyDarkGradient: true,
                overlayChild: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      workout.difficulty.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Workout details
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      workout.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Duration and calories
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${workout.estimatedDurationMinutes} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.local_fire_department,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${workout.estimatedCaloriesBurn} cal',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    // Target muscles
                    if (workout.targetMuscleGroups.isNotEmpty)
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            workout.targetMuscleGroups.first,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: ThemeConfig.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or filter',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToWorkoutDetails(WorkoutCategory workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutDetailsScreen(
          workoutCategory: workout,
        ),
      ),
    );
  }
}
