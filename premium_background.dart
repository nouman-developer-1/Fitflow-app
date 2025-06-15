import 'package:flutter/material.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;
  final bool useDarkOverlay;
  final double patternOpacity;
  final Color startColor;
  final Color endColor;

  const PremiumBackground({
    super.key,
    required this.child,
    this.useDarkOverlay = false,
    this.patternOpacity = 0.1,
    Color? startColor,
    Color? endColor,
  })  : startColor = startColor ?? const Color(0xFF3F51B5),
        endColor = endColor ?? const Color(0xFF303F9F);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            startColor,
            endColor,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Abstract pattern overlay
          _buildPatternOverlay(),

          // Optional dark overlay for better text readability
          if (useDarkOverlay)
            Container(
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

          // Main content
          child,
        ],
      ),
    );
  }

  Widget _buildPatternOverlay() {
    return Stack(
      children: [
        // Top right circle
        Positioned(
          right: -100,
          top: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(patternOpacity),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Bottom left circle
        Positioned(
          left: -70,
          bottom: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(patternOpacity),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Small decorative circles
        Positioned(
          right: 60,
          top: 100,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(patternOpacity * 0.8),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Positioned(
          left: 80,
          top: 200,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(patternOpacity * 0.6),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class HDCardBackground extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double borderRadius;
  final double elevation;

  const HDCardBackground({
    super.key,
    required this.child,
    this.color,
    this.borderRadius = 16.0,
    this.elevation = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor =
        color ?? (isDark ? const Color(0xFF2A2A2A) : Colors.white);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: elevation * 2,
              offset: Offset(0, -elevation / 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}
