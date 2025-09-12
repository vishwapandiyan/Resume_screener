import 'package:flutter/material.dart';
import 'dart:io';

class ResponsiveUtils {
  // Breakpoints for different screen sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  // Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) return ScreenSize.mobile;
    if (width < tabletBreakpoint) return ScreenSize.tablet;
    if (width < desktopBreakpoint) return ScreenSize.desktop;
    if (width < largeDesktopBreakpoint) return ScreenSize.largeDesktop;
    return ScreenSize.extraLargeDesktop;
  }

  // Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }

  // Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.tablet;
  }

  // Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.desktop ||
        size == ScreenSize.largeDesktop ||
        size == ScreenSize.extraLargeDesktop;
  }

  // Check if current platform is web
  static bool isWeb() {
    return !Platform.isAndroid && !Platform.isIOS;
  }

  // Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(16.0);
      case ScreenSize.tablet:
        return const EdgeInsets.all(24.0);
      case ScreenSize.desktop:
        return const EdgeInsets.all(32.0);
      case ScreenSize.largeDesktop:
        return const EdgeInsets.all(40.0);
      case ScreenSize.extraLargeDesktop:
        return const EdgeInsets.all(48.0);
    }
  }

  // Get responsive horizontal padding
  static double getResponsiveHorizontalPadding(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return 20.0;
      case ScreenSize.tablet:
        return 40.0;
      case ScreenSize.desktop:
        return 60.0;
      case ScreenSize.largeDesktop:
        return 80.0;
      case ScreenSize.extraLargeDesktop:
        return 100.0;
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
    double? largeDesktop,
    double? extraLargeDesktop,
  }) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet;
      case ScreenSize.desktop:
        return desktop;
      case ScreenSize.largeDesktop:
        return largeDesktop ?? desktop;
      case ScreenSize.extraLargeDesktop:
        return extraLargeDesktop ?? largeDesktop ?? desktop;
    }
  }

  // Get responsive spacing
  static double getResponsiveSpacing(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
    double? largeDesktop,
    double? extraLargeDesktop,
  }) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet;
      case ScreenSize.desktop:
        return desktop;
      case ScreenSize.largeDesktop:
        return largeDesktop ?? desktop;
      case ScreenSize.extraLargeDesktop:
        return extraLargeDesktop ?? largeDesktop ?? desktop;
    }
  }

  // Get responsive container width
  static double getResponsiveContainerWidth(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
    double? extraLargeDesktop,
  }) {
    final screenSize = getScreenSize(context);
    final screenWidth = MediaQuery.of(context).size.width;

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile ?? screenWidth * 0.9;
      case ScreenSize.tablet:
        return tablet ?? screenWidth * 0.8;
      case ScreenSize.desktop:
        return desktop ?? screenWidth * 0.7;
      case ScreenSize.largeDesktop:
        return largeDesktop ?? screenWidth * 0.6;
      case ScreenSize.extraLargeDesktop:
        return extraLargeDesktop ?? screenWidth * 0.5;
    }
  }

  // Get responsive container height
  static double getResponsiveContainerHeight(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
    double? largeDesktop,
    double? extraLargeDesktop,
  }) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet;
      case ScreenSize.desktop:
        return desktop;
      case ScreenSize.largeDesktop:
        return largeDesktop ?? desktop;
      case ScreenSize.extraLargeDesktop:
        return extraLargeDesktop ?? largeDesktop ?? desktop;
    }
  }

  // Get responsive border radius
  static double getResponsiveBorderRadius(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
    double? largeDesktop,
    double? extraLargeDesktop,
  }) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet;
      case ScreenSize.desktop:
        return desktop;
      case ScreenSize.largeDesktop:
        return largeDesktop ?? desktop;
      case ScreenSize.extraLargeDesktop:
        return extraLargeDesktop ?? largeDesktop ?? desktop;
    }
  }

  // Get responsive icon size
  static double getResponsiveIconSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
    double? largeDesktop,
    double? extraLargeDesktop,
  }) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet;
      case ScreenSize.desktop:
        return desktop;
      case ScreenSize.largeDesktop:
        return largeDesktop ?? desktop;
      case ScreenSize.extraLargeDesktop:
        return extraLargeDesktop ?? largeDesktop ?? desktop;
    }
  }
}

enum ScreenSize { mobile, tablet, desktop, largeDesktop, extraLargeDesktop }
