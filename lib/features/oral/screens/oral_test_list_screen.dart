import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    testsFuture = LocalOralTestsData.loadTests();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Compréhension Orale"),
      ),
      body: FutureBuilder<List<OralTestModel>>(
        future: testsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final tests = snapshot.data ?? [];
          if (tests.isEmpty) {
            return const Center(child: Text("No oral tests found."));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? GridView.builder(
              itemCount: tests.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (_, i) => _OralTestCard(
                test: tests[i],
                onStart: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OralQuestionScreen(test: tests[i]),
                    ),
                  );
                },
              ),
            )
                : ListView.separated(
              itemCount: tests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OralTestCard(
                test: tests[i],
                onStart: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OralQuestionScreen(test: tests[i]),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      backgroundColor: cs.surface,
    );
  }
}

class _OralTestCard extends StatelessWidget {
  final OralTestModel test;
  final VoidCallback onStart;

  const _OralTestCard({
    required this.test,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              test.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Row(
              children: [
                _Chip(icon: Icons.quiz, text: "${test.questions.length} Q"),
                const SizedBox(width: 10),
                _Chip(icon: Icons.timer, text: "${test.durationMinutes} min"),
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

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
          Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}