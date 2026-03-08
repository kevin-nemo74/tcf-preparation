import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/local_tests_data.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';

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
    final isWide = MediaQuery.of(context).size.width >= 980;

    return FutureBuilder<List<TestModel>>(
      future: testsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Failed to load CE tests:\n${snapshot.error}"));
        }

        final tests = snapshot.data ?? [];
        if (tests.isEmpty) {
          return const Center(child: Text("No tests available"));
        }

        selectedTest ??= tests.first;

        if (!isWide) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final test = tests[index];
              return _TestRow(
                title: test.title,
                subtitle: "${test.questions.length} questions • ${test.durationMinutes} min",
                leading: _testNumberFromId(test.id),
                isSelected: false,
                onTap: () => _start(context, test),
              );
            },
          );
        }

        return Row(
          children: [
            // LEFT LIST
            SizedBox(
              width: 430,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: tests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final test = tests[index];
                  final isSelected = selectedTest?.id == test.id;

                  return _TestRow(
                    title: test.title,
                    subtitle: "${test.questions.length} questions • ${test.durationMinutes} min",
                    leading: _testNumberFromId(test.id),
                    isSelected: isSelected,
                    onTap: () => setState(() => selectedTest = test),
                  );
                },
              ),
            ),

            // RIGHT DETAILS (scroll-safe)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: cs.surface,
                    border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
                  ),
                  child: _DetailsPanel(
                    test: selectedTest!,
                    onStart: () => _start(context, selectedTest!),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _start(BuildContext context, TestModel test) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuestionScreen(test: test)),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? cs.primaryContainer.withOpacity(0.45) : cs.surface,
          border: Border.all(
            color: isSelected
                ? cs.primary.withOpacity(0.55)
                : cs.outlineVariant.withOpacity(0.35),
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
                color: cs.surfaceContainerHighest.withOpacity(0.55),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final TestModel test;
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
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 0),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}