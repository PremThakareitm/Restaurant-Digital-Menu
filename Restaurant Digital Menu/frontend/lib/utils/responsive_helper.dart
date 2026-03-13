import 'package:flutter/material.dart';

/// Breakpoints for responsive design
class ResponsiveHelper {
  /// Mobile: < 480px
  static const double mobileMaxWidth = 480;

  /// Tablet: 480px - 960px
  static const double tabletMinWidth = 480;
  static const double tabletMaxWidth = 960;

  /// Desktop: >= 960px
  static const double desktopMinWidth = 960;

  /// Extra large: >= 1440px
  static const double largeDesktopMinWidth = 1440;

  /// Ultra wide: >= 1920px
  static const double ultraWideMinWidth = 1920;

  /// Determine device type
  static ScreenType getScreenType(double width) {
    if (width < mobileMaxWidth) {
      return ScreenType.mobile;
    } else if (width < tabletMaxWidth) {
      return ScreenType.tablet;
    } else if (width < largeDesktopMinWidth) {
      return ScreenType.desktop;
    } else if (width < ultraWideMinWidth) {
      return ScreenType.largeDesktop;
    } else {
      return ScreenType.ultraWide;
    }
  }

  /// Max content width to prevent text lines from being too long
  static double getMaxContentWidth(double screenWidth) {
    if (screenWidth < tabletMaxWidth) return screenWidth - 32;
    if (screenWidth < largeDesktopMinWidth) return 900;
    if (screenWidth < ultraWideMinWidth) return 1200;
    return 1400;
  }

  /// Responsive horizontal padding
  static double getHorizontalPadding(double screenWidth) {
    if (screenWidth < tabletMaxWidth) return 16;
    if (screenWidth < desktopMinWidth) return 24;
    return 32;
  }

  /// Responsive vertical padding
  static double getVerticalPadding(double screenWidth) {
    if (screenWidth < tabletMaxWidth) return 12;
    return 16;
  }

  /// Grid column count for dish cards
  static int getGridColumns(double width) {
    if (width < 480) return 2;
    if (width < 680) return 2;
    if (width < 980) return 3;
    if (width < 1280) return 4;
    if (width < 1600) return 5;
    return 6;
  }

  /// Card aspect ratio based on column count
  static double getCardAspectRatio(int columnCount) {
    if (columnCount <= 2) return 0.72;
    if (columnCount <= 3) return 0.72;
    if (columnCount <= 4) return 0.76;
    return 0.80;
  }

  /// Dish detail image height (responsive)
  static double getDishDetailImageHeight(double screenWidth) {
    if (screenWidth < 600) return 280;
    if (screenWidth < 960) return 320;
    return 400;
  }

  /// AppBar height (responsive)
  static double getAppBarHeight(double screenWidth) {
    if (screenWidth < 600) return 56;
    return 64;
  }

  /// Spacing between grid items
  static double getGridSpacing(double screenWidth) {
    if (screenWidth < 600) return 12;
    if (screenWidth < 960) return 14;
    return 16;
  }

  /// Font sizes (responsive)
  static double getTitleFontSize(double screenWidth) {
    if (screenWidth < 600) return 18;
    if (screenWidth < 960) return 20;
    return 24;
  }

  static double getBodyFontSize(double screenWidth) {
    if (screenWidth < 600) return 14;
    return 16;
  }
}

enum ScreenType { mobile, tablet, desktop, largeDesktop, ultraWide }

extension ScreenTypeExtension on ScreenType {
  bool get isMobile => this == ScreenType.mobile;
  bool get isTablet => this == ScreenType.tablet;
  bool get isDesktop =>
      this == ScreenType.desktop ||
      this == ScreenType.largeDesktop ||
      this == ScreenType.ultraWide;
  bool get isLargeScreen =>
      this == ScreenType.tablet || this == ScreenType.desktop;
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ScreenType, double) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveHelper.getScreenType(constraints.maxWidth);
        return builder(context, screenType, constraints.maxWidth);
      },
    );
  }
}
