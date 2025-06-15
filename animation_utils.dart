import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Utility class providing reusable animations throughout the app
class AnimationUtils {
  /// Standard entrance animation for cards and containers
  static List<Effect> get standardEntrance => [
        FadeEffect(
          duration: 400.ms,
          curve: Curves.easeOut,
        ),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end: const Offset(0, 0),
          duration: 500.ms,
          curve: Curves.easeOutQuad,
        ),
      ];

  /// Staggered entrance animation for list items
  static List<Effect> staggeredEntrance(int index, {int staggerMs = 50}) => [
        FadeEffect(
          duration: 400.ms,
          delay: Duration(milliseconds: index * staggerMs),
        ),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end: const Offset(0, 0),
          duration: 400.ms,
          delay: Duration(milliseconds: index * staggerMs),
          curve: Curves.easeOutQuad,
        ),
      ];

  /// Subtle pulse animation for interactive elements
  static List<Effect> get subtlePulse => [
        ScaleEffect(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 600.ms,
          curve: Curves.easeInOut,
          delay: 300.ms,
        ),
      ];

  /// Shimmer effect for loading states
  static List<Effect> get shimmerEffect => [
        ShimmerEffect(
          duration: 1500.ms,
          color: Colors.white.withOpacity(0.2),
          delay: 200.ms,
        ),
      ];

  /// Page transition animation
  static PageRouteBuilder customPageRoute({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeOutQuint;
        var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }
}
