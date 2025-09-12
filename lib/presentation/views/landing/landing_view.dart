import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: isMobile ? screenSize.width : 1280,
              height: isMobile ? screenSize.height : 832,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  // Try Clauselens button
                  Positioned(
                    left: isMobile ? screenSize.width * 0.1 : 486,
                    top: isMobile ? screenSize.height * 0.5 : 443,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ),
                        );
                      },
                      child: Container(
                        width: isMobile ? screenSize.width * 0.8 : 289,
                        height: isMobile ? 60 : 71,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-0.00, 0.51),
                            end: Alignment(1.00, 0.51),
                            colors: [
                              const Color(0xFF4285F4),
                              const Color(0xFFEA4335),
                              const Color(0xFFFBBC04),
                              const Color(0xFF34A853),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // White overlay
                            Positioned(
                              left: 3,
                              top: 3,
                              child: Container(
                                width: isMobile
                                    ? screenSize.width * 0.8 - 6
                                    : 280.58,
                                height: isMobile ? 54 : 64.37,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                            ),
                            // Try Clauselens text
                            Center(
                              child: Text(
                                'Try Clauselens',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: isMobile ? 18 : 22,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w400,
                                  height: 1.09,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Legal Documents text
                  Positioned(
                    left: isMobile ? 20 : 214,
                    top: isMobile ? 100 : 265,
                    child: Text(
                      'Legal Documents ',
                      style: TextStyle(
                        color: const Color(0xFF202124),
                        fontSize: isMobile ? 32 : 62,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w600,
                        height: 0.39,
                      ),
                    ),
                  ),
                  // Simplified text
                  Positioned(
                    left: isMobile ? 20 : 747,
                    top: isMobile ? 140 : 265,
                    child: Text(
                      'Simplified..',
                      style: TextStyle(
                        color: const Color(0xFF4285F4),
                        fontSize: isMobile ? 32 : 62,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w600,
                        height: 0.39,
                      ),
                    ),
                  ),
                  // Description text 1
                  Positioned(
                    left: isMobile ? 20 : 209,
                    top: isMobile ? 180 : 335,
                    child: SizedBox(
                      width: isMobile ? screenSize.width - 40 : 863,
                      height: isMobile ? 60 : 31,
                      child: Text(
                        'SumeLens: AI-powered talent matching system, screening resumes and matching candidates ',
                        style: TextStyle(
                          color: const Color(0xFF8A9096),
                          fontSize: isMobile ? 16 : 25,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w400,
                          height: 0.96,
                        ),
                        textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      ),
                    ),
                  ),
                  // Description text 2
                  Positioned(
                    left: isMobile ? screenSize.width * 0.5 - 119 : 521.76,
                    top: isMobile ? 240 : 372,
                    child: SizedBox(
                      width: isMobile ? 238 : 238.54,
                      height: isMobile ? 40 : 28,
                      child: Text(
                        'with job opportunities, ensuring fairness and eliminating bias.',
                        style: TextStyle(
                          color: const Color(0xFF8A9096),
                          fontSize: isMobile ? 16 : 25,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w400,
                          height: 0.96,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Decorative oval
                  Positioned(
                    left: isMobile ? screenSize.width - 120 : 1176,
                    top: isMobile ? 200 : 347,
                    child: Container(
                      width: isMobile ? 100 : 223,
                      height: isMobile ? 80 : 191,
                      decoration: ShapeDecoration(
                        color: const Color(0x00D9D9D9),
                        shape: OvalBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFC1D1D2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // About us text
                  Positioned(
                    left: isMobile ? screenSize.width * 0.5 - 40 : 932,
                    top: isMobile ? 50 : 57,
                    child: Text(
                      'About us ',
                      style: TextStyle(
                        color: const Color(0xFF202124),
                        fontSize: isMobile ? 14 : 16,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
                  ),
                  // Contact Us text
                  Positioned(
                    left: isMobile ? screenSize.width * 0.5 + 20 : 1026,
                    top: isMobile ? 50 : 57,
                    child: Text(
                      'Contact Us',
                      style: TextStyle(
                        color: const Color(0xFF202124),
                        fontSize: isMobile ? 14 : 16,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
                  ),
                  // Login button
                  Positioned(
                    left: isMobile ? screenSize.width - 80 : 1134,
                    top: isMobile ? 40 : 49,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ),
                        );
                      },
                      child: Container(
                        width: isMobile ? 70 : 102,
                        height: isMobile ? 30 : 37,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-0.00, 0.51),
                            end: Alignment(1.00, 0.51),
                            colors: [
                              const Color(0xFF174EA6),
                              const Color(0xFFA50E0E),
                              const Color(0xFFE37400),
                              const Color(0xFF0D652D),
                              const Color(0xFF202124),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // White overlay
                            Positioned(
                              left: 3,
                              top: 3,
                              child: Container(
                                width: isMobile ? 64 : 96,
                                height: isMobile ? 24 : 31,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                ),
                              ),
                            ),
                            // Login text
                            Center(
                              child: Text(
                                'Log in ',
                                style: TextStyle(
                                  color: const Color(0xFF202124),
                                  fontSize: isMobile ? 10 : 14,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w500,
                                  height: 1.71,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Decorative line
                  Positioned(
                    left: isMobile ? 20 : 138,
                    top: isMobile ? 20 : 0,
                    child: Container(
                      transform: Matrix4.identity()
                        ..translate(0.0, 0.0)
                        ..rotateZ(1.90),
                      width: isMobile ? screenSize.width - 40 : 746.98,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: const Color(0xFFC1D1D2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Logo background
                  Positioned(
                    left: isMobile ? 20 : 45,
                    top: isMobile ? 50 : 54,
                    child: Container(
                      width: isMobile ? 120 : 154,
                      height: isMobile ? 24 : 28,
                      decoration: BoxDecoration(color: Colors.white),
                    ),
                  ),
                  // Logo image
                  Positioned(
                    left: isMobile ? 20 : 45,
                    top: isMobile ? 50 : 50,
                    child: Container(
                      width: isMobile ? 120 : 158,
                      height: isMobile ? 28 : 37,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage("https://placehold.co/158x37"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
