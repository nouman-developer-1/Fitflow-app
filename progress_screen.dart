import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'dart:math' as math;
import '../../services/achievement_service.dart';
import '../../models/achievement.dart';
import '../achievements/achievements_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PageController _pageController;
  int _currentPage = 0;
  late TabController _tabController;
  final List<Map<String, dynamic>> _dummyWorkoutData = [];
  bool _isLoading = true;
  List<Achievement> _achievements = [];
  int _unlockedAchievementsCount = 0;

  final List<String> _tabs = ['Daily', 'Weekly', 'Monthly'];

  // Mock data for charts
  final List<Map<String, dynamic>> _dailyWorkouts = [
    {'day': 'Mon', 'minutes': 45, 'calories': 320},
    {'day': 'Tue', 'minutes': 30, 'calories': 250},
    {'day': 'Wed', 'minutes': 0, 'calories': 0},
    {'day': 'Thu', 'minutes': 60, 'calories': 450},
    {'day': 'Fri', 'minutes': 0, 'calories': 0},
    {'day': 'Sat', 'minutes': 75, 'calories': 520},
    {'day': 'Sun', 'minutes': 20, 'calories': 150},
  ];

  final List<Map<String, dynamic>> _weeklyWorkouts = [
    {'week': 'Week 1', 'minutes': 120, 'calories': 950},
    {'week': 'Week 2', 'minutes': 180, 'calories': 1200},
    {'week': 'Week 3', 'minutes': 210, 'calories': 1450},
    {'week': 'Week 4', 'minutes': 230, 'calories': 1700},
  ];

  final List<Map<String, dynamic>> _monthlyWorkouts = [
    {'month': 'Jan', 'minutes': 420, 'calories': 3200},
    {'month': 'Feb', 'minutes': 540, 'calories': 4100},
    {'month': 'Mar', 'minutes': 600, 'calories': 4800},
    {'month': 'Apr', 'minutes': 450, 'calories': 3500},
    {'month': 'May', 'minutes': 720, 'calories': 5600},
    {'month': 'Jun', 'minutes': 600, 'calories': 4700},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animationController.forward();

    // Load achievements
    _loadAchievements();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Your Progress'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final opacity = math.min(1.0, _animationController.value * 2);
                  return Opacity(
                    opacity: opacity,
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      context: context,
                      title: 'BMI',
                      value: userProvider.bmi.toStringAsFixed(1),
                      subtitle: userProvider.bmiCategory,
                      icon: Icons.monitor_weight,
                      color: _getBmiColor(userProvider.bmi),
                    ),
                    _buildStatCard(
                      context: context,
                      title: 'Weight',
                      value: '${userProvider.weight} kg',
                      subtitle: 'Target: 70 kg',
                      icon: Icons.fitness_center,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _buildStatCard(
                      context: context,
                      title: 'Workouts',
                      value: '15',
                      subtitle: 'This month',
                      icon: Icons.calendar_today,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final translateY = 50.0 *
                    (1.0 -
                        math.min(1.0, _animationController.value * 1.5 - 0.3));
                final opacity = math.max(
                    0.0, math.min(1.0, _animationController.value * 1.5 - 0.3));

                return Transform.translate(
                  offset: Offset(0, translateY),
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Activity Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        for (int i = 0; i < _tabs.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(_tabs[i]),
                              selected: _currentPage == i,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _currentPage = i;
                                    _pageController.animateToPage(
                                      i,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  });
                                }
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              labelStyle: TextStyle(
                                color: _currentPage == i
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.black87,
                                fontWeight: _currentPage == i
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        _buildBarChart(
                          context: context,
                          data: _dailyWorkouts,
                          labelKey: 'day',
                          valueKey: 'minutes',
                          title: 'Workout Duration (minutes)',
                        ),
                        _buildBarChart(
                          context: context,
                          data: _weeklyWorkouts,
                          labelKey: 'week',
                          valueKey: 'minutes',
                          title: 'Weekly Workout Duration (minutes)',
                        ),
                        _buildBarChart(
                          context: context,
                          data: _monthlyWorkouts,
                          labelKey: 'month',
                          valueKey: 'minutes',
                          title: 'Monthly Workout Duration (minutes)',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final translateY = 50.0 *
                    (1.0 -
                        math.min(1.0, _animationController.value * 1.5 - 0.6));
                final opacity = math.max(
                    0.0, math.min(1.0, _animationController.value * 1.5 - 0.6));

                return Transform.translate(
                  offset: Offset(0, translateY),
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Recent Achievements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentAchievements(),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart({
    required BuildContext context,
    required List<Map<String, dynamic>> data,
    required String labelKey,
    required String valueKey,
    required String title,
  }) {
    final double maxValue = data.fold(0.0,
        (prev, item) => math.max(prev.toDouble(), item[valueKey].toDouble()));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      maxValue.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      (maxValue * 0.75).toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      (maxValue * 0.5).toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      (maxValue * 0.25).toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '0',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.map((item) {
                      final double value = item[valueKey].toDouble();
                      final double percentage =
                          maxValue > 0 ? value / maxValue : 0;
                      final barHeight = 200 * percentage;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  final animatedHeight = barHeight *
                                      math.min(1.0,
                                          _animationController.value * 1.5);

                                  return Container(
                                    height: animatedHeight,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item[labelKey],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final unlockedAchievements =
        _achievements.where((achievement) => achievement.isUnlocked).toList();

    if (unlockedAchievements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No achievements unlocked yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete workouts to earn achievements',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AchievementsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.emoji_events),
              label: const Text('View All Achievements'),
            ),
          ],
        ),
      );
    }

    // Sort by most recently awarded
    unlockedAchievements.sort((a, b) => b.awardedDate.compareTo(a.awardedDate));

    // Show at most 4 most recent achievements
    final recentAchievements = unlockedAchievements.take(4).toList();

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: recentAchievements.length + 1, // +1 for "View All" card
        itemBuilder: (context, index) {
          if (index == recentAchievements.length) {
            // "View All" card
            return _buildViewAllAchievementsCard();
          }

          final achievement = recentAchievements[index];
          return _buildAchievementCard(
            context: context,
            title: achievement.title,
            description: achievement.description,
            icon: achievement.icon,
            color: achievement.color,
          );
        },
      ),
    );
  }

  Widget _buildViewAllAchievementsCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AchievementsScreen(),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'View All Achievements',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$_unlockedAchievementsCount/${_achievements.length} unlocked',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  // Load achievements from service
  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final achievementService = AchievementService();
      final achievements = await achievementService.getAchievements();

      setState(() {
        _achievements = achievements;
        _unlockedAchievementsCount =
            achievements.where((a) => a.isUnlocked).length;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading achievements: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
}
