import 'package:flutter/material.dart';

import '../theme/motion.dart';

/// True when the platform/user requests reduced motion.
bool contextReducedMotion(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}

/// Fades and slides [child] in on first build (respects reduced motion).
class AnimatedFadeSlide extends StatefulWidget {
  const AnimatedFadeSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.medium,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  State<AnimatedFadeSlide> createState() => _AnimatedFadeSlideState();
}

class _AnimatedFadeSlideState extends State<AnimatedFadeSlide>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;
  Animation<double>? _opacity;
  Animation<Offset>? _slide;
  bool _animationsReady = false;

  /// [MediaQuery] / inherited widgets are not safe to read from [initState].
  /// Initialize after [didChangeDependencies] (same pattern as [Theme.of]).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationsReady) return;
    _animationsReady = true;

    final reduced = contextReducedMotion(context);
    final c = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: c, curve: AppMotion.curve);
    _opacity = Tween<double>(begin: reduced ? 1 : 0, end: 1).animate(curved);
    _slide = Tween<Offset>(
      begin: reduced ? Offset.zero : const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(curved);
    _c = c;

    if (reduced) {
      c.value = 1;
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = _opacity;
    final slide = _slide;
    if (opacity == null || slide == null) {
      return widget.child;
    }
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: slide,
        child: widget.child,
      ),
    );
  }
}

/// Subtle scale on press (skipped when reduced motion).
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.minScale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double minScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
      reverseDuration: AppMotion.fast,
    );
    _scale = Tween<double>(begin: 1, end: widget.minScale).animate(
      CurvedAnimation(parent: _c, curve: AppMotion.curve),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = contextReducedMotion(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: reduced ? null : (_) => _c.forward(),
      onTapUp: reduced ? null : (_) {
        _c.reverse();
        widget.onTap?.call();
      },
      onTapCancel: reduced ? null : () => _c.reverse(),
      onTap: reduced ? widget.onTap : null,
      child: ScaleTransition(
        scale: reduced ? const AlwaysStoppedAnimation(1) : _scale,
        child: widget.child,
      ),
    );
  }
}

/// Vertically stacks [children] with staggered [AnimatedFadeSlide] entrances.
class StaggeredColumn extends StatelessWidget {
  const StaggeredColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.spacing = 0,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final reduced = contextReducedMotion(context);
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          reduced
              ? children[i]
              : AnimatedFadeSlide(
                  delay: AppMotion.fast + Duration(milliseconds: 50 * i),
                  child: children[i],
                ),
          if (i < children.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

/// Lightweight loading placeholder (respects reduced motion = static).
class ShimmerSkeleton extends StatefulWidget {
  const ShimmerSkeleton({
    super.key,
    this.height = 56,
    this.borderRadius = 14,
  });

  final double height;
  final double borderRadius;

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (contextReducedMotion(context)) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      );
    }
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 2, 0),
              end: Alignment(1 + t * 2, 0),
              colors: [
                cs.surfaceContainerHighest.withValues(alpha: 0.35),
                cs.primaryContainer.withValues(alpha: 0.45),
                cs.surfaceContainerHighest.withValues(alpha: 0.35),
              ],
            ),
          ),
        );
      },
    );
  }
}
