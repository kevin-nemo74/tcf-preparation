import 'package:flutter/material.dart';

import '../layout/responsive.dart';

/// Top-aligned, horizontally centered column with a max width on large screens.
/// Use under [Scaffold.body] when the child is a [Column] with [Expanded].
class ResponsiveFrame extends StatelessWidget {
  const ResponsiveFrame({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.expandToViewport = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final bool expandToViewport;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cap = maxWidth ?? Responsive.canvasMaxWidth(context);
        Widget c = child;
        if (padding != null) {
          c = Padding(padding: padding!, child: c);
        }
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: cap,
              minWidth: expandToViewport ? constraints.maxWidth : 0,
              maxHeight: constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : double.infinity,
            ),
            child: c,
          ),
        );
      },
    );
  }
}

/// Centers a **single-column** child (forms, cards) with a max width.
class ResponsiveCentered extends StatelessWidget {
  const ResponsiveCentered({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final cap = maxWidth ?? Responsive.formMaxWidth(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: child,
      ),
    );
  }
}
