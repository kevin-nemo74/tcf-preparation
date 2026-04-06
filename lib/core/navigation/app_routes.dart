import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';

/// Opinionated route transitions for a softer, less "dead" navigation feel.
class AppRoutes {
  AppRoutes._();

  static PageRoute<T> fadeSlide<T extends Object?>(
    Widget page, {
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? AppMotion.medium,
      reverseTransitionDuration: duration ?? AppMotion.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.curve,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.035),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
