import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final Widget? extraLargeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.extraLargeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ResponsiveUtils.getScreenSize(context);

        switch (screenSize) {
          case ScreenSize.mobile:
            return mobile;
          case ScreenSize.tablet:
            return tablet ?? mobile;
          case ScreenSize.desktop:
            return desktop ?? tablet ?? mobile;
          case ScreenSize.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
          case ScreenSize.extraLargeDesktop:
            return extraLargeDesktop ??
                largeDesktop ??
                desktop ??
                tablet ??
                mobile;
        }
      },
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ResponsiveUtils.getScreenSize(context);
        return builder(context, screenSize);
      },
    );
  }
}

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: backgroundColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final Color? color;
  final Decoration? foregroundDecoration;
  final Matrix4? transform;
  final Alignment? transformAlignment;

  const ResponsiveContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.decoration,
    this.constraints,
    this.alignment,
    this.clipBehavior = Clip.none,
    this.color,
    this.foregroundDecoration,
    this.transform,
    this.transformAlignment,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveWidth = width != null
        ? ResponsiveUtils.getResponsiveContainerWidth(
            context,
            mobile: width! * 0.9,
            tablet: width! * 0.8,
            desktop: width! * 0.7,
            largeDesktop: width! * 0.6,
            extraLargeDesktop: width! * 0.5,
          )
        : null;

    final responsiveHeight = height != null
        ? ResponsiveUtils.getResponsiveContainerHeight(
            context,
            mobile: height! * 0.9,
            tablet: height! * 0.85,
            desktop: height!,
            largeDesktop: height!,
            extraLargeDesktop: height!,
          )
        : null;

    final responsivePadding = padding != null
        ? ResponsiveUtils.getResponsivePadding(context)
        : null;

    return Container(
      width: responsiveWidth,
      height: responsiveHeight,
      margin: margin,
      padding: responsivePadding,
      decoration: decoration,
      constraints: constraints,
      alignment: alignment,
      clipBehavior: clipBehavior,
      color: color,
      foregroundDecoration: foregroundDecoration,
      transform: transform,
      transformAlignment: transformAlignment,
      child: child,
    );
  }
}
