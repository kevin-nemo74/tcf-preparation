

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/question_model.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';

class QuestionScreen extends StatefulWidget {
  final TestModel test;

  const QuestionScreen({super.key, required this.test});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int currentIndex = 0;
  String? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    QuestionModel question = widget.test.questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test.title),
      ),
      body: Column(
        children: [
          /// PROGRESS BAR
          LinearProgressIndicator(
            value: (currentIndex + 1) / widget.test.questions.length,
          ),

          const SizedBox(height: 10),

          /// QUESTION + OPTIONS
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// IMAGE
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InteractiveViewer(
                      child: Image.asset(
                        question.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// OPTIONS
                  ...question.options.map((option) {
                    bool isSelected = selectedAnswer == option.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAnswer = option.id;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.white,
                            border: Border.all(
                              color:
                              isSelected ? Colors.blue : Colors.grey,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${option.id}. ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(option.text),
                              ),
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

          /// NAVIGATION BUTTONS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentIndex > 0
                      ? () {
                    setState(() {
                      currentIndex--;
                      selectedAnswer = null;
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
                      selectedAnswer = null;
                    });
                  }
                      : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
