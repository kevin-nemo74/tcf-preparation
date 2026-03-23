import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/core/widgets/responsive_frame.dart';
import 'package:tcf_canada_preparation/l10n/app_localizations.dart';
import 'package:tcf_canada_preparation/features/comprehension/screens/test_list_screen.dart';
import 'package:tcf_canada_preparation/features/profile/profile_screen.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/features/progress/review_queue_screen.dart';
import 'package:tcf_canada_preparation/features/progress/study_plan_screen.dart';

import '../oral/screens/oral_test_list_screen.dart';
import '../settings/settings_screen.dart';
import 'study_plan_portal_card.dart';

class ExamPortalScreen extends StatelessWidget {
  final String? uid;

  const ExamPortalScreen({super.key, this.uid});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final resolvedUid = uid ?? ProgressRepository.currentUid;
    final wide = kIsWeb
        ? Responsive.isTabletWeb(context)
        : Responsive.isSplitLayout(context);
    final webDesktopDashboard = kIsWeb && wide;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          actions: [
            if (!wide && resolvedUid != null)
              IconButton(
                tooltip: "Dashboard",
                icon: const Icon(Icons.dashboard_customize_rounded),
                onPressed: () =>
                    _openMobileDashboardSheet(context, resolvedUid),
              ),
            IconButton(
              tooltip: "Settings",
              icon: const Icon(Icons.settings_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  AppRoutes.fadeSlide(const SettingsScreen()),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
              Responsive.isDesktopWeb(context) ? 70 : 64,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.isDesktopWeb(context) ? 24 : 16,
                0,
                Responsive.isDesktopWeb(context) ? 24 : 16,
                12,
              ),
              child: Container(
                height: Responsive.isDesktopWeb(context) ? 56 : 52,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: TabBar(
                  isScrollable: false,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorAnimation: TabIndicatorAnimation.elastic,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: cs.primaryContainer.withValues(alpha: 0.75),
                  ),
                  labelColor: cs.onPrimaryContainer,
                  unselectedLabelColor: cs.onSurface.withValues(alpha: 0.75),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.menu_book_rounded, size: 18),
                      text: "Écrite",
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                    Tab(
                      icon: Icon(Icons.headphones_rounded, size: 18),
                      text: "Orale",
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: Responsive.horizontalInset(context),
          child: ResponsiveFrame(
            child: webDesktopDashboard
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (resolvedUid != null)
                        SizedBox(
                          width: Responsive.splitListPaneWidth(context),
                          child: SingleChildScrollView(
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
                                _ProgressInsights(
                                  uid: resolvedUid,
                                  compact: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (resolvedUid != null) const SizedBox(width: 14),
                      const Expanded(child: _DesktopTabPanel()),
                    ],
                  )
                : wide
                ? Column(
                    children: [
                      if (resolvedUid != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: _PortalSummary(uid: resolvedUid),
                        ),
                      if (resolvedUid != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          child: _PortalActions(uid: resolvedUid),
                        ),
                      if (resolvedUid != null)
                        StudyPlanPortalCard(uid: resolvedUid),
                      if (resolvedUid != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                          child: _ProgressInsights(uid: resolvedUid),
                        ),
                      const Expanded(
                        child: TabBarView(
                          children: [
                            TestListScreen(showHeader: false),
                            OralTestListScreen(),
                          ],
                        ),
                      ),
                    ],
                  )
                : const TabBarView(
                    children: [
                      TestListScreen(showHeader: false),
                      OralTestListScreen(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

Future<void> _openMobileDashboardSheet(BuildContext context, String uid) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.9,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'Dashboard',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _PortalSummary(uid: uid),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _PortalActions(uid: uid),
              ),
              StudyPlanPortalCard(uid: uid),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _ProgressInsights(uid: uid),
              ),
            ],
          ),
        ),
      );
    },
  );
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
                _Kpi(label: 'Best', value: '${summary.bestScore} / 699'),
                _Kpi(label: 'Last', value: '${summary.lastScore} / 699'),
                _Kpi(
                  label: 'Average',
                  value: summary.averageScore == 0
                      ? '0'
                      : summary.averageScore.toStringAsFixed(1),
                ),
                _Kpi(label: 'Attempts', value: '${summary.attemptsCount}'),
                _Kpi(label: 'Streak', value: '${summary.currentStreak} d'),
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
          label: 'Study Plan',
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
          label: 'Review Queue',
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
          label: 'Profile',
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
                    'Progress Insights',
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
                      _InsightChip(label: 'Review queue: $queueCount'),
                      _InsightChip(label: 'Trend: $trendText'),
                      _InsightChip(
                        label:
                            "CE avg: ${moduleAverages['CE']?.toStringAsFixed(1) ?? '0.0'}",
                      ),
                      _InsightChip(
                        label:
                            "CO avg: ${moduleAverages['CO']?.toStringAsFixed(1) ?? '0.0'}",
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 8 : 12),
                  if (attempts.isEmpty)
                    Text(
                      'Complete your first test to unlock recent attempt history.',
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

class _DesktopTabPanel extends StatelessWidget {
  const _DesktopTabPanel();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: const TabBarView(
        children: [TestListScreen(showHeader: false), OralTestListScreen()],
      ),
    );
  }
}

String _nextActionText({
  required int queueCount,
  required String trendText,
  required int attemptsCount,
}) {
  if (queueCount >= 8) {
    return 'Next action: clear at least 3 review queue items before a new test.';
  }
  if (trendText == 'dropping') {
    return 'Next action: retake one weak module with timed conditions.';
  }
  if (attemptsCount == 0) {
    return 'Next action: complete your first practice test to build a baseline.';
  }
  return 'Next action: run one mixed set and finish today\'s study plan tasks.';
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
    final title = (attempt['testTitle'] ?? attempt['testId'] ?? 'Practice set')
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
  if (attempts.length < 2) return 'baseline';
  final latest = attempts.take(2).map((e) => _asNum(e['score'])).toList();
  final earlier = attempts
      .skip(2)
      .take(2)
      .map((e) => _asNum(e['score']))
      .toList();
  if (earlier.isEmpty) return 'baseline';
  final latestAvg = latest.reduce((a, b) => a + b) / latest.length;
  final earlierAvg = earlier.reduce((a, b) => a + b) / earlier.length;
  if (latestAvg >= earlierAvg + 15) return 'improving';
  if (latestAvg <= earlierAvg - 15) return 'dropping';
  return 'steady';
}

double _asNum(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
