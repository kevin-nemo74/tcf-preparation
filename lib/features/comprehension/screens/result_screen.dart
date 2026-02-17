import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';
import 'review_screen.dart';

class ResultScreen extends StatelessWidget {
  final TestModel test;
  final Map<String, String> userAnswers;

  const ResultScreen({
    super.key,
    required this.test,
    required this.userAnswers,
  });

  int calculateScore() {
    int totalScore = 0;

    for (int i = 0; i < test.questions.length; i++) {
      final question = test.questions[i];

      if (userAnswers[question.id] == question.correctAnswer) {
        totalScore += getQuestionPoints(i + 1);
      }
    }

    return totalScore;
  }

  int getQuestionPoints(int questionNumber) {
    if (questionNumber >= 1 && questionNumber <= 4) return 3;
    if (questionNumber >= 5 && questionNumber <= 10) return 9;
    if (questionNumber >= 11 && questionNumber <= 19) return 15;
    if (questionNumber >= 20 && questionNumber <= 29) return 21;
    if (questionNumber >= 30 && questionNumber <= 35) return 26;
    if (questionNumber >= 36 && questionNumber <= 39) return 33;
    return 0;
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
    int score = calculateScore();
    String level = getNCLCLevel(score);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Result"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Your Score",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text(
                "$score / 699",
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                level,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(
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
    );
  }
}
