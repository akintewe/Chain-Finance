import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double _tabletBreakpoint = 600.0;
  static const double _iPadSidePadding = 80.0;
  static const double _phoneSidePadding = 16.0;

  /// Check if the current device is a tablet/iPad
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > _tabletBreakpoint;
  }

  /// Get appropriate horizontal padding based on device type
  static double getHorizontalPadding(BuildContext context) {
    return isTablet(context) ? _iPadSidePadding : _phoneSidePadding;
  }

  /// Get EdgeInsets with responsive horizontal padding
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double? top,
    double? bottom,
    double? vertical,
    double? horizontal,
  }) {
    final horizontalPadding = horizontal ?? getHorizontalPadding(context);
    final verticalPadding = vertical ?? 0.0;
    
    return EdgeInsets.only(
      left: horizontalPadding,
      right: horizontalPadding,
      top: top ?? verticalPadding,
      bottom: bottom ?? verticalPadding,
    );
  }

  /// Get EdgeInsets with all sides responsive
  static EdgeInsets getResponsiveAllPadding(BuildContext context, {
    double? all,
    double? vertical,
    double? horizontal,
  }) {
    final horizontalPadding = horizontal ?? getHorizontalPadding(context);
    final verticalPadding = vertical ?? all ?? 16.0;
    
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
  }

  /// Wrapper widget that applies responsive padding
  static Widget wrapWithResponsivePadding(
    BuildContext context,
    Widget child, {
    double? top,
    double? bottom,
    double? vertical,
    double? horizontal,
    bool onlyHorizontal = false,
  }) {
    if (onlyHorizontal) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPadding(context),
        ),
        child: child,
      );
    }
    
    return Padding(
      padding: getResponsivePadding(
        context,
        top: top,
        bottom: bottom,
        vertical: vertical,
        horizontal: horizontal,
      ),
      child: child,
    );
  }

  /// Get screen width percentage (useful for responsive sizing)
  static double getScreenWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    return isTablet(context) ? baseFontSize * 1.1 : baseFontSize;
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    return isTablet(context) ? baseIconSize * 1.2 : baseIconSize;
  }

  /// Get maximum content width for iPad to prevent over-stretching
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isTablet(context)) {
      // On iPad, limit content width to 80% of screen or max 600px
      return (screenWidth * 0.8).clamp(300.0, 600.0);
    }
    return screenWidth;
  }

  /// Center content on iPad with max width constraint
  static Widget centerContentOnTablet(BuildContext context, Widget child) {
    if (isTablet(context)) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: getMaxContentWidth(context),
          ),
          child: child,
        ),
      );
    }
    return child;
  }
}

/// Extension to make responsive padding easier to use
extension ResponsiveWidget on Widget {
  /// Wrap widget with responsive horizontal padding
  Widget withResponsivePadding(BuildContext context, {
    double? top,
    double? bottom,
    double? vertical,
    double? horizontal,
    bool onlyHorizontal = false,
  }) {
    return ResponsiveHelper.wrapWithResponsivePadding(
      context,
      this,
      top: top,
      bottom: bottom,
      vertical: vertical,
      horizontal: horizontal,
      onlyHorizontal: onlyHorizontal,
    );
  }

  /// Center content on tablet with max width constraint
  Widget centerOnTablet(BuildContext context) {
    return ResponsiveHelper.centerContentOnTablet(context, this);
  }
}
