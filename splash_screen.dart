import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math' as math;
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/premium_background.dart';
import 'auth/auth_wrapper.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showShimmer = false;
  List<Widget> _floatingElements = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    // Generate random floating fitness elements
    _generateFloatingElements();

    // Delayed shimmer effect to make transition smoother
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showShimmer = true;
        });
      }
    });

    // Navigate to main screen after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: userProvider.user == null
                      ? const AuthWrapper()
                      : const HomePage(),
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  void _generateFloatingElements() {
    final List<IconData> fitnessIcons = [
      Icons.fitness_center,
      Icons.directions_run,
      Icons.self_improvement,
      Icons.sports_gymnastics,
      Icons.sports_handball,
      Icons.sports_martial_arts,
      Icons.monitor_heart,
      Icons.rice_bowl,
      Icons.local_fire_department,
      Icons.water_drop,
    ];

    final random = math.Random();
    final List<Widget> elements = [];

    for (int i = 0; i < 15; i++) {
      final size = 20.0 + random.nextDouble() * 30;
      final icon = fitnessIcons[random.nextInt(fitnessIcons.length)];
      final left = random.nextDouble() * 300;
      final top = random.nextDouble() * 800;
      final delay = (random.nextDouble() * 1.5).seconds;

      elements.add(
        Positioned(
          left: left,
          top: top,
          child: Icon(
            icon,
            size: size,
            color: Colors.white.withOpacity(0.3),
          )
              .animate(delay: delay)
              .fadeIn(duration: 1.seconds)
              .scaleXY(
                  begin: 0.7,
                  end: 1.2,
                  duration: 2.seconds,
                  curve: Curves.easeInOut)
              .then()
              .scaleXY(begin: 1.2, end: 0.9, duration: 1.5.seconds)
              .then()
              .scaleXY(begin: 0.9, end: 1.0, duration: 1.seconds)
              .then(delay: 2.seconds)
              .custom(
                builder: (context, value, child) => Transform.rotate(
                  angle: value * 0.05,
                  child: child,
                ),
                begin: 0,
                end: 6.28,
                duration: 3.seconds,
                curve: Curves.easeInOut,
              ),
        ),
      );
    }

    setState(() {
      _floatingElements = elements;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final theme = Theme.of(context);

    return Scaffold(
      body: PremiumBackground(
        startColor: theme.colorScheme.primary,
        endColor: const Color(0xFF5C6BC0),
        patternOpacity: 0.15,
        child: Stack(
          children: [
            // Background floating elements
            ..._floatingElements,

            // Decorative elements
            Positioned(
              top: size.height * 0.1,
              right: size.width * 0.1,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
              )
                  .animate(controller: _animationController)
                  .fadeIn(delay: 200.ms, duration: 800.ms)
                  .rotate(delay: 200.ms, duration: 1500.ms),
            ),

            Positioned(
              bottom: size.height * 0.15,
              left: size.width * 0.1,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
              )
                  .animate(controller: _animationController)
                  .fadeIn(delay: 400.ms, duration: 800.ms)
                  .rotate(delay: 400.ms, duration: 1200.ms, begin: 0.5, end: 0),
            ),

            // Circle pulse animation
            Center(
              child: Container(
                width: size.width * 0.9,
                height: size.width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              )
                  .animate(controller: _animationController)
                  .scaleXY(
                    duration: 2.seconds,
                    curve: Curves.easeOut,
                    begin: 0.1,
                    end: 1.0,
                  )
                  .fadeIn(duration: 800.ms),
            ),

            Center(
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              )
                  .animate(controller: _animationController)
                  .scaleXY(
                    duration: 1800.ms,
                    curve: Curves.easeOut,
                    begin: 0.1,
                    end: 1.0,
                  )
                  .fadeIn(duration: 800.ms),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Logo container
                  Container(
                    width: isTablet ? 200 : 160,
                    height: isTablet ? 200 : 160,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: -5,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: Curves.elasticOut
                              .transform(_animationController.value),
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App name
                  Text(
                    'FitFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 52 : 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(0, 3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  )
                      .animate(controller: _animationController)
                      .fadeIn(delay: 400.ms, duration: 800.ms)
                      .slideY(
                          delay: 400.ms, duration: 800.ms, begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  // Tagline
                  Text(
                    'Your Fitness Journey Starts Here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  )
                      .animate(controller: _animationController)
                      .fadeIn(delay: 700.ms, duration: 800.ms)
                      .slideY(
                          delay: 700.ms, duration: 800.ms, begin: 0.3, end: 0),

                  const Spacer(),

                  // Loading indicator
                  if (_showShimmer)
                    Column(
                      children: [
                        Container(
                          width: 220,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Container(
                                        width: constraints.maxWidth *
                                            _animationController.value,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.colorScheme.secondary,
                                              theme.colorScheme.primary,
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Animated shine effect
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return AnimatedPositioned(
                                        duration:
                                            const Duration(milliseconds: 1500),
                                        curve: Curves.easeInOut,
                                        left: _animationController.value *
                                            constraints.maxWidth,
                                        top: 0,
                                        width: 30,
                                        height: 6,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.0),
                                                Colors.white.withOpacity(0.5),
                                                Colors.white.withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
