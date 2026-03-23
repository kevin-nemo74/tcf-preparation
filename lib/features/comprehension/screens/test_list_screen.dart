import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/telemetry/app_analytics.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/local_tests_data.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';

import 'question_screen.dart';

class TestListScreen extends StatefulWidget {
  final bool showHeader;

  const TestListScreen({super.key, this.showHeader = true});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
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
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, __) => const ShimmerSkeleton(height: 72),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text("Failed to load CE tests:\n${snapshot.error}"));
        }

        final tests = snapshot.data ?? [];
        if (tests.isEmpty) {
          return const Center(child: Text("No tests available"));
        }

        selectedTest ??= tests.first;

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: uid == null
              ? Stream.value(const <Map<String, dynamic>>[])
              : ProgressRepository.streamRecentAttempts(uid, limit: 100),
          builder: (context, attemptsSnap) {
            final attempts = attemptsSnap.data ?? const <Map<String, dynamic>>[];
            final bestScores = _bestScoreByTestId(attempts);
            final latestScores = _latestScoreByTestId(attempts);

            if (!isWide) {
              return StreamBuilder<UserProgressSummary>(
                stream: uid == null ? null : ProgressRepository.streamSummary(uid),
                builder: (context, progressSnap) {
                  final summary = progressSnap.data ?? UserProgressSummary.empty();
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tests.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _AdaptiveHeader(summary: summary);
                      }
                      final test = tests[index - 1];
                      final row = _TestRow(
                        title: test.title,
                        subtitle:
                            "${test.questions.length} questions • ${test.durationMinutes} min • Best ${_scoreText(bestScores[test.id])}",
                        leading: _testNumberFromId(test.id),
                        isSelected: false,
                        onTap: () => _start(context, test),
                      );
                      return AnimatedFadeSlide(
                        delay: AppMotion.fast +
                            Duration(milliseconds: 40 * (index - 1)),
                        child: row,
                      );
                    },
                  );
                },
              );
            }

            return Row(
              children: [
                SizedBox(
                  width: 430,
                  child: StreamBuilder<UserProgressSummary>(
                    stream: uid == null ? null : ProgressRepository.streamSummary(uid),
                    builder: (context, progressSnap) {
                      final summary = progressSnap.data ?? UserProgressSummary.empty();
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: tests.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _AdaptiveHeader(summary: summary);
                          }
                          final test = tests[index - 1];
                          final isSelected = selectedTest?.id == test.id;
                          final row = _TestRow(
                            title: test.title,
                            subtitle:
                                "${test.questions.length} questions • ${test.durationMinutes} min • Best ${_scoreText(bestScores[test.id])} • Last ${_scoreText(latestScores[test.id])}",
                            leading: _testNumberFromId(test.id),
                            isSelected: isSelected,
                            onTap: () => setState(() => selectedTest = test),
                          );
                          return AnimatedFadeSlide(
                            delay: AppMotion.fast +
                                Duration(milliseconds: 40 * (index - 1)),
                            child: row,
                          );
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      isWide ? 8 : 16,
                      isWide ? 12 : 16,
                      isWide ? 8 : 16,
                    ),
                    child: AnimatedSwitcher(
                      duration: contextReducedMotion(context)
                          ? Duration.zero
                          : AppMotion.medium,
                      switchInCurve: AppMotion.curve,
                      switchOutCurve: AppMotion.curve,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
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
    Navigator.push(
      context,
      AppRoutes.fadeSlide(QuestionScreen(test: test)),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: 0.65,
                          ),
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
              color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.6,
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

  const _DetailsPanel({
    required this.test,
    required this.bestScore,
    required this.onStart,
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
                      border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events_rounded, color: cs.primary),
                        const SizedBox(width: 10),
                        Text(
                          "Best: ${_scoreText(bestScore)}",
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
            label: const Text("Start Test"),
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
    final cs = Theme.of(context).colorScheme;
    final needsPractice = summary.lastScore > 0 && summary.lastScore < summary.bestScore;
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
                  ? "Adaptive: focus on weak answers from recent attempts."
                  : "Adaptive: keep practicing to establish baseline.",
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
