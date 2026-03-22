import 'package:flutter/material.dart';

/// Shared motion constants for the app. Use with [AppMotionWidgets] helpers.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
  static const Curve curve = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve decelerate = Curves.decelerate;
}
