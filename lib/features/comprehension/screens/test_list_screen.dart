import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/telemetry/app_analytics.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/local_tests_data.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/l10n/app_localizations.dart';

import 'question_screen.dart';

class TestListScreen extends StatefulWidget {
  final bool showHeader;

  const TestListScreen({super.key, this.showHeader = true});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

Widget _buildTestListHeader(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cs.primaryContainer.withValues(alpha: 0.6),
          cs.tertiaryContainer.withValues(alpha: 0.4),
          cs.secondaryContainer.withValues(alpha: 0.2),
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
          child: Icon(Icons.menu_book_rounded, color: cs.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tests Ecrits',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Comprehension ecrite (CE)',
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

class _TestListScreenState extends State<TestListScreen> {
  late Future<List<TestModel>> testsFuture;
  TestModel? selectedTest;

  @override
  void initState() {
    super.initState();
    testsFuture = LocalTestsData.loadTests();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isWide = Responsive.isSplitLayout(context);
    final uid = ProgressRepository.currentUid;

    return FutureBuilder<List<TestModel>>(
      future: testsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 8,
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemBuilder: (_, index) => const ShimmerSkeleton(height: 72),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text("${l10n.ceLoadError}\n${snapshot.error}"));
        }

        final tests = snapshot.data ?? [];
        if (tests.isEmpty) {
          return Center(child: Text(l10n.ceEmptyState));
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
                builder: (context, progressSnap) {
                  final summary =
                      progressSnap.data ?? UserProgressSummary.empty();
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      _buildTestListHeader(context),
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
                    builder: (context, progressSnap) {
                      final summary =
                          progressSnap.data ?? UserProgressSummary.empty();
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        children: [
                          _buildTestListHeader(context),
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

  void _start(BuildContext context, TestModel test) {
    AppAnalytics.logTestStarted(moduleType: 'CE', testId: test.id);
    Navigator.push(context, AppRoutes.fadeSlide(QuestionScreen(test: test)));
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
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? cs.primaryContainer.withValues(alpha: 0.45)
              : cs.surface,
          border: Border.all(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.55)
                : cs.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? cs.primary.withValues(alpha: 0.08)
                  : cs.shadow.withValues(alpha: 0.03),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primaryContainer.withValues(
                      alpha: isSelected ? 0.7 : 0.5,
                    ),
                    cs.secondaryContainer.withValues(
                      alpha: isSelected ? 0.5 : 0.3,
                    ),
                  ],
                ),
                border: Border.all(
                  color: cs.primary.withValues(alpha: isSelected ? 0.4 : 0.2),
                ),
              ),
              child: Text(
                leading,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: cs.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final TestModel test;
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
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
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
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.quiz_rounded, size: 16, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          "${test.questions.length} questions",
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.timer_rounded, size: 16, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          "${test.durationMinutes} min",
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primaryContainer.withValues(alpha: 0.3),
                          cs.secondaryContainer.withValues(alpha: 0.2),
                        ],
                      ),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: cs.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meilleur Score',
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _scoreText(bestScore),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.ceStartTestCta),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.35),
            cs.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: cs.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
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
