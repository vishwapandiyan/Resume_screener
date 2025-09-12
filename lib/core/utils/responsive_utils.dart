import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ResponsiveUtils {
  // Breakpoints for different screen sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  // Web-specific breakpoints
  static const double webMobileBreakpoint = 768;
  static const double webTabletBreakpoint = 1024;
  static const double webDesktopBreakpoint = 1440;

  // Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Use web-specific breakpoints for web platform
    if (kIsWeb) {
      if (width < webMobileBreakpoint) return ScreenSize.mobile;
      if (width < webTabletBreakpoint) return ScreenSize.tablet;
      if (width < webDesktopBreakpoint) return ScreenSize.desktop;
      return ScreenSize.largeDesktop;
    }

    // Use mobile-specific breakpoints for mobile platforms
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
    return kIsWeb;
  }

  // Check if current platform is mobile (iOS/Android)
  static bool isMobilePlatform() {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  // Check if current platform is desktop
  static bool isDesktopPlatform() {
    return !kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
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

  // Get responsive grid columns for different screen sizes
  static int getResponsiveGridColumns(BuildContext context) {
    final screenSize = getScreenSize(context);
    final isWeb = ResponsiveUtils.isWeb();

    if (isWeb) {
      switch (screenSize) {
        case ScreenSize.mobile:
          return 1;
        case ScreenSize.tablet:
          return 2;
        case ScreenSize.desktop:
          return 3;
        case ScreenSize.largeDesktop:
          return 4;
        case ScreenSize.extraLargeDesktop:
          return 5;
      }
    } else {
      switch (screenSize) {
        case ScreenSize.mobile:
          return 1;
        case ScreenSize.tablet:
          return 2;
        case ScreenSize.desktop:
          return 3;
        case ScreenSize.largeDesktop:
        case ScreenSize.extraLargeDesktop:
          return 4;
      }
    }
  }

  // Get responsive aspect ratio for grid items
  static double getResponsiveAspectRatio(BuildContext context) {
    final screenSize = getScreenSize(context);
    final isWeb = ResponsiveUtils.isWeb();

    if (isWeb) {
      switch (screenSize) {
        case ScreenSize.mobile:
          return 1.2;
        case ScreenSize.tablet:
          return 1.1;
        case ScreenSize.desktop:
          return 1.0;
        case ScreenSize.largeDesktop:
          return 0.9;
        case ScreenSize.extraLargeDesktop:
          return 0.8;
      }
    } else {
      switch (screenSize) {
        case ScreenSize.mobile:
          return 1.2;
        case ScreenSize.tablet:
          return 1.1;
        case ScreenSize.desktop:
          return 1.0;
        case ScreenSize.largeDesktop:
        case ScreenSize.extraLargeDesktop:
          return 0.9;
      }
    }
  }

  // Get responsive sidebar width for web
  static double getResponsiveSidebarWidth(BuildContext context) {
    if (!isWeb()) return 0;

    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return MediaQuery.of(context).size.width * 0.8;
      case ScreenSize.tablet:
        return 280;
      case ScreenSize.desktop:
        return 320;
      case ScreenSize.largeDesktop:
        return 360;
      case ScreenSize.extraLargeDesktop:
        return 400;
    }
  }

  // Get responsive content max width for web
  static double getResponsiveContentMaxWidth(BuildContext context) {
    if (!isWeb()) return double.infinity;

    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return 800;
      case ScreenSize.desktop:
        return 1200;
      case ScreenSize.largeDesktop:
        return 1400;
      case ScreenSize.extraLargeDesktop:
        return 1600;
    }
  }

  /// Check if horizontal space is limited and should use vertical scrolling
  static bool shouldUseVerticalScrolling(
    BuildContext context, {
    double? minWidth,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final requiredWidth = minWidth ?? 600.0; // Default minimum width

    return screenWidth < requiredWidth;
  }

  /// Get responsive horizontal spacing with fallback to vertical
  static double getResponsiveHorizontalSpacing(
    BuildContext context, {
    double? minWidth,
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) {
    if (shouldUseVerticalScrolling(context, minWidth: minWidth)) {
      return 0.0; // No horizontal spacing when using vertical scrolling
    }

    return getResponsiveSpacing(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive vertical spacing for stacked layouts
  static double getResponsiveVerticalSpacing(
    BuildContext context, {
    double mobile = 12.0,
    double tablet = 16.0,
    double desktop = 20.0,
  }) {
    return getResponsiveSpacing(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Check if items should be stacked vertically based on available width
  static bool shouldStackVertically(
    BuildContext context, {
    double? itemWidth,
    int? itemCount,
    double? minSpacing,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing =
        minSpacing ??
        getResponsiveSpacing(
          context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        );
    final width = itemWidth ?? 200.0; // Default item width
    final count = itemCount ?? 1;

    final requiredWidth = (width * count) + (spacing * (count - 1));
    return screenWidth < requiredWidth;
  }
}

enum ScreenSize { mobile, tablet, desktop, largeDesktop, extraLargeDesktop }
