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
    final cs = Theme.of(context).colorScheme;
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
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PortalSummary(uid: resolvedUid),
                          const SizedBox(height: 10),
                          _PortalActions(uid: resolvedUid, compact: true),
                          const SizedBox(height: 10),
                          StudyPlanPortalCard(uid: resolvedUid),
                          const SizedBox(height: 10),
                          _ProgressInsights(uid: resolvedUid, compact: true),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _PortalSummary(uid: resolvedUid),
                        const SizedBox(height: 10),
                        _PortalActions(uid: resolvedUid),
                        const SizedBox(height: 10),
                        StudyPlanPortalCard(uid: resolvedUid),
                        const SizedBox(height: 10),
                        _ProgressInsights(uid: resolvedUid),
                      ],
                    )
            : Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    'Connectez-vous pour acceder au tableau de bord',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
              vertical: wide ? 10 : 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 8,
              children: [
                _Kpi(label: 'Meilleur', value: '${summary.bestScore} / 699'),
                _Kpi(label: 'Dernier', value: '${summary.lastScore} / 699'),
                _Kpi(
                  label: 'Moyenne',
                  value: summary.averageScore == 0
                      ? '0'
                      : summary.averageScore.toStringAsFixed(1),
                ),
                _Kpi(label: 'Tentatives', value: '${summary.attemptsCount}'),
                _Kpi(label: 'Serie', value: '${summary.currentStreak} j'),
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
          horizontal: compact ? 10 : 14,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: cs.primary),
            SizedBox(width: compact ? 6 : 8),
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
              padding: EdgeInsets.all(compact ? 12 : 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analyse de progression',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.35),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            nextAction,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InsightChip(label: 'File de revision: $queueCount'),
                      _InsightChip(label: 'Tendance: $trendText'),
                      _InsightChip(
                        label:
                            "Moy CE: ${moduleAverages['CE']?.toStringAsFixed(1) ?? '0.0'}",
                      ),
                      _InsightChip(
                        label:
                            "Moy CO: ${moduleAverages['CO']?.toStringAsFixed(1) ?? '0.0'}",
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 8 : 12),
                  if (attempts.isEmpty)
                    Text(
                      'Passez votre premier test pour afficher l\'historique recent.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
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

  const _InsightChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
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
  const _Kpi({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.68),
              fontSize: 12,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
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
