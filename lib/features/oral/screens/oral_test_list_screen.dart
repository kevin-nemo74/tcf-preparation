import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/telemetry/app_analytics.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/l10n/app_localizations.dart';

import '../data/local_oral_tests_data.dart';
import '../data/models/oral_test_model.dart';
import 'oral_question_screen.dart';

class OralTestListScreen extends StatefulWidget {
  const OralTestListScreen({super.key});

  @override
  State<OralTestListScreen> createState() => _OralTestListScreenState();
}

Widget _buildOralTestListHeader(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cs.secondaryContainer.withValues(alpha: 0.6),
          cs.tertiaryContainer.withValues(alpha: 0.4),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.headphones_rounded, color: cs.secondary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tests Oraux',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Comprehension orale (CO)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _OralTestListScreenState extends State<OralTestListScreen> {
  late Future<List<OralTestModel>> testsFuture;
  OralTestModel? selectedTest;

  @override
  void initState() {
    super.initState();
    testsFuture = LocalOralTestsData.loadTests();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isWide = Responsive.isSplitLayout(context);
    final uid = ProgressRepository.currentUid;

    return FutureBuilder<List<OralTestModel>>(
      future: testsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, __) => const ShimmerSkeleton(height: 72),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text("${l10n.coLoadError}\n${snapshot.error}"));
        }

        final tests = snapshot.data ?? [];
        if (tests.isEmpty) {
          return Center(child: Text(l10n.coEmptyState));
        }

        selectedTest ??= tests.first;

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: uid == null
              ? Stream.value(const <Map<String, dynamic>>[])
              : ProgressRepository.streamRecentAttempts(uid, limit: 100),
          builder: (context, attemptsSnap) {
            final attempts =
                attemptsSnap.data ?? const <Map<String, dynamic>>[];
            final bestScores = _bestScoreByTestId(attempts);
            final latestScores = _latestScoreByTestId(attempts);
            final listPaneWidth = Responsive.splitListPaneWidth(context);

            if (!isWide) {
              return StreamBuilder<UserProgressSummary>(
                stream: uid == null
                    ? null
                    : ProgressRepository.streamSummary(uid),
                builder: (context, summarySnap) {
                  final summary =
                      summarySnap.data ?? UserProgressSummary.empty();
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      _buildOralTestListHeader(context),
                      _AdaptiveHeader(summary: summary),
                      const SizedBox(height: 12),
                      ...tests.asMap().entries.map((entry) {
                        final index = entry.key;
                        final test = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AnimatedFadeSlide(
                            delay:
                                AppMotion.fast +
                                Duration(milliseconds: 40 * index),
                            child: _TestRow(
                              title: test.title,
                              subtitle:
                                  "${test.questions.length} questions • ${test.durationMinutes} min • Meilleur ${_scoreText(bestScores[test.id])}",
                              leading: _testNumberFromId(test.id),
                              isSelected: false,
                              onTap: () => _start(context, test),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              );
            }

            return Row(
              children: [
                SizedBox(
                  width: listPaneWidth,
                  child: StreamBuilder<UserProgressSummary>(
                    stream: uid == null
                        ? null
                        : ProgressRepository.streamSummary(uid),
                    builder: (context, summarySnap) {
                      final summary =
                          summarySnap.data ?? UserProgressSummary.empty();
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        children: [
                          _buildOralTestListHeader(context),
                          _AdaptiveHeader(summary: summary),
                          const SizedBox(height: 12),
                          ...tests.asMap().entries.map((entry) {
                            final index = entry.key;
                            final test = entry.value;
                            final isSelected = selectedTest?.id == test.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AnimatedFadeSlide(
                                delay:
                                    AppMotion.fast +
                                    Duration(milliseconds: 40 * index),
                                child: _TestRow(
                                  title: test.title,
                                  subtitle:
                                      "${test.questions.length} questions • ${test.durationMinutes} min • Meilleur ${_scoreText(bestScores[test.id])} • Dernier ${_scoreText(latestScores[test.id])}",
                                  leading: _testNumberFromId(test.id),
                                  isSelected: isSelected,
                                  onTap: () =>
                                      setState(() => selectedTest = test),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      isWide ? 10 : 16,
                      isWide ? 16 : 16,
                      isWide ? 10 : 16,
                    ),
                    child: AnimatedSwitcher(
                      duration: contextReducedMotion(context)
                          ? Duration.zero
                          : AppMotion.medium,
                      switchInCurve: AppMotion.curve,
                      switchOutCurve: AppMotion.curve,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: KeyedSubtree(
                        key: ValueKey<String>(selectedTest!.id),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: cs.surface,
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.35),
                            ),
                          ),
                          child: _DetailsPanel(
                            test: selectedTest!,
                            bestScore: bestScores[selectedTest!.id],
                            onStart: () => _start(context, selectedTest!),
                            l10n: l10n,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _start(BuildContext context, OralTestModel test) {
    AppAnalytics.logTestStarted(moduleType: 'CO', testId: test.id);
    Navigator.push(
      context,
      AppRoutes.fadeSlide(OralQuestionScreen(test: test)),
    );
  }

  String _testNumberFromId(String id) {
    final parts = id.split('_');
    if (parts.length >= 2) return parts[1].toUpperCase();
    return id.toUpperCase();
  }
}

class _TestRow extends StatelessWidget {
  final String leading;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _TestRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? cs.primaryContainer.withValues(alpha: 0.45)
              : cs.surface,
          border: Border.all(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.55)
                : cs.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                leading,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final OralTestModel test;
  final int? bestScore;
  final VoidCallback onStart;
  final AppLocalizations l10n;

  const _DetailsPanel({
    required this.test,
    required this.bestScore,
    required this.onStart,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${test.questions.length} questions • ${test.durationMinutes} minutes",
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: cs.surfaceContainerHighest.withOpacity(0.55),
                      border: Border.all(
                        color: cs.outlineVariant.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events_rounded, color: cs.primary),
                        const SizedBox(width: 10),
                        Text(
                          "Meilleur: ${_scoreText(bestScore)}",
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.ceStartTestCta),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveHeader extends StatelessWidget {
  final UserProgressSummary summary;

  const _AdaptiveHeader({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final needsPractice =
        summary.lastScore > 0 && summary.lastScore < summary.bestScore;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              needsPractice
                  ? l10n.ceHeaderAdviceNeedsPractice
                  : l10n.ceHeaderAdviceEstablishBaseline,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, int> _bestScoreByTestId(List<Map<String, dynamic>> attempts) {
  final bestScores = <String, int>{};
  for (final attempt in attempts) {
    final testId = (attempt['testId'] ?? '').toString();
    if (testId.isEmpty) continue;
    final score = _asInt(attempt['score']);
    final current = bestScores[testId];
    if (current == null || score > current) {
      bestScores[testId] = score;
    }
  }
  return bestScores;
}

Map<String, int> _latestScoreByTestId(List<Map<String, dynamic>> attempts) {
  final latestScores = <String, int>{};
  for (final attempt in attempts) {
    final testId = (attempt['testId'] ?? '').toString();
    if (testId.isEmpty || latestScores.containsKey(testId)) continue;
    latestScores[testId] = _asInt(attempt['score']);
  }
  return latestScores;
}

String _scoreText(int? score) => score == null ? "- / 699" : "$score/699";

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
