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
  bool showPointsValue = false; // only show question value

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
    final total = widget.test.questions.length;
    final correct = calculateCorrectCount();
    final wrong = total - correct;

    final question = widget.test.questions[selectedIndex];
    final userAnswer = widget.userAnswers[question.id];
    final correctAnswer = question.correctAnswer;

    final isWide = MediaQuery.of(context).size.width > 950;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Answers"),
        actions: [
          Row(
            children: [
              const Text("Show values"),
              Switch.adaptive(
                value: showPointsValue,
                onChanged: (v) => setState(() => showPointsValue = v),
              ),
              const SizedBox(width: 10),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 350,
              child: Column(
                children: [
                  _buildSummary(correct, wrong, total),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildGrid(total),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildDetail(
                  question,
                  userAnswer,
                  correctAnswer,
                  selectedIndex),
            ),
          ],
        )
            : Column(
          children: [
            _buildSummary(correct, wrong, total),
            const SizedBox(height: 15),
            SizedBox(height: 110, child: _buildGrid(total)),
            const SizedBox(height: 15),
            Expanded(
              child: _buildDetail(
                  question,
                  userAnswer,
                  correctAnswer,
                  selectedIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(int correct, int wrong, int total) {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat("Correct", correct.toString(), Colors.green),
          _stat("Wrong", wrong.toString(), Colors.red),
          _stat("Total", total.toString(), Colors.blue),
        ],
      ),
    );
  }

  Widget _stat(String title, String value, Color color) {
    return Column(
      children: [
        Text(title),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color),
        ),
      ],
    );
  }

  Widget _buildGrid(int total) {
    return GridView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: total,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        bool correct = isCorrectAt(index);
        bool answered = isAnsweredAt(index);
        bool selected = selectedIndex == index;

        Color color;
        if (!answered) {
          color = Colors.grey.shade400;
        } else if (correct) {
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
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? Colors.blue : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${index + 1}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  if (showPointsValue)
                    Text(
                      "${getQuestionPoints(index + 1)} pts",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetail(
      question, userAnswer, correctAnswer, int index) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${index + 1}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: ConstrainedBox(
                constraints:
                const BoxConstraints(maxHeight: 450),
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(20),
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
            ...question.options.map((option) {
              bool isUser =
                  userAnswer == option.id;
              bool isCorrect =
                  correctAnswer == option.id;

              Color border = Colors.grey.shade300;
              Color bg = Colors.grey.shade50;

              if (isCorrect) {
                border = Colors.green;
                bg = Colors.green.withOpacity(0.08);
              }

              if (isUser && !isCorrect) {
                border = Colors.red;
                bg = Colors.red.withOpacity(0.08);
              }

              return Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(20),
                  color: bg,
                  border: Border.all(
                      color: border, width: 1.5),
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
                        child: Text(option.text)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
