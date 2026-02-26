import 'package:flutter/material.dart';
import '../data/models/oral_test_model.dart';
import 'oral_review_screen.dart';

class OralResultScreen extends StatelessWidget {
  final OralTestModel test;
  final Map<String, String> userAnswers;

  const OralResultScreen({
    super.key,
    required this.test,
    required this.userAnswers,
  });

  int getQuestionPoints(int questionNumber) {
    if (questionNumber >= 1 && questionNumber <= 4) return 3;
    if (questionNumber >= 5 && questionNumber <= 10) return 9;
    if (questionNumber >= 11 && questionNumber <= 19) return 15;
    if (questionNumber >= 20 && questionNumber <= 29) return 21;
    if (questionNumber >= 30 && questionNumber <= 35) return 26;
    if (questionNumber >= 36 && questionNumber <= 39) return 33;
    return 0;
  }

  int calculateScore() {
    int total = 0;
    for (int i = 0; i < test.questions.length; i++) {
      final q = test.questions[i];
      if (userAnswers[q.id] == q.correctAnswer) {
        total += getQuestionPoints(i + 1);
      }
    }
    return total;
  }

  String getNCLCLevel(int score) {
    if (score >= 342 && score <= 374) return "NCLC 4";
    if (score >= 375 && score <= 405) return "NCLC 5";
    if (score >= 406 && score <= 452) return "NCLC 6";
    if (score >= 453 && score <= 498) return "NCLC 7";
    if (score >= 499 && score <= 523) return "NCLC 8";
    if (score >= 524 && score <= 548) return "NCLC 9";
    if (score >= 549 && score <= 699) return "NCLC 10";
    return "Below NCLC 4";
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final score = calculateScore();
    final level = getNCLCLevel(score);

    return Scaffold(
      appBar: AppBar(title: const Text("Exam Result")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: cs.surface,
              border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.06,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Your Score",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 10),
                Text(
                  "$score / 699",
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                Text(
                  level,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OralReviewScreen(
                          test: test,
                          userAnswers: userAnswers,
                        ),
                      ),
                    );
                  },
                  child: const Text("Review Answers"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}