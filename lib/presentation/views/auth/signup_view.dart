import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../controllers/auth_controller.dart';
// import '../workspace_dashboard_view.dart'; // Temporarily commented out

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  late AnimationController _gradientAnimationController;

  @override
  void initState() {
    super.initState();
    _gradientAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _gradientAnimationController.repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _gradientAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('assets/images/img_1.png', fit: BoxFit.cover),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  _buildLogo(),

                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 20,
                      tablet: 25,
                      desktop: 30,
                      largeDesktop: 35,
                      extraLargeDesktop: 40,
                    ),
                  ),

                  // Signup Form
                  _buildSignupForm(),

                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 20,
                      tablet: 25,
                      desktop: 30,
                      largeDesktop: 35,
                      extraLargeDesktop: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final logoSize = ResponsiveUtils.getResponsiveContainerWidth(
          context,
          mobile: 120,
          tablet: 140,
          desktop: 160,
          largeDesktop: 180,
          extraLargeDesktop: 200,
        );

        return Container(
          width: logoSize,
          height: logoSize * 0.6, // Maintain aspect ratio
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Image.asset(
            'assets/images/img.png',
            width: logoSize,
            height: logoSize * 0.6,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  Widget _buildSignupForm() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final containerWidth = ResponsiveUtils.getResponsiveContainerWidth(
          context,
          mobile: MediaQuery.of(context).size.width * 0.9,
          tablet: MediaQuery.of(context).size.width * 0.8,
          desktop: 627.44,
          largeDesktop: 700,
          extraLargeDesktop: 800,
        );

        final containerHeight = ResponsiveUtils.getResponsiveContainerHeight(
          context,
          mobile: 600.0,
          tablet: 630.0,
          desktop: 660.0,
          largeDesktop: 680,
          extraLargeDesktop: 700,
        );

        return Center(
          child: GlowContainer(
            gradientColors: [
              const Color(0xFF4285F4),
              const Color(0xFFEA4335),
              const Color(0xFFFBBC04),
              const Color(0xFF34A853),
            ],
            rotationDuration: Duration(seconds: 4),
            glowRadius: ResponsiveUtils.getResponsiveSpacing(
              context,
              mobile: 3,
              tablet: 4,
              desktop: 5,
              largeDesktop: 6,
              extraLargeDesktop: 7,
            ),
            containerOptions: ContainerOptions(
              width: containerWidth,
              height: containerHeight,
              borderRadius: ResponsiveUtils.getResponsiveBorderRadius(
                context,
                mobile: 10,
                tablet: 12,
                desktop: 15,
                largeDesktop: 18,
                extraLargeDesktop: 20,
              ),
              backgroundColor: Colors.white,
            ),
            child: Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 20,
                  tablet: 24,
                  desktop: 28,
                  largeDesktop: 32,
                  extraLargeDesktop: 36,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'Join SumeLens',
                      style: TextStyle(
                        color: const Color(0xFF515151),
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 20,
                          tablet: 24,
                          desktop: 28,
                          largeDesktop: 32,
                          extraLargeDesktop: 36,
                        ),
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                        largeDesktop: 22,
                        extraLargeDesktop: 24,
                      ),
                    ),

                    // Google Signup Button
                    _buildGoogleButton(),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                        largeDesktop: 18,
                        extraLargeDesktop: 20,
                      ),
                    ),

                    // Separator
                    _buildSeparator(),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                        largeDesktop: 22,
                        extraLargeDesktop: 24,
                      ),
                    ),

                    // Name Field
                    _buildNameField(),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                        largeDesktop: 18,
                        extraLargeDesktop: 20,
                      ),
                    ),

                    // Email Field
                    _buildEmailField(),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                        largeDesktop: 18,
                        extraLargeDesktop: 20,
                      ),
                    ),

                    // Password Field
                    _buildPasswordField(),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                        largeDesktop: 18,
                        extraLargeDesktop: 20,
                      ),
                    ),

                    // Confirm Password Field
                    _buildConfirmPasswordField(),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                        largeDesktop: 18,
                        extraLargeDesktop: 20,
                      ),
                    ),

                    // Terms and Conditions
                    _buildTermsAndConditions(),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                        largeDesktop: 22,
                        extraLargeDesktop: 24,
                      ),
                    ),

                    // Signup Button
                    _buildSignupButton(),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                        largeDesktop: 14,
                        extraLargeDesktop: 16,
                      ),
                    ),

                    // Login Navigation
                    _buildLoginNavigation(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleButton() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final buttonWidth = ResponsiveUtils.getResponsiveContainerWidth(
          context,
          mobile: double.infinity,
          tablet: MediaQuery.of(context).size.width * 0.6,
          desktop: 420,
          largeDesktop: 450,
          extraLargeDesktop: 480,
        );

        return Consumer<AuthController>(
          builder: (context, authController, child) {
            // Handle authentication state changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (authController.authState.isAuthenticated) {
                // Navigate to dashboard after successful signup
                Navigator.of(context).pushReplacementNamed('/dashboard');
              } else if (authController.authState.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      authController.authState.errorMessage ??
                          'Google sign-up failed',
                    ),
                  ),
                );
              }
            });

            return GestureDetector(
              onTap: () async {
                await authController.signInWithGoogle();
              },
              child: Container(
                width: buttonWidth,
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 8,
                    tablet: 9,
                    desktop: 10,
                    largeDesktop: 11,
                    extraLargeDesktop: 12,
                  ),
                ),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFE7E7E7)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Logo
                    Container(
                      width: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        mobile: 20,
                        tablet: 22,
                        desktop: 25,
                        largeDesktop: 28,
                        extraLargeDesktop: 30,
                      ),
                      height: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        mobile: 20,
                        tablet: 22,
                        desktop: 25,
                        largeDesktop: 28,
                        extraLargeDesktop: 30,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        'assets/images/Screenshot 2025-08-26 113658.png',
                        width: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          mobile: 20,
                          tablet: 22,
                          desktop: 25,
                          largeDesktop: 28,
                          extraLargeDesktop: 30,
                        ),
                        height: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          mobile: 20,
                          tablet: 22,
                          desktop: 25,
                          largeDesktop: 28,
                          extraLargeDesktop: 30,
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 10,
                        tablet: 11,
                        desktop: 13,
                        largeDesktop: 15,
                        extraLargeDesktop: 17,
                      ),
                    ),
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: const Color(0xFF828282),
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                          largeDesktop: 15,
                          extraLargeDesktop: 16,
                        ),
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSeparator() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '-------------',
            style: TextStyle(
              color: const Color(0xFFDDDDDD),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 10,
                tablet: 11,
                desktop: 12,
                largeDesktop: 13,
                extraLargeDesktop: 14,
              ),
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: ' or Sign up with Email ',
            style: TextStyle(
              color: const Color(0xFFA1A1A1),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 10,
                tablet: 11,
                desktop: 12,
                largeDesktop: 13,
                extraLargeDesktop: 14,
              ),
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: '-------------',
            style: TextStyle(
              color: const Color(0xFFDDDDDD),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 10,
                tablet: 11,
                desktop: 12,
                largeDesktop: 13,
                extraLargeDesktop: 14,
              ),
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final fieldWidth = ResponsiveUtils.getResponsiveContainerWidth(
          context,
          mobile: double.infinity,
          tablet: MediaQuery.of(context).size.width * 0.5,
          desktop: 320,
          largeDesktop: 350,
          extraLargeDesktop: 380,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Full Name',
              style: TextStyle(
                color: const Color(0xFF828282),
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                  largeDesktop: 15,
                  extraLargeDesktop: 16,
                ),
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 6,
                tablet: 7,
                desktop: 8,
                largeDesktop: 9,
                extraLargeDesktop: 10,
              ),
            ),
            Container(
              width: fieldWidth,
              height: ResponsiveUtils.getResponsiveContainerHeight(
                context,
                mobile: 48,
                tablet: 50,
                desktop: 52,
                largeDesktop: 54,
                extraLargeDesktop: 56,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 10,
                  tablet: 11,
                  desktop: 12,
                  largeDesktop: 13,
                  extraLargeDesktop: 14,
                ),
                vertical: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 9,
                  desktop: 10,
                  largeDesktop: 11,
                  extraLargeDesktop: 12,
                ),
              ),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFDED2D9)),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  hintStyle: TextStyle(
                    color: const Color(0xFFE0E0E0),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                      largeDesktop: 15,
                      extraLargeDesktop: 16,
                    ),
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmailField() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final fieldWidth = ResponsiveUtils.getResponsiveContainerWidth(
          context,
          mobile: double.infinity,
          tablet: MediaQuery.of(context).size.width * 0.5,
          desktop: 320,
          largeDesktop: 350,
          extraLargeDesktop: 380,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email',
              style: TextStyle(
                color: const Color(0xFF828282),
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                  largeDesktop: 15,
                  extraLargeDesktop: 16,
                ),
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 6,
                tablet: 7,
                desktop: 8,
                largeDesktop: 9,
                extraLargeDesktop: 10,
              ),
            ),
            Container(
              width: fieldWidth,
              height: ResponsiveUtils.getResponsiveContainerHeight(
                context,
                mobile: 48,
                tablet: 50,
                desktop: 52,
                largeDesktop: 54,
                extraLargeDesktop: 56,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 10,
                  tablet: 11,
                  desktop: 12,
                  largeDesktop: 13,
                  extraLargeDesktop: 14,
                ),
                vertical: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 9,
                  desktop: 10,
                  largeDesktop: 11,
                  extraLargeDesktop: 12,
                ),
              ),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFDED2D9)),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'mail@abc.com',
                  hintStyle: TextStyle(
                    color: const Color(0xFFE0E0E0),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                      largeDesktop: 15,
                      extraLargeDesktop: 16,
                    ),
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final fieldWidth = ResponsiveUtils.getResponsiveContainerWidth(
          context,
          mobile: double.infinity,
          tablet: MediaQuery.of(context).size.width * 0.5,
          desktop: 320,
          largeDesktop: 350,
          extraLargeDesktop: 380,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password',
              style: TextStyle(
                color: const Color(0xFF828282),
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                  largeDesktop: 15,
                  extraLargeDesktop: 16,
                ),
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 6,
                tablet: 7,
                desktop: 8,
                largeDesktop: 9,
                extraLargeDesktop: 10,
              ),
            ),
            Container(
              width: fieldWidth,
              height: ResponsiveUtils.getResponsiveContainerHeight(
                context,
                mobile: 48,
                tablet: 50,
                desktop: 52,
                largeDesktop: 54,
                extraLargeDesktop: 56,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 10,
                  tablet: 11,
                  desktop: 12,
                  largeDesktop: 13,
                  extraLargeDesktop: 14,
                ),
                vertical: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 9,
                  desktop: 10,
                  largeDesktop: 11,
                  extraLargeDesktop: 12,
                ),
              ),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFDED2D9)),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '*****************',
                  hintStyle: TextStyle(
                    color: const Color(0xFFE0E0E0),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 10,
                      tablet: 11,
                      desktop: 12,
                      largeDesktop: 13,
                      extraLargeDesktop: 14,
                    ),
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final fieldWidth = ResponsiveUtils.getResponsiveContainerWidth(
          context,
          mobile: double.infinity,
          tablet: MediaQuery.of(context).size.width * 0.5,
          desktop: 320,
          largeDesktop: 350,
          extraLargeDesktop: 380,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm Password',
              style: TextStyle(
                color: const Color(0xFF828282),
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                  largeDesktop: 15,
                  extraLargeDesktop: 16,
                ),
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 6,
                tablet: 7,
                desktop: 8,
                largeDesktop: 9,
                extraLargeDesktop: 10,
              ),
            ),
            Container(
              width: fieldWidth,
              height: ResponsiveUtils.getResponsiveContainerHeight(
                context,
                mobile: 48,
                tablet: 50,
                desktop: 52,
                largeDesktop: 54,
                extraLargeDesktop: 56,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 10,
                  tablet: 11,
                  desktop: 12,
                  largeDesktop: 13,
                  extraLargeDesktop: 14,
                ),
                vertical: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 9,
                  desktop: 10,
                  largeDesktop: 11,
                  extraLargeDesktop: 12,
                ),
              ),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFDED2D9)),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '*****************',
                  hintStyle: TextStyle(
                    color: const Color(0xFFE0E0E0),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 10,
                      tablet: 11,
                      desktop: 12,
                      largeDesktop: 13,
                      extraLargeDesktop: 14,
                    ),
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTermsAndConditions() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        return Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _agreeToTerms = !_agreeToTerms;
                });
              },
              child: Container(
                width: ResponsiveUtils.getResponsiveIconSize(
                  context,
                  mobile: 10,
                  tablet: 11,
                  desktop: 12,
                  largeDesktop: 13,
                  extraLargeDesktop: 14,
                ),
                height: ResponsiveUtils.getResponsiveIconSize(
                  context,
                  mobile: 10,
                  tablet: 11,
                  desktop: 12,
                  largeDesktop: 13,
                  extraLargeDesktop: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF202124),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(width: 2, color: const Color(0xFF202124)),
                ),
                child: _agreeToTerms
                    ? Icon(
                        Icons.check,
                        size: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          mobile: 6,
                          tablet: 7,
                          desktop: 8,
                          largeDesktop: 9,
                          extraLargeDesktop: 10,
                        ),
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 6,
                tablet: 7,
                desktop: 8,
                largeDesktop: 9,
                extraLargeDesktop: 10,
              ),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(
                        color: const Color(0xFFA1A1A1),
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 10,
                          tablet: 11,
                          desktop: 12,
                          largeDesktop: 13,
                          extraLargeDesktop: 14,
                        ),
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(
                        color: const Color(0xFF202124),
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 10,
                          tablet: 11,
                          desktop: 12,
                          largeDesktop: 13,
                          extraLargeDesktop: 14,
                        ),
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignupButton() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final buttonWidth = ResponsiveUtils.getResponsiveContainerWidth(
          context,
          mobile: double.infinity,
          tablet: MediaQuery.of(context).size.width * 0.6,
          desktop: 420,
          largeDesktop: 450,
          extraLargeDesktop: 480,
        );

        return Consumer<AuthController>(
          builder: (context, authController, child) {
            // Handle authentication state changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (authController.authState.isAuthenticated) {
                // Navigate to dashboard after successful signup
                Navigator.of(context).pushReplacementNamed('/dashboard');
              } else if (authController.authState.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      authController.authState.errorMessage ?? 'Sign up failed',
                    ),
                  ),
                );
              }
            });

            return GestureDetector(
              onTap: () async {
                // Validation
                if (_nameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                    _passwordController.text.isEmpty ||
                    _confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                if (_passwordController.text !=
                    _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                if (!_agreeToTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please agree to the Terms & Conditions'),
                    ),
                  );
                  return;
                }

                await authController.signUp(
                  _emailController.text.trim(),
                  _passwordController.text,
                  _nameController.text.trim(),
                );
              },
              child: Container(
                width: buttonWidth,
                padding: EdgeInsets.only(
                  top: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 11,
                    tablet: 12,
                    desktop: 13,
                    largeDesktop: 14,
                    extraLargeDesktop: 15,
                  ),
                  left: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 8,
                    tablet: 9,
                    desktop: 10,
                    largeDesktop: 11,
                    extraLargeDesktop: 12,
                  ),
                  right: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 8,
                    tablet: 9,
                    desktop: 10,
                    largeDesktop: 11,
                    extraLargeDesktop: 12,
                  ),
                  bottom: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 10,
                    tablet: 11,
                    desktop: 12,
                    largeDesktop: 13,
                    extraLargeDesktop: 14,
                  ),
                ),
                decoration: ShapeDecoration(
                  color: const Color(0xFF202124),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(
                        context,
                        mobile: 4,
                        tablet: 5,
                        desktop: 6,
                        largeDesktop: 7,
                        extraLargeDesktop: 8,
                      ),
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                        largeDesktop: 17,
                        extraLargeDesktop: 18,
                      ),
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoginNavigation() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(
                color: const Color(0xFFA1A1A1),
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                  largeDesktop: 15,
                  extraLargeDesktop: 16,
                ),
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                'Login',
                style: TextStyle(
                  color: const Color(0xFF202124),
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                    largeDesktop: 15,
                    extraLargeDesktop: 16,
                  ),
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
