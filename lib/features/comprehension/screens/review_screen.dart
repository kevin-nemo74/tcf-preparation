import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/theme/design_tokens.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/core/widgets/responsive_frame.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/question_model.dart';
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
  bool showPointsValue = false;
  bool showMissedOnly = false;

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

    final isWeb = kIsWeb;
    final total = widget.test.questions.length;
    final correct = calculateCorrectCount();
    final wrong = total - correct;
    final completionPct = total == 0 ? 0 : (correct / total * 100).round();

    final q = widget.test.questions[selectedIndex];
    final userAnswer = widget.userAnswers[q.id];
    final correctAnswer = q.correctAnswer;

    final isWide = Responsive.isWideReview(context);

    const double narrowGridHeight = 110.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Revoir les reponses"),
        actions: [
          Row(
            children: [
              const Text("Erreurs seulement"),
              Switch.adaptive(
                value: showMissedOnly,
                onChanged: (v) => setState(() => showMissedOnly = v),
              ),
            ],
          ),
          Row(
            children: [
              const Text("Points"),
              Switch.adaptive(
                value: showPointsValue,
                onChanged: (v) => setState(() => showPointsValue = v),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
      body: ResponsiveFrame(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: Responsive.reviewPaneWidth(context),
                    child: Column(
                      children: [
                        _summaryCard(cs, correct, wrong, total, completionPct),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _grid(
                            cs,
                            total,
                            crossAxisCount: isWeb ? 4 : 2,
                            childAspectRatio: isWeb ? 1.15 : 1.25,
                            scrollDirection: isWeb
                                ? Axis.vertical
                                : Axis.horizontal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _animatedDetail(
                      context,
                      cs,
                      q,
                      userAnswer,
                      correctAnswer,
                      selectedIndex,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _summaryCard(cs, correct, wrong, total, completionPct),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: narrowGridHeight,
                    child: _grid(
                      cs,
                      total,
                      crossAxisCount: 2,
                      childAspectRatio: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: _animatedDetail(
                      context,
                      cs,
                      q,
                      userAnswer,
                      correctAnswer,
                      selectedIndex,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _summaryCard(
    ColorScheme cs,
    int correct,
    int wrong,
    int total,
    int completionPct,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: DesignTokens.cardDecoration(cs),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat("Correctes", "$correct", Colors.green),
              _stat("Incorrectes", "$wrong", Colors.red),
              _stat("Total", "$total", cs.primary),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completionPct / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 6),
          Text(
            '$completionPct% correctes',
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
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
    QuestionModel question,
    String? userAnswer,
    String correctAnswer,
    int index,
  ) {
    return AnimatedSwitcher(
      duration: contextReducedMotion(context)
          ? Duration.zero
          : AppMotion.medium,
      switchInCurve: AppMotion.curve,
      switchOutCurve: AppMotion.curve,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: AppMotion.curve),
                ),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(index),
        child: _detailCard(cs, question, userAnswer, correctAnswer, index),
      ),
    );
  }

  Widget _grid(
    ColorScheme cs,
    int total, {
    required int crossAxisCount,
    required double childAspectRatio,
    Axis scrollDirection = Axis.horizontal,
    ValueChanged<int>? onIndexSelected,
  }) {
    final filteredIndexes = List<int>.generate(
      total,
      (i) => i,
    ).where((i) => !showMissedOnly || !isCorrectAt(i)).toList();
    if (filteredIndexes.isEmpty) {
      return Center(
        child: Text(
          'Aucune question manquee a revoir.',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return GridView.builder(
      scrollDirection: scrollDirection,
      itemCount: filteredIndexes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final sourceIndex = filteredIndexes[index];
        final answered = isAnsweredAt(sourceIndex);
        final correct = isCorrectAt(sourceIndex);
        final selected = selectedIndex == sourceIndex;

        Color tileColor;
        if (!answered) {
          tileColor = cs.outlineVariant.withValues(alpha: 0.55);
        } else if (correct) {
          tileColor = Colors.green;
        } else {
          tileColor = Colors.red;
        }

        return InkWell(
          onTap: () {
            setState(() => selectedIndex = sourceIndex);
            onIndexSelected?.call(sourceIndex);
          },
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
                  color: tileColor.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${sourceIndex + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (showPointsValue)
                    Text(
                      "${getQuestionPoints(sourceIndex + 1)} pts",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailCard(
    ColorScheme cs,
    QuestionModel question,
    String? userAnswer,
    String correctAnswer,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.25
                  : 0.06,
            ),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${index + 1}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),

            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: kIsWeb ? 640 : 480),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
                    padding: const EdgeInsets.all(10),
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Image.network(
                        question.imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes == null
                                  ? null
                                  : progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Text("Echec du chargement de l'image"),
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ...question.options.map((option) {
              final isUser = userAnswer == option.id;
              final isCorrect = correctAnswer == option.id;

              Color border = cs.outlineVariant.withValues(alpha: 0.35);
              Color bg = cs.surfaceContainerHighest.withValues(alpha: 0.25);

              if (isCorrect) {
                border = Colors.green;
                bg = Colors.green.withValues(alpha: 0.10);
              }
              if (isUser && !isCorrect) {
                border = Colors.red;
                bg = Colors.red.withValues(alpha: 0.10);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${option.id}. ",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Expanded(child: Text(option.text)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                question.explanation.isEmpty
                    ? "Explication: cet element est ajoute a la file de revision si la reponse est fausse ou signalee."
                    : "Explication: ${question.explanation}",
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.8),
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
