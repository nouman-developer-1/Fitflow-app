import 'package:flutter/material.dart';
import 'package:fitflow/config/theme_config.dart';
import 'package:fitflow/screens/home/home_screen.dart';
import 'package:fitflow/screens/workouts/discover_workouts_screen.dart';
import 'package:fitflow/screens/progress/statistics_screen.dart';
import 'package:fitflow/screens/profile/profile_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoverWorkoutsScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.secondaryColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ThemeConfig.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _buildNavItem(
                  icon: Icons.fitness_center,
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _buildNavItem(
                  icon: Icons.bar_chart_rounded,
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ).animate().slideY(
            begin: 1,
            end: 0,
            duration: 500.ms,
            curve: Curves.easeOutQuint,
          ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeConfig.primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? ThemeConfig.primaryColor : Colors.grey,
          size: 24.0,
        )
            .animate(target: isSelected ? 1 : 0)
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.2, 1.2),
              duration: 300.ms,
              curve: Curves.easeOut,
            )
            .shimmer(
              duration: 300.ms,
              color: ThemeConfig.primaryColor.withOpacity(0.3),
              delay: 100.ms,
            ),
      ),
    );
  }
}
