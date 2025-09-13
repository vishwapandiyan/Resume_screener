import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import '../widgets/gradient_text.dart';
import 'auth/login_view.dart';
import 'workspace_dashboard_view.dart';
import 'dart:math' as math;

// Particle class for background animation
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.opacity,
  });
}

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView>
    with TickerProviderStateMixin {
  late AnimationController _gradientAnimationController;
  late AnimationController _buttonBorderAnimationController;
  late AnimationController _buttonScaleAnimationController;
  late AnimationController _particleAnimationController;

  // Particle data
  List<Particle> _particles = [];

  // Scroll controller and state
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    // Initialize scroll controller
    _scrollController = ScrollController();

    // Gradient text animation controller
    _gradientAnimationController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ), // Faster animation for running gradient effect
      vsync: this,
    );

    // Button border gradient animation controller
    _buttonBorderAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Button scale animation controller for pop-up effect
    _buttonScaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Particle animation controller
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Initialize particles
    _initializeParticles();

    // Start animations
    _startAnimations();
  }

  void _initializeParticles() {
    final random = math.Random();
    final particleColors = [
      const Color(0xFF4285F4).withOpacity(0.3),
      const Color(0xFFEA4335).withOpacity(0.3),
      const Color(0xFFFBBC04).withOpacity(0.3),
      const Color(0xFF34A853).withOpacity(0.3),
      const Color(0xFF8B5CF6).withOpacity(0.3),
    ];

    _particles = List.generate(50, (index) {
      return Particle(
        x: random.nextDouble() * 1000,
        y: random.nextDouble() * 1000,
        vx: (random.nextDouble() - 0.5) * 2,
        vy: (random.nextDouble() - 0.5) * 2,
        size: random.nextDouble() * 4 + 1,
        color: particleColors[random.nextInt(particleColors.length)],
        opacity: random.nextDouble() * 0.8 + 0.2,
      );
    });
  }

  void _startAnimations() {
    // Gradient rotation animation
    _gradientAnimationController.repeat();

    // Button border gradient animation
    _buttonBorderAnimationController.repeat();

    // Particle animation
    _particleAnimationController.repeat();
  }

  @override
  void dispose() {
    _gradientAnimationController.dispose();
    _buttonBorderAnimationController.dispose();
    _buttonScaleAnimationController.dispose();
    _particleAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('assets/images/img_1.png', fit: BoxFit.cover),
          ),

          // Animated particles background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    animationValue: _particleAnimationController.value,
                  ),
                );
              },
            ),
          ),

          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Main content
                  _buildMainContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        return Padding(
          padding: ResponsiveUtils.getResponsiveHorizontalPadding(context).add(
            EdgeInsets.symmetric(
              vertical: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
                largeDesktop: 28,
                extraLargeDesktop: 32,
              ),
            ),
          ),
          child: _buildHeaderContent(screenSize),
        );
      },
    );
  }

  Widget _buildHeaderContent(ScreenSize screenSize) {
    if (screenSize == ScreenSize.mobile) {
      // Mobile layout - stacked vertically
      return Column(
        children: [
          // Logo
          _buildLogo(
            width: ResponsiveUtils.getResponsiveContainerWidth(
              context,
              mobile: 140,
              tablet: 160,
              desktop: 180,
              largeDesktop: 200,
              extraLargeDesktop: 220,
            ),
            height: ResponsiveUtils.getResponsiveContainerHeight(
              context,
              mobile: 35,
              tablet: 40,
              desktop: 45,
              largeDesktop: 50,
              extraLargeDesktop: 55,
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
              largeDesktop: 28,
              extraLargeDesktop: 32,
            ),
          ),
          // Navigation
          _buildMobileNavigation(),
        ],
      );
    } else {
      // Desktop/Tablet layout - horizontal
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          _buildLogo(
            width: ResponsiveUtils.getResponsiveContainerWidth(
              context,
              mobile: 140,
              tablet: 160,
              desktop: 180,
              largeDesktop: 200,
              extraLargeDesktop: 220,
            ),
            height: ResponsiveUtils.getResponsiveContainerHeight(
              context,
              mobile: 35,
              tablet: 40,
              desktop: 45,
              largeDesktop: 50,
              extraLargeDesktop: 55,
            ),
          ),

          // Navigation
          _buildDesktopNavigation(),
        ],
      );
    }
  }

  Widget _buildLogo({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Image.asset(
        'assets/images/img.png',
        width: width * 0.85,
        height: height * 0.85,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildMobileNavigation() {
    return Wrap(
      spacing: ResponsiveUtils.getResponsiveSpacing(
        context,
        mobile: 12,
        tablet: 16,
        desktop: 20,
        largeDesktop: 24,
        extraLargeDesktop: 28,
      ),
      runSpacing: ResponsiveUtils.getResponsiveSpacing(
        context,
        mobile: 8,
        tablet: 12,
        desktop: 16,
        largeDesktop: 20,
        extraLargeDesktop: 24,
      ),
      alignment: WrapAlignment.center,
      children: [
        _buildNavigationButton('About us'),
        _buildNavigationButton('Contact Us'),
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildDesktopNavigation() {
    return Row(
      children: [
        _buildNavigationButton('About us'),
        SizedBox(
          width: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
            largeDesktop: 28,
            extraLargeDesktop: 32,
          ),
        ),
        _buildNavigationButton('Contact Us'),
        SizedBox(
          width: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
            largeDesktop: 28,
            extraLargeDesktop: 32,
          ),
        ),
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildNavigationButton(String text) {
    return TextButton(
      onPressed: () {},
      child: Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 15,
            desktop: 16,
            largeDesktop: 17,
            extraLargeDesktop: 18,
          ),
          fontFamily: 'Raleway',
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryBlack,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      height:
          MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          MediaQuery.of(context).padding.bottom -
          ResponsiveUtils.getResponsiveContainerHeight(
            context,
            mobile: 80,
            tablet: 100,
            desktop: 120,
            largeDesktop: 140,
            extraLargeDesktop: 160,
          ),
      child: Center(
        child: Padding(
          padding: ResponsiveUtils.getResponsiveHorizontalPadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Main headline
              _buildHeadline(),

              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 32,
                  tablet: 36,
                  desktop: 40,
                  largeDesktop: 44,
                  extraLargeDesktop: 48,
                ),
              ),

              // Subtitle
              _buildSubtitle(),

              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 48,
                  tablet: 52,
                  desktop: 56,
                  largeDesktop: 60,
                  extraLargeDesktop: 64,
                ),
              ),

              // CTA Button
              _buildAnimatedCTAButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        if (screenSize == ScreenSize.mobile) {
          // Mobile: Stack vertically
          return Column(
            children: [
              Text(
                'Hiring ',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 32,
                    tablet: 40,
                    desktop: 48,
                    largeDesktop: 56,
                    extraLargeDesktop: 62,
                  ),
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202124),
                  height: 1.2,
                  letterSpacing: 0.5,
                ),
              ),
              GradientText(
                text: 'Simplified..',
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 32,
                  tablet: 40,
                  desktop: 48,
                  largeDesktop: 56,
                  extraLargeDesktop: 62,
                ),
                fontWeight: FontWeight.w600,
                animationController: _gradientAnimationController,
              ),
            ],
          );
        } else {
          // Desktop/Tablet: Side by side
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Hiring ',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 32,
                    tablet: 40,
                    desktop: 48,
                    largeDesktop: 56,
                    extraLargeDesktop: 62,
                  ),
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202124),
                  height: 1.2,
                  letterSpacing: 0.5,
                ),
              ),
              GradientText(
                text: 'Simplified..',
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 32,
                  tablet: 40,
                  desktop: 48,
                  largeDesktop: 56,
                  extraLargeDesktop: 62,
                ),
                fontWeight: FontWeight.w600,
                animationController: _gradientAnimationController,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSubtitle() {
    return Column(
      children: [
        Text(
          'Hiring simplified: AI-powered talent matching system, screening resumes and matching candidates',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
              largeDesktop: 22,
              extraLargeDesktop: 25,
            ),
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8A9096),
            height: 0.96,
          ),
        ),
        Text(
          'with job opportunities, ensuring fairness and eliminating bias.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
              largeDesktop: 22,
              extraLargeDesktop: 25,
            ),
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8A9096),
            height: 0.96,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCTAButton() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final buttonWidth = ResponsiveUtils.getResponsiveContainerWidth(
          context,
          mobile: 280,
          tablet: 300,
          desktop: 320,
          largeDesktop: 340,
          extraLargeDesktop: 360,
        );

        final buttonHeight = ResponsiveUtils.getResponsiveContainerHeight(
          context,
          mobile: 60,
          tablet: 65,
          desktop: 70,
          largeDesktop: 75,
          extraLargeDesktop: 80,
        );

        return GestureDetector(
          onTapDown: (_) {
            _buttonScaleAnimationController.forward();
          },
          onTapUp: (_) {
            _buttonScaleAnimationController.reverse();
          },
          onTapCancel: () {
            _buttonScaleAnimationController.reverse();
          },
          onTap: () {
            // Navigate to workspace dashboard
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorkspaceDashboardView(),
              ),
            );
          },
          child: AnimatedBuilder(
            animation: _buttonScaleAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 - (_buttonScaleAnimationController.value * 0.05),
                child: GlowContainer(
                  glowRadius: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 3,
                    tablet: 4,
                    desktop: 5,
                    largeDesktop: 6,
                    extraLargeDesktop: 7,
                  ),
                  gradientColors: [
                    const Color(0xFF4285F4),
                    const Color(0xFFEA4335),
                    const Color(0xFFFBBC04),
                    const Color(0xFF34A853),
                  ],
                  rotationDuration: Duration(seconds: 3),
                  containerOptions: ContainerOptions(
                    width: buttonWidth + 9,
                    height: buttonHeight + 7,
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(
                      context,
                      mobile: 50,
                      tablet: 55,
                      desktop: 60,
                      largeDesktop: 65,
                      extraLargeDesktop: 70,
                    ),
                    backgroundColor: Colors.transparent,
                    borderSide: BorderSide(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 1.5,
                        tablet: 2,
                        desktop: 2.5,
                        largeDesktop: 3,
                        extraLargeDesktop: 3.5,
                      ),
                      color: Colors.black,
                    ),
                  ),
                  transitionDuration: Duration(milliseconds: 400),
                  showAnimatedBorder: true,
                  child: Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    margin: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 3,
                        tablet: 3.5,
                        desktop: 4,
                        largeDesktop: 4.5,
                        extraLargeDesktop: 5,
                      ),
                    ),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(
                            context,
                            mobile: 45,
                            tablet: 50,
                            desktop: 55,
                            largeDesktop: 60,
                            extraLargeDesktop: 65,
                          ),
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Try Sumelens',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                            largeDesktop: 22,
                            extraLargeDesktop: 24,
                          ),
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w400,
                          height: 1.09,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        'Log in',
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 15,
            desktop: 16,
            largeDesktop: 17,
            extraLargeDesktop: 18,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Custom painter for particle animation
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      // Update particle position based on animation
      final animatedX =
          (particle.x + particle.vx * animationValue * 100) % size.width;
      final animatedY =
          (particle.y + particle.vy * animationValue * 100) % size.height;

      // Draw particle
      canvas.drawCircle(Offset(animatedX, animatedY), particle.size, paint);

      // Add glow effect
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(animatedX, animatedY),
        particle.size * 2,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
