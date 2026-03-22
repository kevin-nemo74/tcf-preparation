import 'package:flutter/material.dart';

import 'motion.dart';

class DesignTokens {
  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const EdgeInsets cardPadding = EdgeInsets.all(14);
  static const double cardRadius = 18;
  static const double chipRadius = 14;
  static const double minTouchTarget = 48;

  /// Stagger delay between list/section children.
  static Duration staggerDelay(int index) =>
      AppMotion.fast + Duration(milliseconds: 40 * index);

  static BorderRadius cardBorderRadius() => BorderRadius.circular(cardRadius);
  static BorderRadius chipBorderRadius() => BorderRadius.circular(chipRadius);
}
