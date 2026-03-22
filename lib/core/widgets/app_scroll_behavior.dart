import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Enables **mouse / trackpad drag scrolling** on web and desktop (not only touch).
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
