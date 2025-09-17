import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';

class GradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final bool isSmall;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isSmall = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  // late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(
        seconds: 6,
      ), // Slowed down from 3 seconds to 6 seconds
      vsync: this,
    );
    // _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.linear),
    // );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final buttonWidth = ResponsiveUtils.getResponsiveContainerWidth(
          context,
          mobile: widget.isSmall ? 90 : 110,
          tablet: widget.isSmall ? 96 : 115,
          desktop: widget.isSmall ? 102 : 120,
          largeDesktop: widget.isSmall ? 108 : 125,
          extraLargeDesktop: widget.isSmall ? 114 : 130,
        );

        final buttonHeight = ResponsiveUtils.getResponsiveContainerHeight(
          context,
          mobile: widget.isSmall ? 32 : 40,
          tablet: widget.isSmall ? 33 : 41,
          desktop: widget.isSmall ? 35 : 43,
          largeDesktop: widget.isSmall ? 37 : 45,
          extraLargeDesktop: widget.isSmall ? 39 : 47,
        );

        final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(
          context,
          mobile: widget.isSmall ? 18 : 22,
          tablet: widget.isSmall ? 19 : 23,
          desktop: widget.isSmall ? 20 : 24,
          largeDesktop: widget.isSmall ? 21 : 25,
          extraLargeDesktop: widget.isSmall ? 22 : 26,
        );

        final fontSize = ResponsiveUtils.getResponsiveFontSize(
          context,
          mobile: widget.isSmall ? 12 : 14,
          tablet: widget.isSmall ? 13 : 15,
          desktop: widget.isSmall ? 14 : 16,
          largeDesktop: widget.isSmall ? 15 : 17,
          extraLargeDesktop: widget.isSmall ? 16 : 18,
        );

        return GlowContainer(
          gradientColors: [
            const Color(0xFF4285F4), // Blue
            const Color(0xFFEA4335), // Red
            const Color(0xFFFBBC04), // Yellow
            const Color(0xFF34A853), // Green
          ],
          rotationDuration: Duration(seconds: 3),
          glowRadius: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 2,
            tablet: 2.5,
            desktop: 3,
            largeDesktop: 3.5,
            extraLargeDesktop: 4,
          ),
          containerOptions: ContainerOptions(
            width: buttonWidth,
            height: buttonHeight,
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(
              context,
              mobile: widget.isSmall ? 18 : 22,
              tablet: widget.isSmall ? 19 : 23,
              desktop: widget.isSmall ? 20 : 24,
              largeDesktop: widget.isSmall ? 21 : 25,
              extraLargeDesktop: widget.isSmall ? 22 : 26,
            ),
            backgroundColor: Colors.transparent,
            borderSide: BorderSide(
              width: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 1.5,
                tablet: 1.8,
                desktop: 2,
                largeDesktop: 2.2,
                extraLargeDesktop: 2.5,
              ),
              color: const Color(0xFF174EA6),
            ),
          ),
          child: Container(
            width: buttonWidth * 0.94,
            height: buttonHeight * 0.89,
            margin: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 2.5,
                tablet: 2.8,
                desktop: 3,
                largeDesktop: 3.2,
                extraLargeDesktop: 3.5,
              ),
            ),
            decoration: ShapeDecoration(
              color: AppTheme.backgroundWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Center(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF202124),
                      height: 1.71,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
