import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';

class ReviewScreen extends StatelessWidget {
  final TestModel test;
  final Map<String, String> userAnswers;

  const ReviewScreen({
    super.key,
    required this.test,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Answers"),
      ),
      body: ListView.builder(
        itemCount: test.questions.length,
        itemBuilder: (context, index) {
          final question = test.questions[index];
          final userAnswer = userAnswers[question.id];
          final correctAnswer = question.correctAnswer;

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${index + 1}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  /// IMAGE
                  InteractiveViewer(
                    child: Image.asset(
                      question.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// OPTIONS
                  ...question.options.map((option) {
                    bool isUserAnswer =
                        userAnswer == option.id;
                    bool isCorrectAnswer =
                        correctAnswer == option.id;

                    Color borderColor = Colors.grey;

                    if (isCorrectAnswer) {
                      borderColor = Colors.green;
                    } else if (isUserAnswer &&
                        !isCorrectAnswer) {
                      borderColor = Colors.red;
                    }

                    return Container(
                      margin:
                      const EdgeInsets.symmetric(
                          vertical: 4),
                      padding:
                      const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: borderColor),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${option.id}. ",
                            style: const TextStyle(
                                fontWeight:
                                FontWeight.bold),
                          ),
                          Expanded(
                              child:
                              Text(option.text)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
