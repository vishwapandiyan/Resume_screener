import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlowContainer extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isAnimated;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor = AppTheme.glowBlue,
    this.glowRadius = 20.0,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.isAnimated = true,
    this.backgroundColor,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  State<GlowContainer> createState() => _GlowContainerState();
}

class _GlowContainerState extends State<GlowContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isAnimated) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              final glowIntensity = widget.isAnimated 
                  ? _glowAnimation.value 
                  : (_isHovered ? 1.0 : 0.6);
              
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    // Outer glow
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.3 * glowIntensity),
                      blurRadius: widget.glowRadius * glowIntensity,
                      spreadRadius: 2,
                    ),
                    // Inner glow
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.1 * glowIntensity),
                      blurRadius: widget.glowRadius * 0.5 * glowIntensity,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? 
                           AppTheme.backgroundWhite.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: widget.glowColor.withOpacity(0.2 * glowIntensity),
                      width: 1,
                    ),
                  ),
                  child: widget.child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class GlowButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color glowColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isLoading;

  const GlowButton({
    super.key,
    required this.child,
    this.onPressed,
    this.glowColor = AppTheme.glowBlue,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlowContainer(
      glowColor: glowColor,
      borderRadius: borderRadius,
      padding: padding,
      isAnimated: false,
      backgroundColor: glowColor,
      onTap: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : DefaultTextStyle(
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
              child: child,
            ),
    );
  }
}

class GlowCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final String? title;
  final VoidCallback? onTap;
  final bool isSelected;

  const GlowCard({
    super.key,
    required this.child,
    this.glowColor = AppTheme.glowBlue,
    this.title,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlowContainer(
      glowColor: isSelected ? glowColor : glowColor.withOpacity(0.3),
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      isAnimated: isSelected,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: glowColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

class GlowProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color glowColor;
  final double height;
  final String? label;

  const GlowProgressIndicator({
    super.key,
    required this.progress,
    this.glowColor = AppTheme.glowBlue,
    this.height = 8.0,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: AppTheme.secondaryGray.withOpacity(0.1),
          ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  color: AppTheme.secondaryGray.withOpacity(0.1),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height / 2),
                    gradient: LinearGradient(
                      colors: [
                        glowColor.withOpacity(0.8),
                        glowColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
