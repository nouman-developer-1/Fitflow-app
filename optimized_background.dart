import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class OptimizedBackground extends StatefulWidget {
  final String imagePath;
  final Widget child;
  final double opacity;
  final bool enableBlur;
  final bool enableParticles;
  final Color overlayColor;
  final List<Color>? gradientColors;

  const OptimizedBackground({
    super.key,
    required this.imagePath,
    required this.child,
    this.opacity = 0.7,
    this.enableBlur = true,
    this.enableParticles = true,
    this.overlayColor = Colors.black,
    this.gradientColors,
  });

  @override
  State<OptimizedBackground> createState() => _OptimizedBackgroundState();
}

class _OptimizedBackgroundState extends State<OptimizedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Optimized image loading with fade in animation
        Image.asset(
          widget.imagePath,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.indigo.shade900,
                    Colors.indigo.shade700,
                    Colors.blue.shade500,
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white70,
                  size: 48,
                ),
              ),
            );
          },
        ),

        // Overlay with gradient
        Container(
          decoration: BoxDecoration(
            color: widget.gradientColors == null
                ? widget.overlayColor.withOpacity(widget.opacity)
                : null,
            gradient: widget.gradientColors != null
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: widget.gradientColors!
                        .map((color) => color.withOpacity(widget.opacity))
                        .toList(),
                  )
                : null,
          ),
        ),

        // Blur effect
        if (widget.enableBlur)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(color: Colors.transparent),
          ),

        // Animated particles effect
        if (widget.enableParticles)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return CustomPaint(
                painter: ParticlesPainter(
                  animationValue: _animationController.value,
                  screenSize: screenSize,
                ),
              );
            },
          ),

        // Actual content
        widget.child,
      ],
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final Size screenSize;
  final List<Particle> particles = [];

  ParticlesPainter({
    required this.animationValue,
    required this.screenSize,
  }) {
    if (particles.isEmpty) {
      // Generate particles only once
      for (int i = 0; i < 40; i++) {
        particles.add(Particle(screenSize: screenSize));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update particle position based on animation value
      particle.update(animationValue);

      // Draw particle
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late Color color;
  late double speed;
  late double opacity;
  late double direction;
  final Size screenSize;

  Particle({required this.screenSize}) {
    final random = math.Random();

    // Random initial position
    x = random.nextDouble() * screenSize.width;
    y = random.nextDouble() * screenSize.height;

    // Random size between 2 and 5
    size = 2 + random.nextDouble() * 3;

    // Random white-ish color
    final brightness = 200 + random.nextInt(55);
    color = Color.fromRGBO(brightness, brightness, brightness, 1);

    // Random speed
    speed = 0.2 + random.nextDouble() * 0.8;

    // Random opacity between 0.1 and 0.7
    opacity = 0.1 + random.nextDouble() * 0.6;

    // Random direction in radians
    direction = random.nextDouble() * 2 * math.pi;
  }

  void update(double animationValue) {
    final distance = 50.0 * speed;
    final angle = direction + animationValue * 2 * math.pi;

    x += math.sin(angle) * distance;
    y += math.cos(angle) * distance;

    // Wrap around edges
    if (x < 0) x = screenSize.width;
    if (x > screenSize.width) x = 0;
    if (y < 0) y = screenSize.height;
    if (y > screenSize.height) y = 0;
  }
}

/// A widget that optimizes images to prevent layout issues and improve performance
class OptimizedImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Color? fallbackColor;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final bool applyDarkGradient;

  const OptimizedImage({
    Key? key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.errorBuilder,
    this.fallbackColor,
    this.fallbackIcon = Icons.fitness_center,
    this.fallbackIconSize = 48.0,
    this.applyDarkGradient = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget image = Image.asset(
      imagePath,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: width != null ? (width! * 2).toInt() : null,
      cacheHeight: height != null ? (height! * 2).toInt() : null,
      errorBuilder: errorBuilder ??
          (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color:
                  fallbackColor ?? theme.colorScheme.primary.withOpacity(0.2),
              child: Center(
                child: Icon(
                  fallbackIcon,
                  size: fallbackIconSize,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          },
    );

    if (applyDarkGradient) {
      image = Stack(
        fit: StackFit.passthrough,
        children: [
          image,
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
        ],
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}

/// A responsive image container that maintains aspect ratio
class AspectRatioImage extends StatelessWidget {
  final String imagePath;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final bool applyDarkGradient;
  final Widget? overlayChild;

  const AspectRatioImage({
    Key? key,
    required this.imagePath,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
    this.applyDarkGradient = false,
    this.overlayChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          OptimizedImage(
            imagePath: imagePath,
            borderRadius: borderRadius,
            applyDarkGradient: applyDarkGradient,
          ),
          if (overlayChild != null)
            Positioned.fill(
              child: overlayChild!,
            ),
        ],
      ),
    );
  }
}
