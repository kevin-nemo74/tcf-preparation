import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/core/widgets/responsive_frame.dart';
import 'package:tcf_canada_preparation/features/profile/profile_screen.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/features/progress/review_queue_screen.dart';
import 'package:tcf_canada_preparation/features/progress/study_plan_screen.dart';

import 'study_plan_portal_card.dart';

class ExamPortalScreen extends StatelessWidget {
  final String? uid;

  const ExamPortalScreen({super.key, this.uid});

  @override
  Widget build(BuildContext context) {
    final resolvedUid = uid ?? ProgressRepository.currentUid;
    final wide = kIsWeb
        ? Responsive.isTabletWeb(context)
        : Responsive.isSplitLayout(context);

    return Padding(
      padding: Responsive.horizontalInset(context),
      child: ResponsiveFrame(
        child: resolvedUid != null
            ? wide
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 20),
                          _PortalSummary(uid: resolvedUid),
                          const SizedBox(height: 16),
                          _PortalActions(uid: resolvedUid, compact: true),
                          const SizedBox(height: 16),
                          _buildSectionTitle(
                            context,
                            'Plan d\'etude',
                            Icons.event_note_rounded,
                          ),
                          const SizedBox(height: 8),
                          StudyPlanPortalCard(uid: resolvedUid),
                          const SizedBox(height: 16),
                          _buildSectionTitle(
                            context,
                            'Analyse de progression',
                            Icons.insights_rounded,
                          ),
                          const SizedBox(height: 8),
                          _ProgressInsights(uid: resolvedUid, compact: true),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 20),
                        _PortalSummary(uid: resolvedUid),
                        const SizedBox(height: 16),
                        _PortalActions(uid: resolvedUid),
                        const SizedBox(height: 20),
                        _buildSectionTitle(
                          context,
                          'Plan d\'etude',
                          Icons.event_note_rounded,
                        ),
                        const SizedBox(height: 10),
                        StudyPlanPortalCard(uid: resolvedUid),
                        const SizedBox(height: 20),
                        _buildSectionTitle(
                          context,
                          'Analyse de progression',
                          Icons.insights_rounded,
                        ),
                        const SizedBox(height: 10),
                        _ProgressInsights(uid: resolvedUid),
                      ],
                    )
            : _buildEmptyState(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.6),
            cs.tertiaryContainer.withValues(alpha: 0.35),
            cs.secondaryContainer.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.dashboard_customize_rounded,
              color: cs.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableau de bord',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Suivez votre progression et planifiez votre etude',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 48,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tableau de bord',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Connectez-vous pour acceder a votre\ntableau de bord personnalise',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalSummary extends StatelessWidget {
  final String uid;

  const _PortalSummary({required this.uid});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final wide = Responsive.isSplitLayout(context);
    return StreamBuilder<UserProgressSummary>(
      stream: ProgressRepository.streamSummary(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return ShimmerSkeleton(height: wide ? 64 : 76, borderRadius: 14);
        }
        final summary = snapshot.data ?? UserProgressSummary.empty();
        return AnimatedFadeSlide(
          duration: AppMotion.fast,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: wide ? 12 : 16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primaryContainer.withValues(alpha: 0.2),
                  cs.surfaceContainerHighest.withValues(alpha: 0.35),
                ],
              ),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 10,
              children: [
                _Kpi(
                  label: 'Meilleur',
                  value: '${summary.bestScore} / 699',
                  highlight: summary.bestScore >= 500,
                ),
                _Kpi(label: 'Dernier', value: '${summary.lastScore} / 699'),
                _Kpi(
                  label: 'Moyenne',
                  value: summary.averageScore == 0
                      ? '0'
                      : summary.averageScore.toStringAsFixed(1),
                ),
                _Kpi(label: 'Tentatives', value: '${summary.attemptsCount}'),
                _Kpi(
                  label: 'Serie',
                  value: '${summary.currentStreak} j',
                  highlight: summary.currentStreak >= 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PortalActions extends StatelessWidget {
  final String uid;
  final bool compact;

  const _PortalActions({required this.uid, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? 8 : 10,
      runSpacing: compact ? 8 : 10,
      children: [
        _ActionButton(
          label: 'Plan d\'etude',
          icon: Icons.event_note_rounded,
          compact: compact,
          onTap: () {
            Navigator.push(
              context,
              AppRoutes.fadeSlide(const StudyPlanScreen()),
            );
          },
        ),
        _ActionButton(
          label: 'File de revision',
          icon: Icons.assignment_late_rounded,
          compact: compact,
          onTap: () {
            Navigator.push(
              context,
              AppRoutes.fadeSlide(ReviewQueueScreen(uid: uid)),
            );
          },
        ),
        _ActionButton(
          label: 'Profil',
          icon: Icons.account_circle_rounded,
          compact: compact,
          onTap: () {
            Navigator.push(context, AppRoutes.fadeSlide(const ProfileScreen()));
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 10 : 13,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: cs.primary),
            ),
            SizedBox(width: compact ? 8 : 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: compact ? 12.5 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressInsights extends StatelessWidget {
  final String uid;
  final bool compact;

  const _ProgressInsights({required this.uid, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ProgressRepository.streamRecentAttempts(uid, limit: 8),
      builder: (context, attemptsSnap) {
        final attempts = attemptsSnap.data ?? const <Map<String, dynamic>>[];
        final moduleAverages = _moduleAverages(attempts);
        final trendText = _trendText(attempts);
        return StreamBuilder<List<ReviewQueueItem>>(
          stream: ProgressRepository.streamReviewQueue(uid, limit: 40),
          builder: (context, reviewSnap) {
            final queueCount = reviewSnap.data?.length ?? 0;
            final nextAction = _nextActionText(
              queueCount: queueCount,
              trendText: trendText,
              attemptsCount: attempts.length,
            );
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(compact ? 14 : 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: cs.surface,
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          size: 18,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Analyse de progression',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primaryContainer.withValues(alpha: 0.4),
                          cs.secondaryContainer.withValues(alpha: 0.25),
                        ],
                      ),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bolt_rounded, size: 20, color: cs.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            nextAction,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InsightChip(
                        label: 'File: $queueCount',
                        highlighted: queueCount > 0,
                      ),
                      _InsightChip(
                        label: 'Tendance: $trendText',
                        highlighted: trendText == 'en hausse',
                      ),
                      _InsightChip(
                        label:
                            "CE: ${moduleAverages['CE']?.toStringAsFixed(1) ?? '0.0'}",
                      ),
                      _InsightChip(
                        label:
                            "CO: ${moduleAverages['CO']?.toStringAsFixed(1) ?? '0.0'}",
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  if (attempts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Passez votre premier test pour afficher l\'historique recent.',
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...attempts
                        .take(compact ? 3 : 4)
                        .map(
                          (attempt) => Padding(
                            padding: EdgeInsets.only(bottom: compact ? 6 : 8),
                            child: _AttemptRow(attempt: attempt),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

String _nextActionText({
  required int queueCount,
  required String trendText,
  required int attemptsCount,
}) {
  if (queueCount >= 8) {
    return 'Action suivante: traitez au moins 3 elements de revision avant un nouveau test.';
  }
  if (trendText == 'dropping') {
    return 'Action suivante: refaites un module faible en conditions chronometrees.';
  }
  if (attemptsCount == 0) {
    return 'Action suivante: passez un premier test pour etablir votre niveau.';
  }
  return 'Action suivante: faites une serie mixte et terminez le plan du jour.';
}

class _InsightChip extends StatelessWidget {
  final String label;
  final bool highlighted;

  const _InsightChip({required this.label, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: highlighted
            ? cs.primaryContainer.withValues(alpha: 0.55)
            : cs.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(
          color: highlighted
              ? cs.primary.withValues(alpha: 0.4)
              : cs.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
          color: highlighted ? cs.primary : null,
        ),
      ),
    );
  }
}

class _AttemptRow extends StatelessWidget {
  final Map<String, dynamic> attempt;

  const _AttemptRow({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final module = (attempt['moduleType'] ?? 'CE').toString();
    final title =
        (attempt['testTitle'] ?? attempt['testId'] ?? 'Serie pratique')
            .toString();
    final score = _asNum(attempt['score']).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Text(
            module,
            style: TextStyle(fontWeight: FontWeight.w900, color: cs.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(
            '$score / 699',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _Kpi({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      padding: EdgeInsets.symmetric(
        horizontal: highlight ? 10 : 0,
        vertical: highlight ? 6 : 0,
      ),
      decoration: highlight
          ? BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: highlight ? 0.85 : 0.68),
              fontSize: 12,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: highlight ? cs.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, double> _moduleAverages(List<Map<String, dynamic>> attempts) {
  double ceTotal = 0;
  double coTotal = 0;
  int ceCount = 0;
  int coCount = 0;
  for (final attempt in attempts) {
    final score = _asNum(attempt['score']);
    if ((attempt['moduleType'] ?? '').toString() == 'CO') {
      coTotal += score;
      coCount++;
    } else {
      ceTotal += score;
      ceCount++;
    }
  }
  return {
    'CE': ceCount == 0 ? 0 : ceTotal / ceCount,
    'CO': coCount == 0 ? 0 : coTotal / coCount,
  };
}

String _trendText(List<Map<String, dynamic>> attempts) {
  if (attempts.length < 2) return 'reference';
  final latest = attempts.take(2).map((e) => _asNum(e['score'])).toList();
  final earlier = attempts
      .skip(2)
      .take(2)
      .map((e) => _asNum(e['score']))
      .toList();
  if (earlier.isEmpty) return 'reference';
  final latestAvg = latest.reduce((a, b) => a + b) / latest.length;
  final earlierAvg = earlier.reduce((a, b) => a + b) / earlier.length;
  if (latestAvg >= earlierAvg + 15) return 'en hausse';
  if (latestAvg <= earlierAvg - 15) return 'en baisse';
  return 'stable';
}

double _asNum(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
