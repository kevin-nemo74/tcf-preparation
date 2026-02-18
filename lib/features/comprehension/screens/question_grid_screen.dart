import 'package:flutter/material.dart';

class QuestionGridScreen extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final Map<String, String> userAnswers;
  final Set<String> flaggedQuestions;

  const QuestionGridScreen({
    super.key,
    required this.totalQuestions,
    required this.currentIndex,
    required this.userAnswers,
    required this.flaggedQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Question Navigation"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: totalQuestions,
        itemBuilder: (context, index) {
          String questionId = "Q${index + 1}";

          bool isAnswered =
          userAnswers.containsKey(questionId);
          bool isFlagged =
          flaggedQuestions.contains(questionId);
          bool isCurrent = index == currentIndex;

          Color bgColor = Colors.grey.shade300;

          if (isAnswered) bgColor = Colors.blue;
          if (isFlagged) bgColor = Colors.orange;

          return GestureDetector(
            onTap: () {
              Navigator.pop(context, index);
            },
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(
                  color: isCurrent
                      ? Colors.green
                      : Colors.transparent,
                  width: 3,
                ),
                borderRadius:
                BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
