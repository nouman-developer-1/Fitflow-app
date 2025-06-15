import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/profile/profile_screen.dart';
import 'providers/user_provider.dart';
import 'services/video_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
    // Will be handled in the app
  }

  // Add Firebase status to app state
  final firebaseStatus = Provider.value(
    value: firebaseInitialized,
    child: Consumer<bool>(
      builder: (context, initialized, _) {
        if (!initialized) {
          // Show a banner when Firebase is not initialized
          return const MaterialBanner(
            content: Text(
                'Some features may be unavailable - Firebase initialization failed'),
            leading: Icon(Icons.warning),
            actions: <Widget>[
              TextButton(
                onPressed: null, // Could add retry logic here
                child: Text('Dismiss'),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    ),
  );

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemeMode();

  // Preload workout videos in the background
  _preloadWorkoutVideos();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => UserProvider()..setUser(null)),
        Provider<bool>.value(value: firebaseInitialized),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            final isFirebaseInitialized = Provider.of<bool>(context);
            if (!isFirebaseInitialized) {
              ScaffoldMessenger.of(context).showMaterialBanner(
                const MaterialBanner(
                  content: Text(
                      'Some features may be unavailable - Firebase initialization failed'),
                  leading: Icon(Icons.warning),
                  actions: <Widget>[
                    TextButton(
                      onPressed: null, // Could add retry logic here
                      child: Text('Dismiss'),
                    ),
                  ],
                ),
              );
            }
            return const FitFlowApp();
          },
        ),
      ),
    ),
  );
}

Future<void> _preloadWorkoutVideos() async {
  final videoCacheService = VideoCacheService();
  final defaultVideos = [
    'assets/Videos/cardio_workout.mp4',
    'assets/Videos/core_workout.mp4',
    'assets/Videos/default_workout.mp4',
    'assets/Videos/hiit_workout.mp4',
    'assets/Videos/strength_training.mp4',
    'assets/Videos/yoga_flow.mp4',
  ];

  // Start preloading in the background
  videoCacheService.preloadVideos(defaultVideos);
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }
}

class FitFlowApp extends StatelessWidget {
  const FitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return MaterialApp(
      title: 'FitFlow',
      debugShowCheckedModeBanner: false,
      themeMode: context.watch<ThemeProvider>().themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: userProvider.user == null ? const AuthWrapper() : const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;

  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomeContent(), // Removed const
    const Placeholder(), // Discover page (to be implemented)
    const Placeholder(), // Progress page (to be implemented)
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        child: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Theme.of(context).colorScheme.primary,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.search), text: 'Discover'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Progress'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? AnimatedBuilder(
              animation: _scaleController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _scaleController.value * 2 * math.pi,
                  child: FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class HomeContent extends StatelessWidget {
  HomeContent({super.key}); // Removed const

  final List<WorkoutCategory> categories = [
    // Removed const
    WorkoutCategory(
      name: 'Chest',
      icon: Icons.fitness_center,
      color: Colors.redAccent,
      videoPath:
          'assets/Videos/10 Best Effective Exercises To Build A Perfect Chest.mp4',
    ),
    WorkoutCategory(
      name: 'Arms',
      icon: Icons.sports_gymnastics,
      color: Colors.blueAccent,
      videoPath:
          'assets/Videos/14 Best Workout To Get Big And Perfect Arms.mp4',
    ),
    WorkoutCategory(
      name: 'Back',
      icon: Icons.accessibility_new,
      color: Colors.purpleAccent,
      videoPath:
          'assets/Videos/6 Exercises To Build Bigger Back - Back Workout.mp4',
    ),
    WorkoutCategory(
      name: 'Legs',
      icon: Icons.directions_run,
      color: Colors.orangeAccent,
      videoPath:
          'assets/Videos/7 BEST LEG EXERCISES TO GET WIDE THIGH WORKOUT !🎯.mp4',
    ),
    WorkoutCategory(
      name: 'Shoulders',
      icon: Icons.sports_martial_arts,
      color: Colors.greenAccent,
      videoPath: 'assets/Videos/9 Exercise For Bigger SHOULDER AND TRAPS.mp4',
    ),
    WorkoutCategory(
      name: 'Triceps',
      icon: Icons.fitness_center,
      color: Colors.deepPurpleAccent,
      videoPath:
          'assets/Videos/TRICEPS Exercises WITH DUMBBELLS AT HOME AND GYM.mp4',
    ),
  ];

  final List<Workout> featuredWorkouts = [
    // Removed const
    Workout(
      name: 'Full Body HIIT',
      duration: '30 min',
      difficulty: 'Intermediate',
      caloriesBurn: '320 cal',
    ),
    Workout(
      name: 'Morning Yoga Flow',
      duration: '20 min',
      difficulty: 'Beginner',
      caloriesBurn: '150 cal',
    ),
    Workout(
      name: 'Core Crusher',
      duration: '25 min',
      difficulty: 'Advanced',
      caloriesBurn: '280 cal',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final fadeAnimation = CurvedAnimation(
      parent: AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: Scaffold.of(context),
      )..forward(),
      curve: Curves.easeIn,
    );

    final scaleAnimation = CurvedAnimation(
      parent: AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: Scaffold.of(context),
      )..forward(),
      curve: Curves.easeOutBack,
    );

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                expandedHeight: 120,
                backgroundColor: Theme.of(context).colorScheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'FitFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      context.watch<ThemeProvider>().themeMode ==
                              ThemeMode.light
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      context.read<ThemeProvider>().toggleTheme();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProvider.userGreeting,
                          style: TextStyle(
                            fontSize: isTablet ? 24.0 : 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your goal: ${userProvider.fitnessGoal}',
                          style: TextStyle(
                            fontSize: isTablet ? 18.0 : 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Workout Categories',
                          style: TextStyle(
                            fontSize: isTablet ? 20.0 : 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: SizedBox(
                    height: 120,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 500 + (100 * index)),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: CategoryCard(
                                  category: categories[index],
                                  isTablet: isTablet,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Workouts',
                              style: TextStyle(
                                fontSize: isTablet ? 20.0 : 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to all workouts
                              },
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final delay = 300 * index;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 800 + delay),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: WorkoutCard(
                            workout: featuredWorkouts[index],
                            isTablet: isTablet,
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: featuredWorkouts.length),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final WorkoutCategory category;
  final bool isTablet;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isTablet,
  });

  void _showWorkoutVideo(BuildContext context) {
    if (category.videoPath == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutVideoScreen(
          title: category.name,
          videoPath: category.videoPath!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        child: InkWell(
          onTap: () => _showWorkoutVideo(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: isTablet ? 150 : 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [category.color.withOpacity(0.8), category.color],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  size: isTablet ? 40 : 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final bool isTablet;

  const WorkoutCard({super.key, required this.workout, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: isTablet ? 140 : 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Row(
              children: [
                WorkoutImage(
                  workoutType: workout.name.toLowerCase().replaceAll(' ', '_'),
                  width: isTablet ? 100 : 80,
                  height: isTablet ? 100 : 80,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        workout.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: isTablet ? 18 : 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            workout.duration,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.local_fire_department,
                            size: isTablet ? 18 : 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            workout.caloriesBurn,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _difficultyColor(workout.difficulty),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          workout.difficulty,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 12 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: isTablet ? 20 : 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
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
}

class WorkoutCategory {
  final String name;
  final IconData icon;
  final Color color;
  final String? videoPath;

  WorkoutCategory({
    required this.name,
    required this.icon,
    required this.color,
    this.videoPath,
  });
}

class Workout {
  final String name;
  final String duration;
  final String difficulty;
  final String caloriesBurn;

  Workout({
    required this.name,
    required this.duration,
    required this.difficulty,
    required this.caloriesBurn,
  });
}

class WorkoutImage extends StatelessWidget {
  final String workoutType;
  final double width;
  final double height;

  const WorkoutImage({
    super.key,
    required this.workoutType,
    this.width = 80,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _getWorkoutImage(workoutType),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      _getWorkoutIcon(workoutType),
                      size: width * 0.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getWorkoutImage(String type) {
    final lowercaseType = type.toLowerCase();
    if (lowercaseType.contains('hiit')) {
      return 'assets/images/fitnessphoto.jpeg';
    }
    if (lowercaseType.contains('yoga')) {
      return 'assets/images/fitnessphoto1.jpeg';
    }
    if (lowercaseType.contains('core')) return 'assets/images/fitness3.jpeg';
    return 'assets/images/fintessphoto2.jpeg';
  }

  IconData _getWorkoutIcon(String type) {
    final lowercaseType = type.toLowerCase();
    if (lowercaseType.contains('yoga')) return Icons.self_improvement;
    if (lowercaseType.contains('hiit')) return Icons.flash_on;
    if (lowercaseType.contains('core')) return Icons.fitness_center;
    if (lowercaseType.contains('cardio')) return Icons.directions_run;
    return Icons.sports_gymnastics;
  }
}

class WorkoutVideoScreen extends StatefulWidget {
  final String title;
  final String videoPath;

  const WorkoutVideoScreen({
    super.key,
    required this.title,
    required this.videoPath,
  });

  @override
  State<WorkoutVideoScreen> createState() => _WorkoutVideoScreenState();
}

class _WorkoutVideoScreenState extends State<WorkoutVideoScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.asset(widget.videoPath);
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      placeholder: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
      ),
    );
  }
}
