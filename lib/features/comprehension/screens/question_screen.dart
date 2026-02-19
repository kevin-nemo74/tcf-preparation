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

  final Map<String, String> userAnswers = {};
  final Set<String> flaggedQuestions = {};

  late int remainingSeconds;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.test.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 0) {
        t.cancel();
        _submitExam();
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _submitExam() {
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

  Future<void> _openGrid() async {
    final selectedIndex = await Navigator.push<int>(
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
      setState(() => currentIndex = selectedIndex);
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _toggleFlag(String questionId) {
    setState(() {
      if (flaggedQuestions.contains(questionId)) {
        flaggedQuestions.remove(questionId);
      } else {
        flaggedQuestions.add(questionId);
      }
    });
  }

  void _goNextOrSubmit() {
    final lastIndex = widget.test.questions.length - 1;
    if (currentIndex == lastIndex) {
      _submitExam();
    } else {
      setState(() => currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 980;

    final QuestionModel question = widget.test.questions[currentIndex];
    final selectedAnswer = userAnswers[question.id];
    final isFlagged = flaggedQuestions.contains(question.id);

    final bool isLastQuestion =
        currentIndex == widget.test.questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test.title),
        actions: [
          IconButton(
            tooltip: "Question Grid",
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: _openGrid,
          ),
          IconButton(
            tooltip: isFlagged ? "Unflag" : "Flag",
            icon: Icon(
              isFlagged ? Icons.flag_rounded : Icons.outlined_flag_rounded,
              color: isFlagged ? Colors.orange : null,
            ),
            onPressed: () => _toggleFlag(question.id),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: cs.surfaceContainerHighest.withOpacity(0.55),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  _formatTime(remainingSeconds),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / widget.test.questions.length,
              backgroundColor: cs.surfaceContainerHighest.withOpacity(0.45),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isWide
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _QuestionImagePanel(
                        imagePath: question.imagePath,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: _OptionsPanel(
                        question: question,
                        selectedAnswer: selectedAnswer,
                        onSelect: (optId) => setState(() {
                          userAnswers[question.id] = optId;
                        }),
                        footer: _BottomControls(
                          isLastQuestion: isLastQuestion,
                          onPrev: currentIndex > 0
                              ? () => setState(() => currentIndex--)
                              : null,
                          onNextOrSubmit: _goNextOrSubmit,
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _QuestionImagePanel(
                        imagePath: question.imagePath,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      flex: 7,
                      child: _OptionsPanel(
                        question: question,
                        selectedAnswer: selectedAnswer,
                        onSelect: (optId) => setState(() {
                          userAnswers[question.id] = optId;
                        }),
                        footer: _BottomControls(
                          isLastQuestion: isLastQuestion,
                          onPrev: currentIndex > 0
                              ? () => setState(() => currentIndex--)
                              : null,
                          onNextOrSubmit: _goNextOrSubmit,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionImagePanel extends StatelessWidget {
  final String imagePath;

  const _QuestionImagePanel({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: cs.surfaceContainerHighest.withOpacity(0.25),
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionsPanel extends StatelessWidget {
  final QuestionModel question;
  final String? selectedAnswer;
  final ValueChanged<String> onSelect;
  final Widget footer;

  const _OptionsPanel({
    required this.question,
    required this.selectedAnswer,
    required this.onSelect,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // ✅ Only show after user selects (saves space)
          if (selectedAnswer != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: cs.primaryContainer.withOpacity(isDark ? 0.45 : 0.65),
                border: Border.all(color: cs.primary.withOpacity(0.55)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    "Selected: $selectedAnswer",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView(
              children: question.options.map((option) {
                final isSelected = selectedAnswer == option.id;

                final bg = isSelected
                    ? cs.primaryContainer.withOpacity(isDark ? 0.60 : 0.85)
                    : cs.surfaceContainerHighest.withOpacity(isDark ? 0.20 : 0.40);

                final border = isSelected
                    ? cs.primary
                    : cs.outlineVariant.withOpacity(0.35);

                final textColor =
                isSelected ? cs.onPrimaryContainer : cs.onSurface;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    onTap: () => onSelect(option.id),
                    borderRadius: BorderRadius.circular(22),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: bg,
                        border: Border.all(
                          color: border,
                          width: isSelected ? 2.4 : 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: cs.primary.withOpacity(isDark ? 0.35 : 0.20),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ]
                            : [],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? cs.primary.withOpacity(isDark ? 0.25 : 0.15)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? cs.primary.withOpacity(0.75)
                                    : cs.outlineVariant.withOpacity(0.35),
                              ),
                            ),
                            child: Text(
                              option.id,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option.text,
                              style: TextStyle(
                                height: 1.25,
                                color: textColor,
                                fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            child: isSelected
                                ? Icon(Icons.check_circle_rounded,
                                key: const ValueKey("selected"),
                                color: Theme.of(context).colorScheme.primary,
                                size: 22)
                                : const SizedBox(
                              key: ValueKey("empty"),
                              width: 22,
                              height: 22,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          footer,
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final bool isLastQuestion;
  final VoidCallback? onPrev;
  final VoidCallback onNextOrSubmit;

  const _BottomControls({
    required this.isLastQuestion,
    required this.onPrev,
    required this.onNextOrSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPrev,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text("Previous"),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: onNextOrSubmit,
            icon: Icon(isLastQuestion ? Icons.check_circle_rounded : Icons.arrow_forward_rounded),
            label: Text(isLastQuestion ? "Submit" : "Next"),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
