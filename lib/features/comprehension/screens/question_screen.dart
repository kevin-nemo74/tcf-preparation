import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/question_model.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';

import 'result_screen.dart';
import 'question_grid_screen.dart';

class QuestionScreen extends StatefulWidget {
  final TestModel test;

  const QuestionScreen({super.key, required this.test});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int currentIndex = 0;

  Map<String, String> userAnswers = {};
  Set<String> flaggedQuestions = {};

  late int remainingSeconds;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.test.durationMinutes * 60;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 0) {
        t.cancel();
        submitExam();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  void submitExam() {
    timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          test: widget.test,
          userAnswers: userAnswers,
        ),
      ),
    );
  }

  void openGrid() async {
    final selectedIndex = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionGridScreen(
          totalQuestions: widget.test.questions.length,
          currentIndex: currentIndex,
          userAnswers: userAnswers,
          flaggedQuestions: flaggedQuestions,
        ),
      ),
    );

    if (selectedIndex != null) {
      setState(() {
        currentIndex = selectedIndex;
      });
    }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    QuestionModel question = widget.test.questions[currentIndex];
    String? selectedAnswer = userAnswers[question.id];
    bool isFlagged = flaggedQuestions.contains(question.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test.title),
        actions: [
          IconButton(
            icon: Icon(
              isFlagged ? Icons.flag : Icons.outlined_flag,
              color: isFlagged ? Colors.orange : null,
            ),
            onPressed: () {
              setState(() {
                if (isFlagged) {
                  flaggedQuestions.remove(question.id);
                } else {
                  flaggedQuestions.add(question.id);
                }
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                formatTime(remainingSeconds),
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value:
            (currentIndex + 1) / widget.test.questions.length,
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InteractiveViewer(
                      child: Image.asset(
                        question.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...question.options.map((option) {
                    bool isSelected =
                        selectedAnswer == option.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            userAnswers[question.id] =
                                option.id;
                          });
                        },
                        child: Container(
                          padding:
                          const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.white,
                            border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey),
                            borderRadius:
                            BorderRadius.circular(10),
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
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: currentIndex > 0
                          ? () {
                        setState(() {
                          currentIndex--;
                        });
                      }
                          : null,
                      child: const Text("Previous"),
                    ),
                    ElevatedButton(
                      onPressed: currentIndex <
                          widget.test.questions.length - 1
                          ? () {
                        setState(() {
                          currentIndex++;
                        });
                      }
                          : null,
                      child: const Text("Next"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: openGrid,
                      child: const Text("Question Grid"),
                    ),
                    ElevatedButton(
                      onPressed: submitExam,
                      child: const Text("Submit Exam"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
