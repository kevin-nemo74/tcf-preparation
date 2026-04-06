import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';

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
      appBar: AppBar(title: const Text("Question Navigation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktopWeb = Responsive.isDesktopWeb(context);
            final bool isTabletWeb = Responsive.isTabletWeb(context);
            final columns =
                Responsive.gridColumns(context, mobile: 5) +
                (isDesktopWeb ? 2 : (isTabletWeb ? 1 : 0));
            final spacing = isDesktopWeb ? 8.0 : 7.0;
            return GridView.builder(
              itemCount: totalQuestions,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: constraints.maxWidth > 1100 ? 1.0 : 0.95,
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
                  tileColor = cs.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  );
                }

                // ✅ Ensure number contrast always readable
                final bool darkTile = isFlagged || isAnswered;
                final Color textColor = darkTile ? Colors.white : cs.onSurface;

                return InkWell(
                  onTap: () => Navigator.pop(context, index),
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent ? cs.tertiary : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tileColor.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                        ),

                        // Flag icon
                        if (isFlagged)
                          const Positioned(
                            top: 6,
                            right: 6,
                            child: Icon(
                              Icons.flag_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),

                        // Answered indicator (small badge)
                        if (isAnswered)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black.withValues(alpha: 0.25),
                              ),
                              child: Text(
                                userAnswers[questionId] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
