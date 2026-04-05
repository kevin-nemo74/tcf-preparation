import 'package:flutter/material.dart';

class PremiumBrandMark extends StatelessWidget {
  final bool large;
  final String heroTag;
  const PremiumBrandMark({
    super.key,
    this.large = false,
    this.heroTag = 'auth_brand',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = large ? 82.0 : 46.0;
    final textSize = large ? 30.0 : 17.0;
    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cs.primaryContainer, cs.secondaryContainer],
            ),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.2),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'MT',
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w900,
                fontSize: textSize,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  const PremiumSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class PremiumInfoCard extends StatelessWidget {
  final Widget child;
  final bool highlighted;
  final EdgeInsetsGeometry padding;
  const PremiumInfoCard({
    super.key,
    required this.child,
    this.highlighted = false,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: highlighted
            ? cs.primaryContainer.withValues(alpha: 0.3)
            : cs.surface,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }
}

class PremiumPrimaryCta extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  const PremiumPrimaryCta({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: PremiumInfoCard(
        highlighted: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cs.primary, size: 34),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.72),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PolishedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool highlighted;
  final double? elevation;
  final VoidCallback? onTap;

  const PolishedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.highlighted = false,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: highlighted
            ? cs.primaryContainer.withValues(alpha: 0.22)
            : cs.surface,
        border: Border.all(
          color: highlighted
              ? cs.primary.withValues(alpha: 0.4)
              : cs.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: highlighted
                ? cs.primary.withValues(alpha: 0.08)
                : cs.shadow.withValues(alpha: 0.04),
            blurRadius: elevation ?? 16,
            offset: Offset(0, elevation ?? 6),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

class PolishedHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final double iconSize;
  final double padding;

  const PolishedHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.iconSize = 24,
    this.padding = 16,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding - 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.55),
            cs.tertiaryContainer.withValues(alpha: 0.35),
            cs.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: cs.primary, size: iconSize),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class PolishedMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;
  final bool compact;

  const PolishedMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = accentColor ?? cs.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    color: cs.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: compact ? 15 : 17,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PolishedChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool highlighted;
  final VoidCallback? onTap;

  const PolishedChip({
    super.key,
    required this.label,
    this.icon,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = highlighted ? cs.primary : cs.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: highlighted
              ? cs.primaryContainer.withValues(alpha: 0.55)
              : cs.surfaceContainerHighest.withValues(alpha: 0.45),
          border: Border.all(
            color: highlighted
                ? cs.primary.withValues(alpha: 0.5)
                : cs.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PolishedDivider extends StatelessWidget {
  final String? label;

  const PolishedDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (label == null) {
      return Divider(
        color: cs.outlineVariant.withValues(alpha: 0.3),
        height: 32,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    cs.outlineVariant.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.outlineVariant.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
