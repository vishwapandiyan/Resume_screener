import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class ResponsiveTheme {
  // Responsive text styles
  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    required TextStyle baseStyle,
    double? mobileScale = 0.8,
    double? tabletScale = 0.9,
    double? desktopScale = 1.0,
    double? largeDesktopScale = 1.1,
    double? extraLargeDesktopScale = 1.2,
  }) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    double scale = 1.0;

    switch (screenSize) {
      case ScreenSize.mobile:
        scale = mobileScale ?? 0.8;
        break;
      case ScreenSize.tablet:
        scale = tabletScale ?? 0.9;
        break;
      case ScreenSize.desktop:
        scale = desktopScale ?? 1.0;
        break;
      case ScreenSize.largeDesktop:
        scale = largeDesktopScale ?? 1.1;
        break;
      case ScreenSize.extraLargeDesktop:
        scale = extraLargeDesktopScale ?? 1.2;
        break;
    }

    return baseStyle.copyWith(
      fontSize: baseStyle.fontSize != null ? baseStyle.fontSize! * scale : null,
      height: baseStyle.height != null ? baseStyle.height! * scale : null,
      letterSpacing: baseStyle.letterSpacing != null
          ? baseStyle.letterSpacing! * scale
          : null,
    );
  }

  // Responsive spacing
  static double getResponsiveSpacing(
    BuildContext context, {
    required double baseSpacing,
    double? mobileScale = 0.8,
    double? tabletScale = 0.9,
    double? desktopScale = 1.0,
    double? largeDesktopScale = 1.1,
    double? extraLargeDesktopScale = 1.2,
  }) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    double scale = 1.0;

    switch (screenSize) {
      case ScreenSize.mobile:
        scale = mobileScale ?? 0.8;
        break;
      case ScreenSize.tablet:
        scale = tabletScale ?? 0.9;
        break;
      case ScreenSize.desktop:
        scale = desktopScale ?? 1.0;
        break;
      case ScreenSize.largeDesktop:
        scale = largeDesktopScale ?? 1.1;
        break;
      case ScreenSize.extraLargeDesktop:
        scale = extraLargeDesktopScale ?? 1.2;
        break;
    }

    return baseSpacing * scale;
  }

  // Responsive padding
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    required EdgeInsets basePadding,
    double? mobileScale = 0.8,
    double? tabletScale = 0.9,
    double? desktopScale = 1.0,
    double? largeDesktopScale = 1.1,
    double? extraLargeDesktopScale = 1.2,
  }) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    double scale = 1.0;

    switch (screenSize) {
      case ScreenSize.mobile:
        scale = mobileScale ?? 0.8;
        break;
      case ScreenSize.tablet:
        scale = tabletScale ?? 0.9;
        break;
      case ScreenSize.desktop:
        scale = desktopScale ?? 1.0;
        break;
      case ScreenSize.largeDesktop:
        scale = largeDesktopScale ?? 1.1;
        break;
      case ScreenSize.extraLargeDesktop:
        scale = extraLargeDesktopScale ?? 1.2;
        break;
    }

    return EdgeInsets.only(
      left: basePadding.left * scale,
      top: basePadding.top * scale,
      right: basePadding.right * scale,
      bottom: basePadding.bottom * scale,
    );
  }

  // Responsive margin
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    required EdgeInsets baseMargin,
    double? mobileScale = 0.8,
    double? tabletScale = 0.9,
    double? desktopScale = 1.0,
    double? largeDesktopScale = 1.1,
    double? extraLargeDesktopScale = 1.2,
  }) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    double scale = 1.0;

    switch (screenSize) {
      case ScreenSize.mobile:
        scale = mobileScale ?? 0.8;
        break;
      case ScreenSize.tablet:
        scale = tabletScale ?? 0.9;
        break;
      case ScreenSize.desktop:
        scale = desktopScale ?? 1.0;
        break;
      case ScreenSize.largeDesktop:
        scale = largeDesktopScale ?? 1.1;
        break;
      case ScreenSize.extraLargeDesktop:
        scale = extraLargeDesktopScale ?? 1.2;
        break;
    }

    return EdgeInsets.only(
      left: baseMargin.left * scale,
      top: baseMargin.top * scale,
      right: baseMargin.right * scale,
      bottom: baseMargin.bottom * scale,
    );
  }

  // Responsive border radius
  static double getResponsiveBorderRadius(
    BuildContext context, {
    required double baseRadius,
    double? mobileScale = 0.8,
    double? tabletScale = 0.9,
    double? desktopScale = 1.0,
    double? largeDesktopScale = 1.1,
    double? extraLargeDesktopScale = 1.2,
  }) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    double scale = 1.0;

    switch (screenSize) {
      case ScreenSize.mobile:
        scale = mobileScale ?? 0.8;
        break;
      case ScreenSize.tablet:
        scale = tabletScale ?? 0.9;
        break;
      case ScreenSize.desktop:
        scale = desktopScale ?? 1.0;
        break;
      case ScreenSize.largeDesktop:
        scale = largeDesktopScale ?? 1.1;
        break;
      case ScreenSize.extraLargeDesktop:
        scale = extraLargeDesktopScale ?? 1.2;
        break;
    }

    return baseRadius * scale;
  }

  // Responsive icon size
  static double getResponsiveIconSize(
    BuildContext context, {
    required double baseSize,
    double? mobileScale = 0.8,
    double? tabletScale = 0.9,
    double? desktopScale = 1.0,
    double? largeDesktopScale = 1.1,
    double? extraLargeDesktopScale = 1.2,
  }) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    double scale = 1.0;

    switch (screenSize) {
      case ScreenSize.mobile:
        scale = mobileScale ?? 0.8;
        break;
      case ScreenSize.tablet:
        scale = tabletScale ?? 0.9;
        break;
      case ScreenSize.desktop:
        scale = desktopScale ?? 1.0;
        break;
      case ScreenSize.largeDesktop:
        scale = largeDesktopScale ?? 1.1;
        break;
      case ScreenSize.extraLargeDesktop:
        scale = extraLargeDesktopScale ?? 1.2;
        break;
    }

    return baseSize * scale;
  }

  // Responsive container constraints
  static BoxConstraints getResponsiveConstraints(
    BuildContext context, {
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
    double? mobileWidthScale = 0.9,
    double? tabletWidthScale = 0.8,
    double? desktopWidthScale = 0.7,
    double? largeDesktopWidthScale = 0.6,
    double? extraLargeDesktopWidthScale = 0.5,
  }) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double widthScale = 1.0;
    double heightScale = 1.0;

    switch (screenSize) {
      case ScreenSize.mobile:
        widthScale = mobileWidthScale ?? 0.9;
        heightScale = 0.9;
        break;
      case ScreenSize.tablet:
        widthScale = tabletWidthScale ?? 0.8;
        heightScale = 0.85;
        break;
      case ScreenSize.desktop:
        widthScale = desktopWidthScale ?? 0.7;
        heightScale = 1.0;
        break;
      case ScreenSize.largeDesktop:
        widthScale = largeDesktopWidthScale ?? 0.6;
        heightScale = 1.0;
        break;
      case ScreenSize.extraLargeDesktop:
        widthScale = extraLargeDesktopWidthScale ?? 0.5;
        heightScale = 1.0;
        break;
    }

    return BoxConstraints(
      minWidth: minWidth ?? 0,
      maxWidth: maxWidth ?? screenWidth * widthScale,
      minHeight: minHeight ?? 0,
      maxHeight: maxHeight ?? screenHeight * heightScale,
    );
  }

  // Responsive elevation
  static double getResponsiveElevation(
    BuildContext context, {
    required double baseElevation,
    double? mobileScale = 0.8,
    double? tabletScale = 0.9,
    double? desktopScale = 1.0,
    double? largeDesktopScale = 1.1,
    double? extraLargeDesktopScale = 1.2,
  }) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    double scale = 1.0;

    switch (screenSize) {
      case ScreenSize.mobile:
        scale = mobileScale ?? 0.8;
        break;
      case ScreenSize.tablet:
        scale = tabletScale ?? 0.9;
        break;
      case ScreenSize.desktop:
        scale = desktopScale ?? 1.0;
        break;
      case ScreenSize.largeDesktop:
        scale = largeDesktopScale ?? 1.1;
        break;
      case ScreenSize.extraLargeDesktop:
        scale = extraLargeDesktopScale ?? 1.2;
        break;
    }

    return baseElevation * scale;
  }

  // Platform-specific adjustments
  static bool isWeb() {
    return ResponsiveUtils.isWeb();
  }

  static bool isMobile() {
    return false; // This should be called with context
  }

  static bool isTablet() {
    return false; // This should be called with context
  }

  static bool isDesktop() {
    return false; // This should be called with context
  }

  // Get platform-specific theme adjustments
  static Map<String, dynamic> getPlatformAdjustments(BuildContext context) {
    final isWebPlatform = isWeb();
    final screenSize = ResponsiveUtils.getScreenSize(context);

    if (isWebPlatform) {
      return {
        'cursorWidth': 2.0,
        'scrollbarTheme': ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(
            Colors.grey.withValues(alpha: 0.5),
          ),
          trackColor: MaterialStateProperty.all(
            Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      };
    } else {
      return {'cursorWidth': 1.0};
    }
  }
}
