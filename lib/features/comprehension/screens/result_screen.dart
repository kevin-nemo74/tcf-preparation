import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/telemetry/app_analytics.dart';
import 'package:tcf_canada_preparation/core/theme/motion.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/l10n/app_localizations.dart';
import 'review_screen.dart';

class ResultScreen extends StatefulWidget {
  final TestModel test;
  final Map<String, String> userAnswers;
  final Set<String> flaggedQuestionIds;

  const ResultScreen({
    super.key,
    required this.test,
    required this.userAnswers,
    required this.flaggedQuestionIds,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saved = false;

  int calculateScore() {
    int totalScore = 0;

    for (int i = 0; i < widget.test.questions.length; i++) {
      final question = widget.test.questions[i];

      if (widget.userAnswers[question.id] == question.correctAnswer) {
        totalScore += getQuestionPoints(i + 1);
      }
    }

    return totalScore;
  }

  @override
  void initState() {
    super.initState();
    _persistProgress();
  }

  Future<void> _persistProgress() async {
    if (_saved) return;
    _saved = true;
    final uid = ProgressRepository.currentUid;
    if (uid == null) return;

    final correctMap = <String, String>{
      for (final q in widget.test.questions) q.id: q.correctAnswer,
    };
    var correctCount = 0;
    for (final q in widget.test.questions) {
      if (widget.userAnswers[q.id] == q.correctAnswer) correctCount++;
    }

    await ProgressRepository.recordAttempt(
      uid: uid,
      testId: widget.test.id,
      testTitle: widget.test.title,
      moduleType: 'CE',
      score: calculateScore(),
      totalQuestions: widget.test.questions.length,
      correctAnswers: correctCount,
      flaggedQuestionIds: widget.flaggedQuestionIds,
      userAnswers: widget.userAnswers,
      correctAnswersByQuestion: correctMap,
    );
    await AppAnalytics.logTestSubmitted(
      moduleType: 'CE',
      testId: widget.test.id,
      score: calculateScore(),
    );
  }

  int getQuestionPoints(int questionNumber) {
    if (questionNumber >= 1 && questionNumber <= 4) return 3;
    if (questionNumber >= 5 && questionNumber <= 10) return 9;
    if (questionNumber >= 11 && questionNumber <= 19) return 15;
    if (questionNumber >= 20 && questionNumber <= 29) return 21;
    if (questionNumber >= 30 && questionNumber <= 35) return 26;
    if (questionNumber >= 36 && questionNumber <= 39) return 33;
    return 0;
  }

  String getNCLCLevel(int score) {
    if (score >= 342 && score <= 374) return "NCLC 4";
    if (score >= 375 && score <= 405) return "NCLC 5";
    if (score >= 406 && score <= 452) return "NCLC 6";
    if (score >= 453 && score <= 498) return "NCLC 7";
    if (score >= 499 && score <= 523) return "NCLC 8";
    if (score >= 524 && score <= 548) return "NCLC 9";
    if (score >= 549 && score <= 699) return "NCLC 10";
    return "Below NCLC 4";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final score = calculateScore();
    final level = getNCLCLevel(score);
    final cs = Theme.of(context).colorScheme;
    final reduced = contextReducedMotion(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ceResultTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.formMaxWidth(context)),
            child: AnimatedFadeSlide(
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: cs.surface,
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_rounded, size: 48, color: cs.primary),
                  const SizedBox(height: 12),
                  Text(
                    l10n.ceResultYourScore,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: score),
                    duration: reduced ? Duration.zero : AppMotion.slow,
                    curve: AppMotion.curve,
                    builder: (context, value, _) => Text(
                      "$value / 699",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedDefaultTextStyle(
                    duration: reduced ? Duration.zero : AppMotion.medium,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.primary,
                        ),
                    child: Text(level),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        AppRoutes.fadeSlide(
                          ReviewScreen(
                            test: widget.test,
                            userAnswers: widget.userAnswers,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review_rounded),
                    label: Text(l10n.ceReviewCta),
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}
