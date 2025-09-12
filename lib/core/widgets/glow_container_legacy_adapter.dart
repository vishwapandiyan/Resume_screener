import 'package:flutter/material.dart';
import 'glow_container.dart' as glow;
import '../theme/app_theme.dart';

/// Legacy adapter for old GlowContainer API
class LegacyGlowContainer extends StatelessWidget {
  final List<Color> colors;
  final Duration rotationDuration;
  final Widget child;
  final ContainerOptions containerOptions;

  const LegacyGlowContainer({
    super.key,
    required this.colors,
    required this.rotationDuration,
    required this.child,
    required this.containerOptions,
  });

  @override
  Widget build(BuildContext context) {
    return glow.GlowContainer(
      glowColor: colors.isNotEmpty ? colors.first : AppTheme.glowBlue,
      borderRadius: containerOptions.borderRadius,
      width: containerOptions.width,
      height: containerOptions.height,
      isAnimated: true,
      child: child,
    );
  }
}

class ContainerOptions {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final BorderSide? borderSide;

  const ContainerOptions({
    this.width,
    this.height,
    required this.borderRadius,
    this.backgroundColor,
    this.borderSide,
  });
}

// Enum for backward compatibility
enum GlowLocation { both }

// Factory function for backward compatibility
Widget glowContainer({
  required List<Color> colors,
  required Duration rotationDuration,
  required GlowLocation glowLocation,
  required ContainerOptions containerOptions,
  required Widget child,
}) {
  return LegacyGlowContainer(
    colors: colors,
    rotationDuration: rotationDuration,
    containerOptions: containerOptions,
    child: child,
  );
}
