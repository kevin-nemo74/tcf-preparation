import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/core/widgets/responsive_frame.dart';
import 'package:tcf_canada_preparation/features/comprehension/screens/question_grid_screen.dart';

import '../data/models/oral_test_model.dart';
import '../data/models/oral_question_model.dart';
import '../widgets/audio_player_widget.dart';
import 'oral_result_screen.dart';

// Reuse your existing grid screen (CE) because it already supports flags/answers

class OralQuestionScreen extends StatefulWidget {
  final OralTestModel test;

  const OralQuestionScreen({super.key, required this.test});

  @override
  State<OralQuestionScreen> createState() => _OralQuestionScreenState();
}

class _OralQuestionScreenState extends State<OralQuestionScreen> {
  int currentIndex = 0;

  final Map<String, String> userAnswers = {};
  final Set<String> flaggedQuestions = {};

  late int remainingSeconds;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.test.durationMinutes * 60;

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

  void _submitExam() {
    timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OralResultScreen(
          test: widget.test,
          userAnswers: userAnswers,
          flaggedQuestionIds: flaggedQuestions,
        ),
      ),
    );
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
    final isWide = kIsWeb
        ? Responsive.isTabletWeb(context)
        : Responsive.isSplitLayout(context);

    final OralQuestionModel question = widget.test.questions[currentIndex];
    final selectedAnswer = userAnswers[question.id];
    final isFlagged = flaggedQuestions.contains(question.id);
    final isLast = currentIndex == widget.test.questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test.title),
        actions: [
          IconButton(
            tooltip: "Grille des questions",
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: _openGrid,
          ),
          IconButton(
            tooltip: isFlagged ? "Retirer le drapeau" : "Signaler",
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
      body: ResponsiveFrame(
        child: SafeArea(
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  end: (currentIndex + 1) / widget.test.questions.length,
                ),
                duration: contextReducedMotion(context)
                    ? Duration.zero
                    : AppMotion.medium,
                curve: AppMotion.curve,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: cs.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(
                    Responsive.isDesktopWeb(context) ? 20 : 16,
                  ),
                  child: AnimatedSwitcher(
                    duration: contextReducedMotion(context)
                        ? Duration.zero
                        : AppMotion.medium,
                    switchInCurve: AppMotion.curve,
                    switchOutCurve: AppMotion.curve,
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                    transitionBuilder: (child, animation) {
                      final offset =
                          Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: AppMotion.curve,
                            ),
                          );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: isWide
                        ? Row(
                            key: ValueKey<String>(question.id),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: Responsive.isDesktopWeb(context) ? 7 : 6,
                                child: _OralMediaPanel(question: question),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: Responsive.isDesktopWeb(context) ? 6 : 5,
                                child: _OptionsPanel(
                                  question: question,
                                  selectedAnswer: selectedAnswer,
                                  onSelect: (id) => setState(() {
                                    userAnswers[question.id] = id;
                                  }),
                                  footer: _BottomControls(
                                    isLastQuestion: isLast,
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
                            key: ValueKey<String>(question.id),
                            children: [
                              Expanded(
                                flex: 6,
                                child: _OralMediaPanel(question: question),
                              ),
                              const SizedBox(height: 14),
                              Expanded(
                                flex: 7,
                                child: _OptionsPanel(
                                  question: question,
                                  selectedAnswer: selectedAnswer,
                                  onSelect: (id) => setState(() {
                                    userAnswers[question.id] = id;
                                  }),
                                  footer: _BottomControls(
                                    isLastQuestion: isLast,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OralMediaPanel extends StatelessWidget {
  final OralQuestionModel question;

  const _OralMediaPanel({required this.question});

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
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ URL audio
          AudioPlayerWidget(audioUrl: question.audioUrl),

          const SizedBox(height: 12),

          // ✅ Optional URL image
          if (question.imageUrl != null)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  color: cs.surfaceContainerHighest.withOpacity(0.25),
                  padding: const EdgeInsets.all(10),
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Image.network(
                      question.imageUrl!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes == null
                                ? null
                                : progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Text("Echec du chargement de l'image")),
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: cs.surfaceContainerHighest.withOpacity(0.20),
                  border: Border.all(
                    color: cs.outlineVariant.withOpacity(0.25),
                  ),
                ),
                child: Text(
                  "Question audio",
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionsPanel extends StatelessWidget {
  final OralQuestionModel question;
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
          ),
        ],
      ),
      child: Column(
        children: [
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
                    "Selection: $selectedAnswer",
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
                    : cs.surfaceContainerHighest.withOpacity(
                        isDark ? 0.20 : 0.40,
                      );

                final border = isSelected
                    ? cs.primary
                    : cs.outlineVariant.withOpacity(0.35);

                final textColor = isSelected
                    ? cs.onPrimaryContainer
                    : cs.onSurface;

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
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${option.id}. ",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              option.text,
                              style: TextStyle(height: 1.25, color: textColor),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: cs.primary,
                              size: 22,
                            ),
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
            label: const Text("Precedent"),
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
            icon: Icon(
              isLastQuestion
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: Text(isLastQuestion ? "Soumettre" : "Suivant"),
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
