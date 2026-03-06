import 'package:flutter/material.dart';

import '../../settings/settings_screen.dart';
import '../data/local_tests_data.dart';
import '../data/models/test_model.dart';
import 'question_screen.dart';

class TestListScreen extends StatefulWidget {
  /// If true: show the big header + settings icon (standalone page)
  /// If false: show only the list/grid (for embedding in the hub tab)
  final bool showHeader;

  const TestListScreen({super.key, this.showHeader = true});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  late Future<List<TestModel>> testsFuture;

  @override
  void initState() {
    super.initState();
    testsFuture = LocalTestsData.loadTests();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // When embedded in hub: we don't want a second Scaffold background conflict.
      // But leaving Scaffold is ok since it's inside a TabBarView; we keep it simple.
      body: SafeArea(
        child: FutureBuilder<List<TestModel>>(
          future: testsFuture,
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Failed to load tests:\n${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Null/empty
            final tests = snapshot.data;
            if (tests == null || tests.isEmpty) {
              return const Center(child: Text("No tests available"));
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ===== HEADER (optional) =====
                  if (widget.showHeader) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _Header(
                            title: "TCF Canada Preparation",
                            subtitle: "Compréhension Écrite",
                            count: tests.length,
                          ),
                        ),
                        IconButton(
                          tooltip: "Settings",
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// ===== Quick hint strip =====
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: cs.surfaceContainerHighest.withOpacity(0.55),
                        border: Border.all(
                          color: cs.outlineVariant.withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.menu_book, color: cs.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Choose a test and start practicing.",
                              style: textTheme.bodyMedium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: cs.primaryContainer.withOpacity(0.7),
                            ),
                            child: Text(
                              "${tests.length} tests",
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ] else ...[
                    // Small spacing for embedded mode
                    const SizedBox(height: 6),
                  ],

                  /// ===== TESTS LIST/GRID =====
                  Expanded(
                    child: isWide
                        ? GridView.builder(
                            itemCount: tests.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.35,
                                ),
                            itemBuilder: (context, index) {
                              final test = tests[index];
                              return _TestCard(
                                test: test,
                                onStart: () => _openTest(context, test),
                              );
                            },
                          )
                        : ListView.separated(
                            itemCount: tests.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final test = tests[index];
                              return _TestCard(
                                test: test,
                                onStart: () => _openTest(context, test),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openTest(BuildContext context, TestModel test) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuestionScreen(test: test)),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.secondaryContainer.withOpacity(0.65),
              ),
              child: Text(
                subtitle,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TestCard extends StatelessWidget {
  final TestModel test;
  final VoidCallback onStart;

  const _TestCard({required this.test, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onStart,
      borderRadius: BorderRadius.circular(26),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    test.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: cs.primaryContainer.withOpacity(0.65),
                  ),
                  child: Icon(Icons.play_arrow, color: cs.onPrimaryContainer),
                ),
              ],
            ),
            Row(
              children: [
                _InfoChip(icon: Icons.quiz, text: "${test.questions.length} Q"),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.timer,
                  text: "${test.durationMinutes} min",
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                child: const Text("Start"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHighest.withOpacity(0.55),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
