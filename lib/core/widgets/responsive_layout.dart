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
  final bool useResponsivePadding;
  final bool useResponsiveWidth;
  final bool useResponsiveHeight;

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
    this.useResponsivePadding = false,
    this.useResponsiveWidth = false,
    this.useResponsiveHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveWidth = useResponsiveWidth && width != null
        ? ResponsiveUtils.getResponsiveContainerWidth(
            context,
            mobile: width! * 0.9,
            tablet: width! * 0.8,
            desktop: width! * 0.7,
            largeDesktop: width! * 0.6,
            extraLargeDesktop: width! * 0.5,
          )
        : width;

    final responsiveHeight = useResponsiveHeight && height != null
        ? ResponsiveUtils.getResponsiveContainerHeight(
            context,
            mobile: height! * 0.9,
            tablet: height! * 0.85,
            desktop: height!,
            largeDesktop: height!,
            extraLargeDesktop: height!,
          )
        : height;

    final responsivePadding = useResponsivePadding
        ? ResponsiveUtils.getResponsivePadding(context)
        : padding;

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

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;
  final int? crossAxisCount;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
    this.crossAxisCount,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveColumns =
        crossAxisCount ?? ResponsiveUtils.getResponsiveGridColumns(context);
    final responsiveAspectRatio =
        childAspectRatio ?? ResponsiveUtils.getResponsiveAspectRatio(context);

    return GridView.count(
      crossAxisCount: responsiveColumns,
      crossAxisSpacing:
          crossAxisSpacing ??
          ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          ),
      mainAxisSpacing:
          mainAxisSpacing ??
          ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          ),
      childAspectRatio: responsiveAspectRatio,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing =
        spacing ??
        ResponsiveUtils.getResponsiveSpacing(
          context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        );

    if (children.length <= 1) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: responsiveSpacing));
      }
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }
}

class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? spacing;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing =
        spacing ??
        ResponsiveUtils.getResponsiveSpacing(
          context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        );

    if (children.length <= 1) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: responsiveSpacing));
      }
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }
}

class ResponsiveWebLayout extends StatelessWidget {
  final Widget? sidebar;
  final Widget content;
  final bool showSidebar;
  final double? sidebarWidth;
  final Color? backgroundColor;

  const ResponsiveWebLayout({
    super.key,
    this.sidebar,
    required this.content,
    this.showSidebar = true,
    this.sidebarWidth,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveUtils.isWeb() || !showSidebar) {
      return content;
    }

    final screenSize = ResponsiveUtils.getScreenSize(context);

    // On mobile web, show sidebar as overlay
    if (screenSize == ScreenSize.mobile) {
      return Stack(
        children: [
          content,
          if (sidebar != null)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width:
                    sidebarWidth ??
                    ResponsiveUtils.getResponsiveSidebarWidth(context),
                color: backgroundColor ?? Colors.white,
                child: sidebar!,
              ),
            ),
        ],
      );
    }

    // On larger screens, show sidebar alongside content
    return Row(
      children: [
        if (sidebar != null)
          Container(
            width:
                sidebarWidth ??
                ResponsiveUtils.getResponsiveSidebarWidth(context),
            color: backgroundColor ?? Colors.white,
            child: sidebar!,
          ),
        Expanded(child: content),
      ],
    );
  }
}

/// A responsive widget that automatically switches between horizontal and vertical layouts
/// based on available space using MediaQuery
class ResponsiveFlexibleRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? spacing;
  final double? minWidth;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveFlexibleRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing,
    this.minWidth,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we should use vertical scrolling
    if (ResponsiveUtils.shouldUseVerticalScrolling(
      context,
      minWidth: minWidth,
    )) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: physics,
        child: ResponsiveColumn(
          spacing:
              spacing ?? ResponsiveUtils.getResponsiveVerticalSpacing(context),
          children: children,
        ),
      );
    }

    // Use horizontal layout with horizontal scrolling if needed
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: physics,
      child: ResponsiveRow(
        spacing:
            spacing ?? ResponsiveUtils.getResponsiveHorizontalSpacing(context),
        children: children,
      ),
    );
  }
}

/// A responsive grid that automatically switches to vertical scrolling when horizontal space is limited
class ResponsiveFlexibleGrid extends StatelessWidget {
  final List<Widget> children;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;
  final int? crossAxisCount;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double? minWidth;
  final double? itemWidth;

  const ResponsiveFlexibleGrid({
    super.key,
    required this.children,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
    this.crossAxisCount,
    this.physics,
    this.shrinkWrap = false,
    this.minWidth,
    this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Check if items should be stacked vertically
    if (ResponsiveUtils.shouldStackVertically(
      context,
      itemWidth: itemWidth,
      itemCount:
          crossAxisCount ?? ResponsiveUtils.getResponsiveGridColumns(context),
      minSpacing: crossAxisSpacing,
    )) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: physics,
        child: ResponsiveColumn(
          spacing:
              mainAxisSpacing ??
              ResponsiveUtils.getResponsiveVerticalSpacing(context),
          children: children,
        ),
      );
    }

    // Use normal grid layout
    return ResponsiveGrid(
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
      crossAxisCount: crossAxisCount,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

/// A responsive widget that provides horizontal scrolling with vertical fallback
/// based on MediaQuery screen width
class ResponsiveScrollableRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? spacing;
  final double? minWidth;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ResponsiveScrollableRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing,
    this.minWidth,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we should use vertical scrolling
    if (ResponsiveUtils.shouldUseVerticalScrolling(
      context,
      minWidth: minWidth,
    )) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: physics,
        padding: padding,
        child: ResponsiveColumn(
          spacing:
              spacing ?? ResponsiveUtils.getResponsiveVerticalSpacing(context),
          children: children,
        ),
      );
    }

    // Use horizontal scrolling
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: physics,
      padding: padding,
      child: ResponsiveRow(
        spacing:
            spacing ?? ResponsiveUtils.getResponsiveHorizontalSpacing(context),
        children: children,
      ),
    );
  }
}
