import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/telemetry/app_analytics.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/local_tests_data.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/question_model.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';
import 'package:tcf_canada_preparation/features/comprehension/screens/review_screen.dart';
import 'package:tcf_canada_preparation/features/oral/data/local_oral_tests_data.dart';
import 'package:tcf_canada_preparation/features/oral/data/models/oral_question_model.dart';
import 'package:tcf_canada_preparation/features/oral/data/models/oral_test_model.dart';
import 'package:tcf_canada_preparation/features/oral/screens/oral_review_screen.dart';

import 'progress_repository.dart';

typedef ReviewQueueStreamFactory = Stream<List<ReviewQueueItem>> Function(
  String uid, {
  int limit,
});
typedef ReviewQueueMutation = Future<void> Function(String uid, String itemId);

class ReviewQueueScreen extends StatelessWidget {
  final String uid;
  final ReviewQueueStreamFactory queueStream;
  final Future<List<TestModel>> Function() loadComprehensionTests;
  final Future<List<OralTestModel>> Function() loadOralTests;
  final ReviewQueueMutation markItemDone;
  final ReviewQueueMutation restoreItem;

  const ReviewQueueScreen({
    super.key,
    required this.uid,
    this.queueStream = ProgressRepository.streamReviewQueue,
    this.loadComprehensionTests = LocalTestsData.loadTests,
    this.loadOralTests = LocalOralTestsData.loadTests,
    this.markItemDone = ProgressRepository.markReviewQueueItemDone,
    this.restoreItem = ProgressRepository.restoreReviewQueueItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Queue')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.canvasMaxWidth(context),
          ),
          child: StreamBuilder<List<ReviewQueueItem>>(
            stream: queueStream(uid, limit: 40),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return ListView.separated(
                  padding: Responsive.pagePadding(context, vertical: 16),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, __) => const ShimmerSkeleton(height: 96),
                );
              }

              final items = snapshot.data ?? const <ReviewQueueItem>[];
              if (items.isEmpty) {
                return const _EmptyQueue();
              }

              return ListView(
                padding: Responsive.pagePadding(context, vertical: 16),
                children: [
                  _QueueHeader(count: items.length),
                  const SizedBox(height: 12),
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _QueueCard(
                        uid: uid,
                        item: item,
                        loadComprehensionTests: loadComprehensionTests,
                        loadOralTests: loadOralTests,
                        markItemDone: markItemDone,
                        restoreItem: restoreItem,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QueueHeader extends StatelessWidget {
  final int count;

  const _QueueHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.assignment_late_rounded, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count question(s) need another pass.',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: cs.surface,
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 42, color: cs.primary),
              const SizedBox(height: 12),
              const Text(
                'Your review queue is empty.',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Wrong or flagged answers will appear here after each attempt.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueCard extends StatefulWidget {
  final String uid;
  final ReviewQueueItem item;
  final Future<List<TestModel>> Function() loadComprehensionTests;
  final Future<List<OralTestModel>> Function() loadOralTests;
  final ReviewQueueMutation markItemDone;
  final ReviewQueueMutation restoreItem;

  const _QueueCard({
    required this.uid,
    required this.item,
    required this.loadComprehensionTests,
    required this.loadOralTests,
    required this.markItemDone,
    required this.restoreItem,
  });

  @override
  State<_QueueCard> createState() => _QueueCardState();
}

class _QueueCardState extends State<_QueueCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final item = widget.item;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: cs.primaryContainer.withOpacity(0.7),
                ),
                child: Text(
                  item.moduleType == 'CO' ? 'Oral' : 'Comprehension',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.testTitle.isEmpty ? item.testId : item.testTitle,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Question ${item.questionId}',
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.75),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.lastUserAnswer == null || item.lastUserAnswer!.isEmpty
                ? 'You flagged this item for review.'
                : 'Your last answer: ${item.lastUserAnswer} | Correct: ${item.correctAnswer}',
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _openReview,
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('Open review'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _busy ? null : _markDone,
                icon: const Icon(Icons.done_rounded),
                label: const Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _markDone() async {
    setState(() => _busy = true);
    await widget.markItemDone(widget.uid, widget.item.id);
    await AppAnalytics.logReviewQueueCompleted();
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  Future<void> _openReview() async {
    setState(() => _busy = true);
    final item = widget.item;

    try {
      if (item.moduleType == 'CO') {
        final tests = await widget.loadOralTests();
        final test = tests.cast<OralTestModel?>().firstWhere(
              (candidate) => candidate?.id == item.testId,
              orElse: () => null,
            );
        if (!mounted) return;
        if (test == null) {
          await _handleMissing();
          return;
        }

        final question = test.questions.cast<OralQuestionModel?>().firstWhere(
              (candidate) => candidate?.id == item.questionId,
              orElse: () => null,
            );
        if (question == null) {
          await _handleMissing();
          return;
        }

        await Navigator.push(
          context,
          AppRoutes.fadeSlide(
            OralReviewScreen(
              test: OralTestModel(
                id: test.id,
                title: '${test.title} - Review',
                type: test.type,
                durationMinutes: test.durationMinutes,
                questions: [question],
              ),
              userAnswers: {question.id: item.lastUserAnswer ?? ''},
            ),
          ),
        );
      } else {
        final tests = await widget.loadComprehensionTests();
        final test = tests.cast<TestModel?>().firstWhere(
              (candidate) => candidate?.id == item.testId,
              orElse: () => null,
            );
        if (!mounted) return;
        if (test == null) {
          await _handleMissing();
          return;
        }

        final question = test.questions.cast<QuestionModel?>().firstWhere(
              (candidate) => candidate?.id == item.questionId,
              orElse: () => null,
            );
        if (question == null) {
          await _handleMissing();
          return;
        }

        await Navigator.push(
          context,
          AppRoutes.fadeSlide(
            ReviewScreen(
              test: TestModel(
                id: test.id,
                title: '${test.title} - Review',
                type: test.type,
                durationMinutes: test.durationMinutes,
                questions: [question],
              ),
              userAnswers: {question.id: item.lastUserAnswer ?? ''},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _handleMissing() async {
    if (!mounted) return;
    final action = await _showMissingAction(context);
    if (action == _MissingAction.remove) {
      await widget.markItemDone(widget.uid, widget.item.id);
      await AppAnalytics.logReviewQueueCompleted();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review item removed from queue.')),
      );
      return;
    }
    if (action == _MissingAction.requeue) {
      await widget.restoreItem(widget.uid, widget.item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review item kept in queue for later.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This review item could not be reopened.')),
    );
  }

  Future<_MissingAction?> _showMissingAction(BuildContext context) {
    return showDialog<_MissingAction>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Review source missing'),
        content: const Text(
          'The original question was not found. You can remove this item or keep it in your queue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _MissingAction.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _MissingAction.requeue),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _MissingAction.remove),
            child: const Text('Remove item'),
          ),
        ],
      ),
    );
  }
}

enum _MissingAction { cancel, requeue, remove }
