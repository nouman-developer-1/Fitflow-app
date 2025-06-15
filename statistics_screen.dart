import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fitflow/config/theme_config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitflow/models/workout_category.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedMetric = 'Calories';
  String _selectedTimeRange = 'Days';
  int _selectedChartIndex = 0;
  final int _selectedDay = DateTime.now().weekday - 1;
  List<WorkoutCategory> _recentWorkouts = [];
  bool _isLoading = true;

  // Mock data for the chart
  final List<Map<String, dynamic>> _dailyData = [
    {'day': 'Mon', 'date': 12, 'value': 890, 'targetMet': false},
    {'day': 'Tue', 'date': 13, 'value': 1210, 'targetMet': true},
    {'day': 'Wed', 'date': 14, 'value': 750, 'targetMet': false},
    {'day': 'Thu', 'date': 15, 'value': 1450, 'targetMet': true},
    {'day': 'Fri', 'date': 16, 'value': 1050, 'targetMet': false},
    {'day': 'Sat', 'date': 17, 'value': 820, 'targetMet': false},
    {'day': 'Sun', 'date': 18, 'value': 1390, 'targetMet': true},
    {'day': 'Mon', 'date': 19, 'value': 1120, 'targetMet': true},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load recent workouts
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate network delay
      final recentWorkouts =
          WorkoutCategory.getAllCategories().take(3).toList();

      if (mounted) {
        setState(() {
          _recentWorkouts = recentWorkouts;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back if needed
          },
        ),
        title: const Text(
          'My Statistic',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {
              // Show options
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: ThemeConfig.primaryColor))
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Metrics selector tabs
                      _buildMetricSelector(),
                      const SizedBox(height: 24),

                      // Calories summary
                      _buildCaloriesSummary(),
                      const SizedBox(height: 16),

                      // Time range selector
                      _buildTimeRangeSelector(),
                      const SizedBox(height: 16),

                      // Chart
                      _buildCaloriesChart(),
                      const SizedBox(height: 24),

                      // Recent workouts
                      _buildRecentWorkouts(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Metric selector tabs
  Widget _buildMetricSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildMetricTab('Calories', 'assets/icons/calories.png'),
          const SizedBox(width: 12),
          _buildMetricTab('Heart Rate', 'assets/icons/heart_rate.png'),
          const SizedBox(width: 12),
          _buildMetricTab('Bpm', 'assets/icons/bpm.png'),
        ],
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(
          duration: 600.ms,
          delay: 100.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: -0.2,
          end: 0,
          duration: 700.ms,
          curve: Curves.easeOutQuint,
          delay: 100.ms,
        );
  }

  Widget _buildMetricTab(String title, String iconPath) {
    final bool isSelected = _selectedMetric == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetric = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ThemeConfig.primaryColor : ThemeConfig.cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: ThemeConfig.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              title == 'Calories'
                  ? Icons.local_fire_department
                  : title == 'Heart Rate'
                      ? Icons.favorite
                      : Icons.speed,
              color: isSelected ? Colors.white : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Calories summary
  Widget _buildCaloriesSummary() {
    return Row(
      children: [
        Text(
          '1,390',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: ThemeConfig.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Kcal',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ThemeConfig.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.arrow_upward,
                size: 14,
                color: ThemeConfig.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '12%',
                style: TextStyle(
                  color: ThemeConfig.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate(controller: _animationController)
        .fadeIn(
          duration: 600.ms,
          delay: 200.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: -0.2,
          end: 0,
          duration: 700.ms,
          curve: Curves.easeOutQuint,
          delay: 200.ms,
        );
  }

  // Time range selector
  Widget _buildTimeRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimeRangeButton('Days', isSelected: _selectedTimeRange == 'Days'),
        const SizedBox(width: 10),
        _buildTimeRangeButton('Weeks',
            isSelected: _selectedTimeRange == 'Weeks'),
        const SizedBox(width: 10),
        _buildTimeRangeButton('Months',
            isSelected: _selectedTimeRange == 'Months'),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ThemeConfig.cardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text(
                'Days',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    )
        .animate(controller: _animationController)
        .fadeIn(
          duration: 600.ms,
          delay: 300.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: -0.2,
          end: 0,
          duration: 700.ms,
          curve: Curves.easeOutQuint,
          delay: 300.ms,
        );
  }

  Widget _buildTimeRangeButton(String title, {required bool isSelected}) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedTimeRange = title;
        });
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
        child: Text(title),
      ),
    );
  }

  // Calories chart
  Widget _buildCaloriesChart() {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeConfig.cardColor,
            ThemeConfig.cardColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Target: 1,500 Kcal',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Container(
                height: 1,
                width: 120,
                color: ThemeConfig.primaryColor.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                8,
                (index) => _buildChartBar(index),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _dailyData.map((data) {
              final bool isToday =
                  _selectedChartIndex == _dailyData.indexOf(data);
              return Text(
                data['day'],
                style: TextStyle(
                  fontSize: 12,
                  color: isToday ? ThemeConfig.primaryColor : Colors.grey,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(
          duration: 700.ms,
          delay: 400.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 800.ms,
          curve: Curves.easeOutQuint,
          delay: 400.ms,
        );
  }

  Widget _buildChartBar(int index) {
    final data = _dailyData[index];
    final double maxValue = 1500;
    final double barHeight = (data['value'] / maxValue) * 120;
    final bool isSelected = _selectedChartIndex == index;
    final bool targetMet = data['targetMet'] as bool;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartIndex = index;
        });
      },
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: isSelected ? 20 : 0,
              child: isSelected
                  ? Center(
                      child: Text(
                        '${data['value']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: ThemeConfig.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 24 : 20,
              height: isSelected
                  ? barHeight + 8 // Add a small boost to selected bar
                  : barHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: targetMet
                      ? [
                          ThemeConfig.primaryColor.withOpacity(0.7),
                          ThemeConfig.primaryColor,
                        ]
                      : [
                          Colors.grey.withOpacity(0.3),
                          Colors.grey.withOpacity(0.7),
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: targetMet
                              ? ThemeConfig.primaryColor.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recent workouts
  Widget _buildRecentWorkouts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Workouts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all workouts
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
        const SizedBox(height: 16),

        // Chest program card
        _buildWorkoutHistoryCard(
          title: 'Chest Program',
          date: '19 Monday, 2024',
          duration: '31 min',
          sets: '3 x 12 reps',
          calories: '802 kcal',
          heartRate: '99 bpm',
          bpm: '16 bpm',
        ),
        const SizedBox(height: 16),

        // Arms program card
        _buildWorkoutHistoryCard(
          title: 'Arms Program',
          date: '18 Sunday, 2024',
          duration: '23 min',
          sets: '3 x 15 reps',
          calories: null,
          heartRate: null,
          bpm: null,
        ),
      ],
    )
        .animate(controller: _animationController)
        .fadeIn(
          duration: 700.ms,
          delay: 500.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 800.ms,
          curve: Curves.easeOutQuint,
          delay: 500.ms,
        );
  }

  Widget _buildWorkoutHistoryCard({
    required String title,
    required String date,
    required String duration,
    required String sets,
    String? calories,
    String? heartRate,
    String? bpm,
  }) {
    return AnimatedSlide(
      offset: Offset(0, 0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutQuint,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      size: 20,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.fitness_center, size: 14, color: Colors.grey[400]),
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
              if (calories != null && heartRate != null && bpm != null) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.grey, height: 1, thickness: 0.5),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWorkoutStat(
                      icon: Icons.local_fire_department,
                      label: 'Calories',
                      value: calories,
                      color: ThemeConfig.primaryColor,
                    ),
                    _buildWorkoutStat(
                      icon: Icons.favorite,
                      label: 'Heart Rate',
                      value: heartRate,
                      color: Colors.redAccent,
                    ),
                    _buildWorkoutStat(
                      icon: Icons.speed,
                      label: 'Bpm',
                      value: bpm,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            maxY: 2000,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value < 0 || value >= _dailyData.length)
                      return const SizedBox.shrink();
                    return Text(_dailyData[value.toInt()]['day']);
                  },
                ),
              ),
            ),
            barGroups: _dailyData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data['value'].toDouble(),
                    color: data['targetMet'] ? Colors.green : Colors.blue,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
