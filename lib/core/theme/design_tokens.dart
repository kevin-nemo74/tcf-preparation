import 'package:flutter/material.dart';

import 'motion.dart';

/// Static spacing / radii. For breakpoints and max widths (web + mobile), see
/// `lib/core/layout/responsive.dart`.
class DesignTokens {
  static const EdgeInsets pagePadding = EdgeInsets.all(18);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const double cardRadius = 20;
  static const double cardRadiusLg = 26;
  static const double chipRadius = 16;
  static const double minTouchTarget = 48;
  static const double sectionGap = 16;
  static const double itemGap = 12;
  static const double subtleBorderOpacity = 0.35;
  static const double subtleSurfaceOpacity = 0.25;

  /// Stagger delay between list/section children.
  static Duration staggerDelay(int index) =>
      AppMotion.fast + Duration(milliseconds: 40 * index);

  static BorderRadius cardBorderRadius() => BorderRadius.circular(cardRadius);
  static BorderRadius cardBorderRadiusLg() => BorderRadius.circular(cardRadiusLg);
  static BorderRadius chipBorderRadius() => BorderRadius.circular(chipRadius);

  static BoxDecoration cardDecoration(
    ColorScheme cs, {
    bool highlighted = false,
  }) {
    return BoxDecoration(
      borderRadius: cardBorderRadiusLg(),
      color: highlighted
          ? cs.primaryContainer.withValues(alpha: 0.28)
          : cs.surface,
      border: Border.all(color: cs.outlineVariant.withValues(alpha: subtleBorderOpacity)),
    );
  }
}
