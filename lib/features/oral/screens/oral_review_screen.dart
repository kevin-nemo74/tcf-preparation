import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import '../data/models/oral_question_model.dart';
import '../data/models/oral_test_model.dart';

class OralReviewScreen extends StatefulWidget {
  final OralTestModel test;
  final Map<String, String> userAnswers;

  const OralReviewScreen({
    super.key,
    required this.test,
    required this.userAnswers,
  });

  @override
  State<OralReviewScreen> createState() => _OralReviewScreenState();
}

class _OralReviewScreenState extends State<OralReviewScreen> {
  int selectedIndex = 0;

  bool isCorrectAt(int index) {
    final q = widget.test.questions[index];
    return widget.userAnswers[q.id] == q.correctAnswer;
  }

  bool isAnsweredAt(int index) {
    final q = widget.test.questions[index];
    return widget.userAnswers[q.id] != null;
  }

  int calculateCorrectCount() {
    int correct = 0;
    for (int i = 0; i < widget.test.questions.length; i++) {
      if (isCorrectAt(i)) correct++;
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final total = widget.test.questions.length;
    final correct = calculateCorrectCount();
    final wrong = total - correct;

    final q = widget.test.questions[selectedIndex];
    final userAnswer = widget.userAnswers[q.id];
    final correctAnswer = q.correctAnswer;

    final isWide = MediaQuery.of(context).size.width > 950;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Answers"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 360,
              child: Column(
                children: [
                  _summaryCard(context, cs, correct, wrong, total),
                  const SizedBox(height: 16),
                  Expanded(child: _grid(cs, total)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _animatedDetail(context, cs, q, userAnswer, correctAnswer, selectedIndex),
            ),
          ],
        )
            : Column(
          children: [
            _summaryCard(context, cs, correct, wrong, total),
            const SizedBox(height: 14),
            SizedBox(height: 110, child: _grid(cs, total)),
            const SizedBox(height: 14),
            Expanded(
              child: _animatedDetail(context, cs, q, userAnswer, correctAnswer, selectedIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(BuildContext context, ColorScheme cs, int correct, int wrong, int total) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat("Correct", "$correct", Colors.green),
          _stat("Wrong", "$wrong", Colors.red),
          _stat("Total", "$total", cs.primary),
        ],
      ),
    );
  }

  Widget _stat(String title, String value, Color color) {
    return Column(
      children: [
        Text(title),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _animatedDetail(
    BuildContext context,
    ColorScheme cs,
    OralQuestionModel question,
    String? userAnswer,
    String correctAnswer,
    int index,
  ) {
    return AnimatedSwitcher(
      duration: contextReducedMotion(context) ? Duration.zero : AppMotion.medium,
      switchInCurve: AppMotion.curve,
      switchOutCurve: AppMotion.curve,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: AppMotion.curve)),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(index),
        child: _detailCard(context, cs, question, userAnswer, correctAnswer),
      ),
    );
  }

  Widget _grid(ColorScheme cs, int total) {
    return GridView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: total,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final answered = isAnsweredAt(index);
        final correct = isCorrectAt(index);
        final selected = selectedIndex == index;

        Color tileColor;
        if (!answered) {
          tileColor = cs.outlineVariant.withOpacity(0.55);
        } else if (correct) {
          tileColor = Colors.green;
        } else {
          tileColor = Colors.red;
        }

        return InkWell(
          onTap: () => setState(() => selectedIndex = index),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? cs.primary : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: tileColor.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Center(
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailCard(
    BuildContext context,
    ColorScheme cs,
    OralQuestionModel question,
    String? userAnswer,
    String correctAnswer,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${selectedIndex + 1}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),

            // Optional image (Q1/Q2 only)
            if (question.imageUrl != null) ...[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      color: cs.surfaceContainerHighest.withOpacity(0.25),
                      padding: const EdgeInsets.all(10),
                      child: InteractiveViewer(
                        child: Image.asset(
                          question.imageUrl!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            ...question.options.map((option) {
              final isUser = userAnswer == option.id;
              final isCorrect = correctAnswer == option.id;

              Color border = cs.outlineVariant.withOpacity(0.35);
              Color bg = cs.surfaceContainerHighest.withOpacity(0.25);

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
                  borderRadius: BorderRadius.circular(20),
                  color: bg,
                  border: Border.all(color: border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Text(
                      "${option.id}. ",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Expanded(child: Text(option.text)),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.surfaceContainerHighest.withOpacity(0.22),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
              ),
              child: Text(
                question.explanation.isEmpty
                    ? "Explanation: Wrong or flagged items are automatically added to your review queue."
                    : "Explanation: ${question.explanation}",
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}