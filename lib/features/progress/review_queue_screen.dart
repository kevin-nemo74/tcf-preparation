import 'package:flutter/material.dart';
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

typedef ReviewQueueStreamFactory =
    Stream<List<ReviewQueueItem>> Function(String uid, {int limit});
typedef ReviewQueueMutation = Future<void> Function(String uid, String itemId);

int reviewQueuePriority(ReviewQueueItem item) {
  if (item.lastUserAnswer == null || item.lastUserAnswer!.isEmpty) return 3;
  if (item.lastUserAnswer != item.correctAnswer) return 2;
  return 1;
}

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
      appBar: AppBar(title: const Text('File de revision')),
      body: StreamBuilder<List<ReviewQueueItem>>(
        stream: queueStream(uid, limit: 40),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, __) => const ShimmerSkeleton(height: 120),
            );
          }

          final items = [...(snapshot.data ?? const <ReviewQueueItem>[])]
            ..sort(
              (a, b) =>
                  reviewQueuePriority(b).compareTo(reviewQueuePriority(a)),
            );
          if (items.isEmpty) {
            return const _EmptyQueue();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _QueueHeader(
                count: items.length,
                highPriorityCount: items
                    .where((e) => reviewQueuePriority(e) >= 2)
                    .length,
              ),
              const SizedBox(height: 16),
              ...items.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedFadeSlide(
                    delay: Duration(milliseconds: 40 * entry.key),
                    child: _QueueCard(
                      uid: uid,
                      item: entry.value,
                      loadComprehensionTests: loadComprehensionTests,
                      loadOralTests: loadOralTests,
                      markItemDone: markItemDone,
                      restoreItem: restoreItem,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QueueHeader extends StatelessWidget {
  final int count;
  final int highPriorityCount;

  const _QueueHeader({required this.count, required this.highPriorityCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.4),
            cs.tertiaryContainer.withValues(alpha: 0.3),
            cs.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.assignment_late_rounded,
                  color: cs.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File de revision',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count question(s) necessitent une revision',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (highPriorityCount > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: cs.errorContainer.withValues(alpha: 0.5),
                border: Border.all(color: cs.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.priority_high_rounded, color: cs.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$highPriorityCount question(s) prioritaire(s)',
                    style: TextStyle(
                      color: cs.onErrorContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: cs.surface,
            border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primaryContainer.withValues(alpha: 0.5),
                      cs.secondaryContainer.withValues(alpha: 0.3),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'File de revision vide',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Les reponses incorrectes ou signalees apparaitront ici apres chaque tentative.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                  height: 1.5,
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
    final priority = reviewQueuePriority(item);
    final isOral = item.moduleType == 'CO';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isOral
                        ? [
                            cs.secondaryContainer.withValues(alpha: 0.7),
                            cs.tertiaryContainer.withValues(alpha: 0.5),
                          ]
                        : [
                            cs.primaryContainer.withValues(alpha: 0.7),
                            cs.secondaryContainer.withValues(alpha: 0.5),
                          ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOral
                          ? Icons.headphones_rounded
                          : Icons.menu_book_rounded,
                      size: 16,
                      color: isOral ? cs.secondary : cs.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOral ? 'Orale' : 'Comprehension',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: isOral
                            ? cs.onSecondaryContainer
                            : cs.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.testTitle.isEmpty ? item.testId : item.testTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (priority >= 2)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: priority == 3
                        ? cs.tertiaryContainer.withValues(alpha: 0.7)
                        : cs.errorContainer.withValues(alpha: 0.6),
                    border: Border.all(
                      color: priority == 3
                          ? cs.tertiary.withValues(alpha: 0.3)
                          : cs.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        priority == 3
                            ? Icons.flag_rounded
                            : Icons.close_rounded,
                        size: 14,
                        color: priority == 3
                            ? cs.onTertiaryContainer
                            : cs.onErrorContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        priority == 3 ? 'Signalee' : 'Manquee',
                        style: TextStyle(
                          fontSize: 11,
                          color: priority == 3
                              ? cs.onTertiaryContainer
                              : cs.onErrorContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Question ${item.questionId}',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.lastUserAnswer == null || item.lastUserAnswer!.isEmpty
                      ? 'Vous avez signale cette question pour revision.'
                      : 'Reponse: ${item.lastUserAnswer} | Correcte: ${item.correctAnswer}',
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _openReview,
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text('Revoir'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: IconButton(
                  onPressed: _busy ? null : _markDone,
                  icon: Icon(Icons.done_rounded, color: cs.primary),
                  tooltip: 'Marquer comme terminee',
                ),
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
                title: '${test.title} - Revision',
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
                title: '${test.title} - Revision',
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
        const SnackBar(content: Text('Element retire de la file de revision.')),
      );
      return;
    }
    if (action == _MissingAction.requeue) {
      await widget.restoreItem(widget.uid, widget.item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Element conserve dans la file pour plus tard.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cet element de revision ne peut pas etre rouvert.'),
      ),
    );
  }

  Future<_MissingAction?> _showMissingAction(BuildContext context) {
    return showDialog<_MissingAction>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Source de revision introuvable'),
        content: const Text(
          'La question d\'origine est introuvable. Vous pouvez retirer cet element ou le conserver.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _MissingAction.cancel),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _MissingAction.requeue),
            child: const Text('Conserver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _MissingAction.remove),
            child: const Text('Retirer l\'element'),
          ),
        ],
      ),
    );
  }
}

enum _MissingAction { cancel, requeue, remove }
