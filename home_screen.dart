import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fitflow/config/theme_config.dart';
import 'package:fitflow/providers/user_provider.dart';
import 'package:fitflow/screens/workouts/workout_details_screen.dart';
import 'package:fitflow/models/workout_category.dart';
import 'package:fitflow/utils/asset_resolver.dart';
import 'package:fitflow/widgets/optimized_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<WorkoutCategory> _featuredWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache common images to avoid jank when they're first displayed
    AssetResolver.precacheCommonImages(context);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load featured workouts - using the static method from WorkoutCategory
      final categories = WorkoutCategory.getAllCategories();

      if (mounted) {
        setState(() {
          _featuredWorkouts = categories;
          _isLoading = false;
        });

        // Start animations
        _animationController.forward();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Navigate to workout details
  void _navigateToWorkoutDetails(String category, String title) {
    // Find the workout category in the list of featured workouts
    final workoutCategory = _featuredWorkouts.firstWhere(
      (workout) =>
          workout.name.toLowerCase() == title.toLowerCase() ||
          workout.name.toLowerCase().contains(category.toLowerCase()),
      orElse: () => WorkoutCategory.createDefaultCategory(category, title),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailsScreen(
          workoutCategory: workoutCategory,
        ),
      ),
    );
  }

  // Navigate to all workouts in a category
  void _navigateToAllWorkouts() {
    Navigator.pushNamed(context, '/discover');
  }

  // Navigate to notifications
  void _navigateToNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications will be implemented in the next update'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Ronald Adrian';
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ThemeConfig.secondaryColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: ThemeConfig.primaryColor))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Header with user info and notifications
                            _buildHeader(userName),
                            const SizedBox(height: 16),

                            // Search bar
                            _buildSearchBar(),
                            const SizedBox(height: 24),

                            // Motivational text
                            _buildMotivationalText(),
                            const SizedBox(height: 20),

                            // Start Workout Button
                            _buildStartWorkoutButton(),
                            const SizedBox(height: 30),

                            // Daily Program Section
                            _buildDailyProgramSection(),
                            const SizedBox(height: 30),

                            // Personal Trainer Section
                            _buildPersonalTrainerSection(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Header with user info and notifications
  Widget _buildHeader(String userName) {
    return Row(
      children: [
        // User profile image
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ThemeConfig.primaryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: AssetResolver.getImageWithFallback(
              'assets/images/profile_placeholder.jpg',
              'profile',
              errorWidget: CircleAvatar(
                backgroundColor: ThemeConfig.primaryColor.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  color: ThemeConfig.primaryColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // User greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Let's Get Back 💪",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Notification icon
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: _navigateToNotifications,
        ),
      ],
    )
        .animate(controller: _animationController)
        .fadeIn(
          duration: 500.ms,
          delay: 100.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: -0.2,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutQuint,
          delay: 100.ms,
        );
  }

  // Search bar
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        // Navigate to search screen when search bar is tapped
        _navigateToAllWorkouts();
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: ThemeConfig.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'Search Workouts...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(
          duration: 500.ms,
          delay: 200.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: -0.2,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutQuint,
          delay: 200.ms,
        );
  }

  // Motivational text
  Widget _buildMotivationalText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stronger every rep',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const Text(
          'every step.',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildHashtag('#FitLife')
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(width: 8),
            _buildHashtag('#FlexAndGrow')
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms),
            const SizedBox(width: 8),
            _buildHashtag('#Training')
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms),
          ],
        ),
      ],
    )
        .animate(controller: _animationController)
        .fadeIn(
          duration: 500.ms,
          delay: 300.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: -0.2,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutQuint,
          delay: 300.ms,
        );
  }

  Widget _buildHashtag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ThemeConfig.cardColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  // Start Workout Button
  Widget _buildStartWorkoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.local_fire_department, color: Colors.white),
        label: const Text(
          'Start Workout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConfig.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          shadowColor: ThemeConfig.primaryColor.withOpacity(0.5),
        ),
        onPressed: () {
          _navigateToWorkoutDetails('full_body', 'Full Body Workout');
        },
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(
          duration: 600.ms,
          delay: 400.ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.easeOutBack,
          delay: 400.ms,
        );
  }

  // Daily Program Section
  Widget _buildDailyProgramSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Program',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: _navigateToAllWorkouts,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: ThemeConfig.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Workout type filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildWorkoutTypeChip('All Type', true),
              _buildWorkoutTypeChip('Chest', false),
              _buildWorkoutTypeChip('Back', false),
              _buildWorkoutTypeChip('Arms', false),
              _buildWorkoutTypeChip('Cardio', false),
              _buildWorkoutTypeChip('Legs', false),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Workout program cards
        Row(
          children: [
            Expanded(
              child: _buildWorkoutProgramCard(
                title: 'Chest Program',
                duration: '12 min',
                sets: '3 x 15 reps',
                imageUrl: 'assets/images/chest_workout.jpg',
                category: 'chest',
                onTap: () {
                  _navigateToWorkoutDetails('chest', 'Chest Program');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWorkoutProgramCard(
                title: 'Arms Program',
                duration: '15 min',
                sets: '3 x 12 reps',
                imageUrl: 'assets/images/arms_workout.jpg',
                category: 'arms',
                onTap: () {
                  _navigateToWorkoutDetails('arms', 'Arms Program');
                },
              ),
            ),
          ],
        ),
      ],
    )
        .animate(controller: _animationController)
        .fadeIn(
          duration: 600.ms,
          delay: 500.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 700.ms,
          curve: Curves.easeOutQuint,
          delay: 500.ms,
        );
  }

  Widget _buildWorkoutTypeChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        backgroundColor: ThemeConfig.cardColor,
        selectedColor: ThemeConfig.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.2),
        onSelected: (bool selected) {
          // Filter workouts by type - to be implemented
        },
      ),
    );
  }

  Widget _buildWorkoutProgramCard({
    required String title,
    required String duration,
    required String sets,
    required String imageUrl,
    required String category,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeConfig.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: AssetResolver.getImageWithFallback(
                      imageUrl,
                      category,
                      errorWidget: Container(
                        color: ThemeConfig.primaryColor.withOpacity(0.2),
                        child: Center(
                          child: Icon(
                            Icons.fitness_center,
                            color: ThemeConfig.primaryColor,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category label
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ThemeConfig.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Workout details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workout title with better typography
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Duration and sets
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.fitness_center,
                          size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        sets,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 700.ms,
          delay: 100.ms,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 700.ms,
          curve: Curves.easeOutQuint,
        );
  }

  // Personal Trainer Section
  Widget _buildPersonalTrainerSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Personal Trainer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Personal trainers will be available in the next update'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  color: ThemeConfig.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    )
        .animate(controller: _animationController)
        .fadeIn(
          duration: 600.ms,
          delay: 600.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 700.ms,
          curve: Curves.easeOutQuint,
          delay: 600.ms,
        );
  }

  Widget _buildWorkoutCard({
    required String title,
    required String subtitle,
    required String category,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeConfig.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout image
            AspectRatioImage(
              imagePath: imageUrl,
              aspectRatio: 16 / 9,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              applyDarkGradient: true,
            ),

            // Workout details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(
          begin: 0.2, end: 0, curve: Curves.easeOutQuad, duration: 500.ms),
    );
  }
}
