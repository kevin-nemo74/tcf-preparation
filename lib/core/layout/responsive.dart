import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Breakpoints and helpers for **mobile + web** (tablet / desktop layouts).
abstract final class Responsive {
  /// Phone portrait / narrow windows.
  static const double breakpointCompact = 600;

  /// Tablet / small laptop — start capping content width.
  static const double breakpointMedium = 840;

  /// Large desktop — wider cap.
  static const double breakpointExpanded = 1200;

  /// Master/detail: test lists, question (image + options), similar flows.
  static const double splitLayoutBreakpoint = 920;
  static const double tabletWebBreakpoint = 1024;
  static const double desktopWebBreakpoint = 1280;
  static const double ultraWideBreakpoint = 1600;

  /// Wider auth marketing + form layout (login / register).
  static const double authWideBreakpoint = 900;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isCompactWidth(BuildContext context) =>
      width(context) < breakpointMedium;

  /// Écrite / Orale list + detail, CE/CO question wide layout.
  static bool isSplitLayout(BuildContext context) =>
      width(context) >= splitLayoutBreakpoint;

  /// Review grid + detail side-by-side.
  static bool isWideReview(BuildContext context) =>
      width(context) >= splitLayoutBreakpoint;

  static bool isTabletWeb(BuildContext context) =>
      kIsWeb && width(context) >= tabletWebBreakpoint;

  static bool isDesktopWeb(BuildContext context) =>
      kIsWeb && width(context) >= desktopWebBreakpoint;

  static bool isUltraWide(BuildContext context) =>
      kIsWeb && width(context) >= ultraWideBreakpoint;

  static bool isAuthWideLayout(BuildContext context) =>
      width(context) >= authWideBreakpoint;

  /// Max width for main app canvas (portal, profile, etc.) on wide viewports.
  static double canvasMaxWidth(BuildContext context) {
    final w = width(context);
    if (kIsWeb) {
      if (w < tabletWebBreakpoint) return w;
      if (w < desktopWebBreakpoint) return 1120;
      if (w < ultraWideBreakpoint) return 1360;
      return 1600;
    }
    if (w < breakpointMedium) return w;
    if (w < breakpointExpanded) return 960;
    return 1200;
  }

  /// Auth and short forms — readable line length on desktop web.
  static double formMaxWidth(BuildContext context) {
    final w = width(context);
    if (w >= breakpointMedium) return 520;
    return w;
  }

  /// Horizontal inset for full-width sections on large canvases.
  static EdgeInsets horizontalInset(BuildContext context) {
    final w = width(context);
    if (kIsWeb) {
      if (w >= ultraWideBreakpoint) {
        return const EdgeInsets.symmetric(horizontal: 32);
      }
      if (w >= desktopWebBreakpoint) {
        return const EdgeInsets.symmetric(horizontal: 24);
      }
      if (w >= tabletWebBreakpoint) {
        return const EdgeInsets.symmetric(horizontal: 18);
      }
    }
    if (w >= breakpointExpanded) {
      return EdgeInsets.symmetric(horizontal: kIsWeb ? 28 : 24);
    }
    if (w >= breakpointMedium) {
      return const EdgeInsets.symmetric(horizontal: 16);
    }
    return EdgeInsets.zero;
  }

  /// Combines [horizontalInset] with optional extra padding.
  static EdgeInsets pagePadding(BuildContext context, {double vertical = 16}) {
    final h = horizontalInset(context);
    return EdgeInsets.fromLTRB(h.left, vertical, h.right, vertical);
  }

  /// Adaptive left pane width for split list/detail layouts.
  static double splitListPaneWidth(BuildContext context) {
    final w = width(context);
    if (kIsWeb) {
      if (w >= ultraWideBreakpoint) return 460;
      if (w >= desktopWebBreakpoint) return 420;
      return 360;
    }
    return 360;
  }

  /// Adaptive side navigator width for review/detail layouts.
  static double reviewPaneWidth(BuildContext context) {
    final w = width(context);
    if (kIsWeb) {
      if (w >= ultraWideBreakpoint) return 420;
      if (w >= desktopWebBreakpoint) return 380;
      return 340;
    }
    return 340;
  }

  /// Standardized adaptive grid columns for web and mobile.
  static int gridColumns(BuildContext context, {int mobile = 2}) {
    final w = width(context);
    if (kIsWeb) {
      if (w >= ultraWideBreakpoint) return 8;
      if (w >= desktopWebBreakpoint) return 6;
      if (w >= tabletWebBreakpoint) return 5;
      return 4;
    }
    if (w >= splitLayoutBreakpoint) return 4;
    return mobile;
  }
}
