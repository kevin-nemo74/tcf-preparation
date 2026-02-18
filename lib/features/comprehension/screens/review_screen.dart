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

  int calculateCorrect() {
    int correct = 0;
    for (var q in widget.test.questions) {
      if (widget.userAnswers[q.id] == q.correctAnswer) {
        correct++;
      }
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.test.questions.length;
    final correct = calculateCorrect();
    final wrong = total - correct;

    final question =
    widget.test.questions[selectedIndex];

    final userAnswer =
    widget.userAnswers[question.id];
    final correctAnswer =
        question.correctAnswer;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Answers"),
      ),
      body: Column(
        children: [
          /// ===== SUMMARY CARD =====
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.blue.shade100,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Performance Overview",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat("Correct", "$correct",
                          Colors.green),
                      _buildStat(
                          "Wrong", "$wrong", Colors.red),
                      _buildStat(
                          "Total", "$total", Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// ===== GRID =====
          SizedBox(
            height: 110,
            child: GridView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: total,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final q =
                widget.test.questions[index];
                final ua =
                widget.userAnswers[q.id];

                bool isCorrect =
                    ua == q.correctAnswer;
                bool notAnswered = ua == null;
                bool isSelected =
                    index == selectedIndex;

                Color color;

                if (notAnswered) {
                  color = Colors.grey.shade400;
                } else if (isCorrect) {
                  color = Colors.green;
                } else {
                  color = Colors.red;
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration:
                    const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius:
                      BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset:
                          const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          /// ===== SELECTED QUESTION ONLY =====
          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(30),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.06),
                      blurRadius: 25,
                      offset:
                      const Offset(0, 12),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${selectedIndex + 1}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      /// IMAGE
                      Center(
                        child: ConstrainedBox(
                          constraints:
                          const BoxConstraints(
                            maxHeight: 450,
                          ),
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(
                                18),
                            child: InteractiveViewer(
                              child: Image.asset(
                                question.imagePath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// OPTIONS
                      ...question.options.map(
                            (option) {
                          bool isUserAnswer =
                              userAnswer ==
                                  option.id;
                          bool isCorrectAnswer =
                              correctAnswer ==
                                  option.id;

                          Color borderColor =
                              Colors.grey.shade300;
                          Color bgColor =
                              Colors.grey.shade50;

                          if (isCorrectAnswer) {
                            borderColor =
                                Colors.green;
                            bgColor =
                                Colors.green
                                    .withOpacity(
                                    0.08);
                          }

                          if (isUserAnswer &&
                              !isCorrectAnswer) {
                            borderColor =
                                Colors.red;
                            bgColor =
                                Colors.red
                                    .withOpacity(
                                    0.08);
                          }

                          return Container(
                            margin:
                            const EdgeInsets
                                .symmetric(
                                vertical:
                                6),
                            padding:
                            const EdgeInsets
                                .all(16),
                            decoration:
                            BoxDecoration(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                  18),
                              color: bgColor,
                              border: Border.all(
                                  color:
                                  borderColor,
                                  width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "${option.id}. ",
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .bold),
                                ),
                                Expanded(
                                    child: Text(
                                        option
                                            .text)),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
      String title, String value, Color color) {
    return Column(
      children: [
        Text(title),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
