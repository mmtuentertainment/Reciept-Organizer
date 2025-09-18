import 'package:flutter/material.dart';

/// Breakpoints for responsive design
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
  static const double largeDesktop = 1920;
}

/// Screen size enum for easy identification
enum ScreenSize {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// ResponsiveBuilder widget for adaptive layouts
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= ResponsiveBreakpoints.largeDesktop && largeDesktop != null) {
          return largeDesktop!;
        } else if (width >= ResponsiveBreakpoints.desktop && desktop != null) {
          return desktop!;
        } else if (width >= ResponsiveBreakpoints.mobile && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Helper class for responsive utilities
class Responsive {
  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= ResponsiveBreakpoints.mobile;

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > ResponsiveBreakpoints.mobile && width <= ResponsiveBreakpoints.tablet;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > ResponsiveBreakpoints.tablet;

  /// Check if current screen is large desktop
  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.largeDesktop;

  /// Get current screen size
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return ScreenSize.largeDesktop;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return ScreenSize.desktop;
    } else if (width > ResponsiveBreakpoints.mobile) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.mobile;
    }
  }

  /// Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.all(
      value<double>(
        context,
        mobile: 16,
        tablet: 24,
        desktop: 32,
        largeDesktop: 40,
      ),
    );
  }

  /// Get responsive spacing
  static double spacing(BuildContext context) {
    return value<double>(
      context,
      mobile: 8,
      tablet: 12,
      desktop: 16,
      largeDesktop: 20,
    );
  }

  /// Get number of grid columns based on screen size
  static int gridColumns(BuildContext context) {
    return value<int>(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }
}

/// Adaptive grid widget that automatically adjusts columns
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsets? padding;

  const AdaptiveGrid({
    Key? key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.value<int>(
      context,
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
      largeDesktop: largeDesktopColumns ?? 4,
    );

    return Padding(
      padding: padding ?? Responsive.padding(context),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: 1,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

/// Responsive text that scales based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive.value<double>(
      context,
      mobile: mobileFontSize ?? 14,
      tablet: tabletFontSize ?? mobileFontSize ?? 16,
      desktop: desktopFontSize ?? tabletFontSize ?? mobileFontSize ?? 18,
    );

    return Text(
      text,
      style: style?.copyWith(fontSize: fontSize) ?? TextStyle(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive container with adaptive constraints
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;
  final EdgeInsets? padding;
  final AlignmentGeometry? alignment;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
    this.padding,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = Responsive.value<double?>(
      context,
      mobile: mobileMaxWidth,
      tablet: tabletMaxWidth ?? 768,
      desktop: desktopMaxWidth ?? 1200,
    );

    return Container(
      alignment: alignment ?? Alignment.center,
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: child,
      ),
    );
  }
}

/// Show/hide widget based on screen size
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool hiddenOnMobile;
  final bool hiddenOnTablet;
  final bool hiddenOnDesktop;
  final bool hiddenOnLargeDesktop;

  const ResponsiveVisibility({
    Key? key,
    required this.child,
    this.hiddenOnMobile = false,
    this.hiddenOnTablet = false,
    this.hiddenOnDesktop = false,
    this.hiddenOnLargeDesktop = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = Responsive.getScreenSize(context);

    bool shouldHide = false;
    switch (screenSize) {
      case ScreenSize.mobile:
        shouldHide = hiddenOnMobile;
        break;
      case ScreenSize.tablet:
        shouldHide = hiddenOnTablet;
        break;
      case ScreenSize.desktop:
        shouldHide = hiddenOnDesktop;
        break;
      case ScreenSize.largeDesktop:
        shouldHide = hiddenOnLargeDesktop;
        break;
    }

    return shouldHide ? const SizedBox.shrink() : child;
  }
}