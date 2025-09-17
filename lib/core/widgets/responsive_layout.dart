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

// Responsive Builder Widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    return builder(context, screenSize);
  }
}

// Responsive Container Widget
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
            mobile: width!,
            tablet: width! * 1.2,
            desktop: width! * 1.5,
            largeDesktop: width! * 1.8,
            extraLargeDesktop: width! * 2.0,
          )
        : null;

    final responsiveHeight = height != null
        ? ResponsiveUtils.getResponsiveContainerHeight(
            context,
            mobile: height!,
            tablet: height! * 1.1,
            desktop: height! * 1.2,
            largeDesktop: height! * 1.3,
            extraLargeDesktop: height! * 1.4,
          )
        : null;

    return Container(
      width: responsiveWidth,
      height: responsiveHeight,
      margin: margin,
      padding: padding,
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

// Responsive Column Widget
class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
  }
}

// Responsive Row Widget
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
  }
}

// Responsive Grid Widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double? itemWidth;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    required this.crossAxisCount,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveColumns = ResponsiveUtils.getResponsiveGridColumns(context);
    final actualColumns = crossAxisCount > responsiveColumns
        ? responsiveColumns
        : crossAxisCount;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: actualColumns,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

// Responsive Scrollable Row Widget
class ResponsiveScrollableRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final ScrollController? controller;
  final double? minWidth;

  const ResponsiveScrollableRow({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.controller,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: children
            .expand(
              (child) => [
                if (minWidth != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minWidth!),
                    child: child,
                  )
                else
                  child,
                SizedBox(width: spacing),
              ],
            )
            .toList(),
      ),
    );
  }
}

// Responsive Flexible Grid Widget
class ResponsiveFlexibleGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double maxCrossAxisExtent;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double? itemWidth;

  const ResponsiveFlexibleGrid({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.maxCrossAxisExtent = 200.0,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

// Responsive Flexible Row Widget
class ResponsiveFlexibleRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? minWidth;

  const ResponsiveFlexibleRow({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children
          .expand(
            (child) => [
              if (minWidth != null)
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: minWidth!),
                  child: child,
                )
              else
                child,
              SizedBox(width: spacing),
            ],
          )
          .toList(),
    );
  }
}
