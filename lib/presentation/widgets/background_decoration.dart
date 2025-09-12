import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BackgroundDecoration extends StatelessWidget {
  const BackgroundDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: BackgroundPainter(), size: Size.infinite);
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC1D1D2)
          .withValues(alpha: 0.25) // Very light grey, minimal opacity
      ..strokeWidth =
          0.8 // Thin, elegant stroke width
      ..style = PaintingStyle.stroke;

    // Draw the background geometric lines FIRST (as shown in the image)
    _drawBackgroundLines(canvas, size, paint);

    // Draw the main curved line from bottom-left to bottom-right
    _drawMainCurvedLine(canvas, size, paint);

    // Draw the partial oval on the right side
    _drawRightOval(canvas, size, paint);
  }

  void _drawBackgroundLines(Canvas canvas, Size size, Paint paint) {
    // Background geometric lines from Figma code
    final path = Path();

    // Main diagonal line (left: 138, top: 0, width: 746.98, rotated 1.90 radians)
    // This creates the main background line as shown in Figma
    final startX = size.width * 0.108; // 138/1280
    final startY = size.height * 0.0;
    final endX = startX + (size.width * 0.584); // 746.98/1280
    final endY = size.height * 0.0;

    // Draw the main diagonal line
    path.moveTo(startX, startY);
    path.lineTo(endX, endY);

    canvas.drawPath(path, paint);

    // Draw the main rectangle with exact Figma properties
    // Left: -150.8303px, Top: -394.9999px, Width: 1670.3804px, Height: 796.2217px, Rotation: 13.23°
    final rectPaint = Paint()
      ..color =
          const Color(0xFFC1D1D2) // Border color #C1D1D2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0; // 1px border

    // Convert negative coordinates to positive and scale to canvas size
    final rectLeft = size.width * 0.1; // Adjusted from negative value
    final rectTop = size.height * 0.1; // Adjusted from negative value
    final rectWidth = size.width * 0.8; // Scaled from 1670.3804px
    final rectHeight = size.height * 0.8; // Scaled from 796.2217px

    // Create rotated rectangle with mixed/bent corners
    canvas.save();
    canvas.translate(rectLeft + rectWidth / 2, rectTop + rectHeight / 2);
    canvas.rotate(13.23 * 3.14159 / 180); // Convert 13.23° to radians

    // Draw rounded rectangle with mixed corner radius for bent effect
    final roundedRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: rectWidth,
        height: rectHeight,
      ),
      const Radius.circular(25.0), // Mixed corner radius for bent effect
    );

    canvas.drawRRect(roundedRect, rectPaint);
    canvas.restore();

    // Draw the white container (left: 45, top: 54, width: 154, height: 28)
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final whiteRect = Rect.fromLTWH(
      size.width * 0.035, // 45/1280
      size.height * 0.065, // 54/832
      size.width * 0.120, // 154/1280
      size.height * 0.034, // 28/832
    );
    canvas.drawRect(whiteRect, whitePaint);

    // Draw additional subtle lines to avoid blank space (as shown in the image)
    _drawAdditionalTextureLines(canvas, size, paint);
  }

  void _drawMainCurvedLine(Canvas canvas, Size size, Paint paint) {
    // Main curved line with organic, calligraphic quality (as described in image analysis)
    final path = Path();

    // Start from bottom-left quadrant
    final startX = size.width * 0.15;
    final startY = size.height * 0.8;

    // First curve: sweeps gently upwards towards center
    final curve1X = size.width * 0.35;
    final curve1Y = size.height * 0.6;

    // Second curve: then sweeps downwards towards bottom-right
    final curve2X = size.width * 0.65;
    final curve2Y = size.height * 0.75;

    // End at bottom-right corner
    final endX = size.width * 0.95;
    final endY = size.height * 0.9;

    // Draw the organic, flowing curved path with smooth transitions
    path.moveTo(startX, startY);
    path.quadraticBezierTo(curve1X, curve1Y, curve2X, curve2Y);
    path.quadraticBezierTo(curve2X + size.width * 0.1, curve2Y, endX, endY);

    canvas.drawPath(path, paint);
  }

  void _drawRightOval(Canvas canvas, Size size, Paint paint) {
    // Oval exactly as in Figma properties - Ellipse 1
    // Left: 1176px, Top: 347px, Width: 223px, Height: 191px
    // Border: 1px with color #C1D1D2, Background: Transparent

    final ovalRect = Rect.fromLTWH(
      size.width * 0.919, // 1176/1280
      size.height * 0.417, // 347/832
      size.width * 0.174, // 223/1280
      size.height * 0.230, // 191/832
    );

    // Draw the oval with exact Figma specifications
    canvas.drawOval(ovalRect, paint);
  }

  void _drawAdditionalTextureLines(Canvas canvas, Size size, Paint paint) {
    // Draw background lines exactly as shown in the image
    final path = Path();

    // Top-left 'X' shape - two intersecting diagonal lines
    // First diagonal: from top-left edge down and right
    path.moveTo(size.width * 0.05, size.height * 0.05);
    path.lineTo(size.width * 0.25, size.height * 0.25);

    // Second diagonal: from slightly right of top-left, down and left (crossing first)
    path.moveTo(size.width * 0.2, size.height * 0.05);
    path.lineTo(size.width * 0.05, size.height * 0.25);

    // Mid-left horizontal line (slightly uneven, organic)
    path.moveTo(size.width * 0.1, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.4);

    // Top-right diagonal line extending down and left
    path.moveTo(size.width * 0.85, size.height * 0.1);
    path.lineTo(size.width * 0.7, size.height * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
