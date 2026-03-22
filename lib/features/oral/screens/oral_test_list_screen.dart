import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import '../data/local_oral_tests_data.dart';
import '../data/models/oral_test_model.dart';
import 'oral_question_screen.dart';

class OralTestListScreen extends StatefulWidget {
  const OralTestListScreen({super.key});

  @override
  State<OralTestListScreen> createState() => _OralTestListScreenState();
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
          return Center(child: Text("Failed to load CO tests:\n${snapshot.error}"));
        }

        final tests = snapshot.data ?? [];
        if (tests.isEmpty) {
          return const Center(child: Text("No oral tests available"));
        }

        selectedTest ??= tests.first;

        if (!isWide) {
          return StreamBuilder<UserProgressSummary>(
            stream: uid == null ? null : ProgressRepository.streamSummary(uid),
            builder: (context, summarySnap) {
              final summary = summarySnap.data ?? UserProgressSummary.empty();
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: tests.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index == 0) return _AdaptiveHeader(summary: summary);
                  final test = tests[index - 1];
                  final row = _TestRow(
                    title: test.title,
                    subtitle: "${test.questions.length} questions • ${test.durationMinutes} min • Best ${summary.bestScore}/699",
                    leading: _testNumberFromId(test.id),
                    isSelected: false,
                    onTap: () => _start(context, test),
                  );
                  return AnimatedFadeSlide(
                    delay: AppMotion.fast + Duration(milliseconds: 40 * (index - 1)),
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
                builder: (context, summarySnap) {
                  final summary = summarySnap.data ?? UserProgressSummary.empty();
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tests.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == 0) return _AdaptiveHeader(summary: summary);
                      final test = tests[index - 1];
                      final isSelected = selectedTest?.id == test.id;
                      final row = _TestRow(
                        title: test.title,
                        subtitle: "${test.questions.length} questions • ${test.durationMinutes} min • Last ${summary.lastScore}/699",
                        leading: _testNumberFromId(test.id),
                        isSelected: isSelected,
                        onTap: () => setState(() => selectedTest = test),
                      );
                      return AnimatedFadeSlide(
                        delay: AppMotion.fast + Duration(milliseconds: 40 * (index - 1)),
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
                  duration: contextReducedMotion(context) ? Duration.zero : AppMotion.medium,
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
  }

  void _start(BuildContext context, OralTestModel test) {
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
  final OralTestModel test;
  final VoidCallback onStart;

  const _DetailsPanel({
    required this.test,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const bestScoreText = "Best: — / 699";

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
                          bestScoreText,
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
                  ? "Adaptive: prioritize oral weak areas from recent attempts."
                  : "Adaptive: take a few oral sets to calibrate.",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}