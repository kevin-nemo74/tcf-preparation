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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Question Navigation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: totalQuestions,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final questionId = "Q${index + 1}";

            final isAnswered = userAnswers.containsKey(questionId);
            final isFlagged = flaggedQuestions.contains(questionId);
            final isCurrent = index == currentIndex;

            Color tileColor;
            if (isFlagged) {
              tileColor = Colors.orange;
            } else if (isAnswered) {
              tileColor = cs.primary;
            } else {
              tileColor = cs.surfaceContainerHighest.withOpacity(0.55);
            }

            // ✅ Ensure number contrast always readable
            final bool darkTile = isFlagged || isAnswered;
            final Color textColor = darkTile ? Colors.white : cs.onSurface;

            return InkWell(
              onTap: () => Navigator.pop(context, index),
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isCurrent ? cs.tertiary : Colors.transparent,
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
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ),

                    // Flag icon
                    if (isFlagged)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(Icons.flag_rounded,
                            size: 18, color: Colors.white),
                      ),

                    // Answered indicator (small badge)
                    if (isAnswered)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(0.25),
                          ),
                          child: Text(
                            userAnswers[questionId] ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
