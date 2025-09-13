import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum ScreenSize { mobile, tablet, desktop, largeDesktop, extraLargeDesktop }

class ResponsiveUtils {
  // Get screen size based on width
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return ScreenSize.mobile;
    } else if (width < 900) {
      return ScreenSize.tablet;
    } else if (width < 1200) {
      return ScreenSize.desktop;
    } else if (width < 1600) {
      return ScreenSize.largeDesktop;
    } else {
      return ScreenSize.extraLargeDesktop;
    }
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
    return getScreenSize(context) == ScreenSize.desktop;
  }

  // Check if current screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.largeDesktop;
  }

  // Check if current screen is extra large desktop
  static bool isExtraLargeDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.extraLargeDesktop;
  }

  // Get responsive padding
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

  // Get responsive container width
  static double getResponsiveContainerWidth(
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

  // Get responsive content max width
  static double getResponsiveContentMaxWidth(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return 800.0;
      case ScreenSize.desktop:
        return 1200.0;
      case ScreenSize.largeDesktop:
        return 1400.0;
      case ScreenSize.extraLargeDesktop:
        return 1600.0;
    }
  }

  // Get responsive grid columns
  static int getResponsiveGridColumns(BuildContext context) {
    final screenSize = getScreenSize(context);

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
  }

  // Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.symmetric(horizontal: 16.0);
      case ScreenSize.tablet:
        return const EdgeInsets.symmetric(horizontal: 24.0);
      case ScreenSize.desktop:
        return const EdgeInsets.symmetric(horizontal: 32.0);
      case ScreenSize.largeDesktop:
        return const EdgeInsets.symmetric(horizontal: 40.0);
      case ScreenSize.extraLargeDesktop:
        return const EdgeInsets.symmetric(horizontal: 48.0);
    }
  }

  // Get responsive aspect ratio
  static double getResponsiveAspectRatio(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return 0.8;
      case ScreenSize.tablet:
        return 0.9;
      case ScreenSize.desktop:
        return 1.0;
      case ScreenSize.largeDesktop:
        return 1.1;
      case ScreenSize.extraLargeDesktop:
        return 1.2;
    }
  }

  // Check if platform is web
  static bool isWeb() {
    return kIsWeb;
  }
}
