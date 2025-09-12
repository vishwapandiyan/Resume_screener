import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';

class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final AnimationController? animationController;
  final TextAlign? textAlign;
  final double? height;
  final double? letterSpacing;

  const GradientText({
    super.key,
    required this.text,
    required this.fontSize,
    this.fontWeight = FontWeight.normal,
    this.animationController,
    this.textAlign,
    this.height,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final responsiveFontSize = ResponsiveUtils.getResponsiveFontSize(
          context,
          mobile: fontSize * 0.8,
          tablet: fontSize * 0.9,
          desktop: fontSize,
          largeDesktop: fontSize * 1.1,
          extraLargeDesktop: fontSize * 1.2,
        );

        return AnimatedBuilder(
          animation: animationController ?? const AlwaysStoppedAnimation(0),
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: AppTheme.simplifiedGradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  transform: GradientRotation(
                    (animationController?.value ?? 0) * 2 * 3.14159,
                  ),
                ).createShader(bounds);
              },
              child: Text(
                text,
                style: TextStyle(
                  fontSize: responsiveFontSize,
                  fontWeight: fontWeight,
                  color: Colors.white,
                  height: height,
                  letterSpacing: letterSpacing,
                ),
                textAlign: textAlign,
              ),
            );
          },
        );
      },
    );
  }
}
