import 'package:flutter/material.dart';
import '../utils/asset_resolver.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HDBackgroundContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final bool useGradient;
  final double borderRadius;
  final double elevation;
  final bool addAnimation;
  final List<BoxShadow>? customShadows;

  const HDBackgroundContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.gradientStartColor,
    this.gradientEndColor,
    this.useGradient = false,
    this.borderRadius = 16.0,
    this.elevation = 4.0,
    this.addAnimation = false,
    this.customShadows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultColor = isDark ? const Color(0xFF1A1D24) : Colors.white;

    final bgColor = backgroundColor ?? defaultColor;

    final shadows = customShadows ??
        [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation / 2),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: elevation * 2,
              offset: Offset(0, -elevation / 2),
            ),
        ];

    Widget containerWidget = Container(
      decoration: BoxDecoration(
        color: useGradient ? null : bgColor,
        gradient: useGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientStartColor ?? theme.colorScheme.primary,
                  gradientEndColor ?? theme.colorScheme.secondary,
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );

    if (addAnimation) {
      return containerWidget
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .slideY(
            begin: 0.1,
            end: 0,
            duration: 500.ms,
            curve: Curves.easeOutQuad,
          );
    }

    return containerWidget;
  }
}

/// A page transition effect for smoother navigation between screens
class PageTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const PageTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutQuint,
  });

  @override
  Widget build(BuildContext context) {
    return child.animate().fadeIn(duration: duration, curve: curve).slideX(
          begin: 0.1,
          end: 0,
          duration: duration,
          curve: curve,
        );
  }
}

class FitnessCardImage extends StatelessWidget {
  final String? imagePath;
  final double height;
  final Color? fallbackColor;
  final IconData fallbackIcon;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool useNetworkFallback;
  final String category;
  final double? width;

  const FitnessCardImage({
    super.key,
    this.imagePath,
    this.height = 180.0,
    this.width,
    this.fallbackColor,
    this.fallbackIcon = Icons.fitness_center,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.useNetworkFallback = true,
    this.category = 'default',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);
    final effectiveColor =
        fallbackColor ?? theme.colorScheme.primary.withOpacity(0.3);

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: effectiveBorderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              effectiveColor.withOpacity(0.6),
              effectiveColor,
            ],
          ),
        ),
        child: _buildImageWithFallbacks(theme),
      ),
    );
  }

  Widget _buildImageWithFallbacks(ThemeData theme) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return _buildAssetImage(theme);
    }

    return Center(
      child: Icon(
        fallbackIcon,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAssetImage(ThemeData theme) {
    return Image.asset(
      imagePath!,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image $imagePath: $error');

        // If network fallback is enabled, try loading from network
        if (useNetworkFallback) {
          return _buildNetworkImage(theme);
        }

        return Center(
          child: Icon(
            fallbackIcon,
            size: 48,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildNetworkImage(ThemeData theme) {
    final networkUrl = AssetResolver.getFallbackNetworkImage(category);

    return Image.network(
      networkUrl,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            color: theme.colorScheme.secondary,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            fallbackIcon,
            size: 48,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
