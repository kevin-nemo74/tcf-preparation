import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';

class ReviewScreen extends StatefulWidget {
  final TestModel test;
  final Map<String, String> userAnswers;

  const ReviewScreen({
    super.key,
    required this.test,
    required this.userAnswers,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int selectedIndex = 0;

  /// Toggle: show/hide points (requested)
  bool showPoints = true;

  int getQuestionPoints(int questionNumber) {
    if (questionNumber >= 1 && questionNumber <= 4) return 3;
    if (questionNumber >= 5 && questionNumber <= 10) return 9;
    if (questionNumber >= 11 && questionNumber <= 19) return 15;
    if (questionNumber >= 20 && questionNumber <= 29) return 21;
    if (questionNumber >= 30 && questionNumber <= 35) return 26;
    if (questionNumber >= 36 && questionNumber <= 39) return 33;
    return 0;
  }

  bool isCorrectAt(int index) {
    final q = widget.test.questions[index];
    final ua = widget.userAnswers[q.id];
    return ua != null && ua == q.correctAnswer;
  }

  bool isAnsweredAt(int index) {
    final q = widget.test.questions[index];
    return widget.userAnswers[q.id] != null;
  }

  int earnedPointsAt(int index) {
    final points = getQuestionPoints(index + 1);
    return isCorrectAt(index) ? points : 0;
  }

  int possiblePointsAt(int index) => getQuestionPoints(index + 1);

  int calculateCorrectCount() {
    int correct = 0;
    for (int i = 0; i < widget.test.questions.length; i++) {
      if (isCorrectAt(i)) correct++;
    }
    return correct;
  }

  int calculateEarnedPointsTotal() {
    int total = 0;
    for (int i = 0; i < widget.test.questions.length; i++) {
      total += earnedPointsAt(i);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalQ = widget.test.questions.length;
    final correctCount = calculateCorrectCount();
    final wrongCount = totalQ - correctCount;
    final earnedTotal = calculateEarnedPointsTotal();

    final question = widget.test.questions[selectedIndex];
    final userAnswer = widget.userAnswers[question.id];
    final correctAnswer = question.correctAnswer;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Answers"),
        actions: [
          Row(
            children: [
              const Icon(Icons.toll, size: 18),
              const SizedBox(width: 6),
              Text(
                "Points",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Switch.adaptive(
                value: showPoints,
                onChanged: (v) => setState(() => showPoints = v),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980; // great for web/tablet
          final sidePadding = isWide ? 18.0 : 16.0;

          final summaryCard = _SummaryCard(
            correct: correctCount,
            wrong: wrongCount,
            total: totalQ,
            earnedTotal: earnedTotal,
            showPoints: showPoints,
          );

          final grid = _QuestionGrid(
            total: totalQ,
            selectedIndex: selectedIndex,
            showPoints: showPoints,
            isCorrectAt: isCorrectAt,
            isAnsweredAt: isAnsweredAt,
            earnedPointsAt: earnedPointsAt,
            possiblePointsAt: possiblePointsAt,
            onTap: (i) => setState(() => selectedIndex = i),
          );

          final detail = _QuestionDetail(
            index: selectedIndex,
            imagePath: question.imagePath,
            options: question.options,
            userAnswer: userAnswer,
            correctAnswer: correctAnswer,
            showPoints: showPoints,
            earnedPoints: earnedPointsAt(selectedIndex),
            possiblePoints: possiblePointsAt(selectedIndex),
            onPrev: selectedIndex > 0
                ? () => setState(() => selectedIndex--)
                : null,
            onNext: selectedIndex < totalQ - 1
                ? () => setState(() => selectedIndex++)
                : null,
          );

          if (!isWide) {
            // Mobile layout: Summary -> Grid -> Detail
            return SafeArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                    sidePadding, 14, sidePadding, 24),
                children: [
                  summaryCard,
                  const SizedBox(height: 14),
                  _SectionTitle(title: "Quick Navigation"),
                  const SizedBox(height: 10),
                  SizedBox(height: 120, child: grid),
                  const SizedBox(height: 16),
                  detail,
                ],
              ),
            );
          }

          // Wide/Web layout: left column (summary + grid) | right column (detail)
          return SafeArea(
            child: Padding(
              padding:
              EdgeInsets.fromLTRB(sidePadding, 14, sidePadding, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT
                  SizedBox(
                    width: 360,
                    child: Column(
                      children: [
                        summaryCard,
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _SectionTitle(title: "Quick Navigation"),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.35),
                              padding: const EdgeInsets.all(12),
                              child: GridView.builder(
                                itemCount: totalQ,
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                ),
                                itemBuilder: (context, index) {
                                  // Reuse same grid tile builder for wide layout
                                  return _GridTile(
                                    index: index,
                                    selectedIndex: selectedIndex,
                                    showPoints: showPoints,
                                    isCorrect: isCorrectAt(index),
                                    isAnswered: isAnsweredAt(index),
                                    earned: earnedPointsAt(index),
                                    possible: possiblePointsAt(index),
                                    onTap: () => setState(() => selectedIndex = index),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // RIGHT
                  Expanded(
                    child: SingleChildScrollView(
                      child: detail,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// =======================
/// UI Components
/// =======================

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int correct;
  final int wrong;
  final int total;
  final int earnedTotal;
  final bool showPoints;

  const _SummaryCard({
    required this.correct,
    required this.wrong,
    required this.total,
    required this.earnedTotal,
    required this.showPoints,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withOpacity(0.55),
            cs.secondaryContainer.withOpacity(0.55),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Performance Overview",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatPill(
                label: "Correct",
                value: "$correct",
                color: Colors.green,
              ),
              _StatPill(
                label: "Wrong",
                value: "$wrong",
                color: Colors.red,
              ),
              _StatPill(
                label: "Total",
                value: "$total",
                color: cs.primary,
              ),
            ],
          ),
          if (showPoints) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.surface.withOpacity(0.55),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Total Points Earned: ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    "$earnedTotal / 699",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 98,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.65),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionGrid extends StatelessWidget {
  final int total;
  final int selectedIndex;
  final bool showPoints;

  final bool Function(int index) isCorrectAt;
  final bool Function(int index) isAnsweredAt;
  final int Function(int index) earnedPointsAt;
  final int Function(int index) possiblePointsAt;
  final ValueChanged<int> onTap;

  const _QuestionGrid({
    required this.total,
    required this.selectedIndex,
    required this.showPoints,
    required this.isCorrectAt,
    required this.isAnsweredAt,
    required this.earnedPointsAt,
    required this.possiblePointsAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Horizontal 2-row grid for mobile; wide layout uses _GridTile directly.
    return GridView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: total,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return _GridTile(
          index: index,
          selectedIndex: selectedIndex,
          showPoints: showPoints,
          isCorrect: isCorrectAt(index),
          isAnswered: isAnsweredAt(index),
          earned: earnedPointsAt(index),
          possible: possiblePointsAt(index),
          onTap: () => onTap(index),
        );
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final bool showPoints;
  final bool isCorrect;
  final bool isAnswered;
  final int earned;
  final int possible;
  final VoidCallback onTap;

  const _GridTile({
    required this.index,
    required this.selectedIndex,
    required this.showPoints,
    required this.isCorrect,
    required this.isAnswered,
    required this.earned,
    required this.possible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    Color bg;
    if (!isAnswered) {
      bg = Colors.grey.shade400;
    } else if (isCorrect) {
      bg = Colors.green;
    } else {
      bg = Colors.red;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: bg.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                "${index + 1}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            if (showPoints)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.22),
                  ),
                  child: Text(
                    // earned/possible
                    "$earned/$possible",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuestionDetail extends StatelessWidget {
  final int index;
  final String imagePath;
  final List<dynamic> options; // OptionModel list (dynamic to avoid extra import here)
  final String? userAnswer;
  final String correctAnswer;

  final bool showPoints;
  final int earnedPoints;
  final int possiblePoints;

  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _QuestionDetail({
    required this.index,
    required this.imagePath,
    required this.options,
    required this.userAnswer,
    required this.correctAnswer,
    required this.showPoints,
    required this.earnedPoints,
    required this.possiblePoints,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: cs.surface,
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              Text(
                "Question ${index + 1}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (showPoints)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: cs.surfaceContainerHighest.withOpacity(0.45),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.toll, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "Earned: $earnedPoints / $possiblePoints",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Image with better responsiveness
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: kIsWeb ? 520 : 460,
                maxWidth: 900,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  color: cs.surfaceContainerHighest.withOpacity(0.28),
                  padding: const EdgeInsets.all(10),
                  child: InteractiveViewer(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Options
          ...options.map((opt) {
            final String optId = (opt as dynamic).id as String;
            final String optText = (opt as dynamic).text as String;

            final bool isUser = userAnswer == optId;
            final bool isCorrect = correctAnswer == optId;

            Color border = Colors.grey.shade300;
            Color bg = cs.surfaceContainerHighest.withOpacity(0.28);

            if (isCorrect) {
              border = Colors.green;
              bg = Colors.green.withOpacity(0.10);
            }
            if (isUser && !isCorrect) {
              border = Colors.red;
              bg = Colors.red.withOpacity(0.10);
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: bg,
                border: Border.all(color: border, width: 1.6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$optId. ",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Expanded(child: Text(optText)),
                  const SizedBox(width: 10),
                  if (isCorrect)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20)
                  else if (isUser && !isCorrect)
                    const Icon(Icons.cancel, color: Colors.red, size: 20),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 14),

          // Bottom navigation
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrev,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Previous"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Next"),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
