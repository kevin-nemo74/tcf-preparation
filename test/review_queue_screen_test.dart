import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/option_model.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/question_model.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';
import 'package:tcf_canada_preparation/features/oral/data/models/oral_option_model.dart';
import 'package:tcf_canada_preparation/features/oral/data/models/oral_question_model.dart';
import 'package:tcf_canada_preparation/features/oral/data/models/oral_test_model.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/features/progress/review_queue_screen.dart';

void main() {
  test('priority helper ranks flagged highest then missed', () {
    const flagged = ReviewQueueItem(
      id: '1',
      questionId: 'Q1',
      moduleType: 'CE',
      testId: 't1',
      testTitle: 'T1',
      lastUserAnswer: '',
      correctAnswer: 'A',
      needsReview: true,
      lastUpdatedAt: null,
    );
    const missed = ReviewQueueItem(
      id: '2',
      questionId: 'Q2',
      moduleType: 'CE',
      testId: 't1',
      testTitle: 'T1',
      lastUserAnswer: 'B',
      correctAnswer: 'A',
      needsReview: true,
      lastUpdatedAt: null,
    );

    expect(
      reviewQueuePriority(flagged),
      greaterThan(reviewQueuePriority(missed)),
    );
  });

  testWidgets('shows empty state when review queue has no items', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReviewQueueScreen(
          uid: 'uid-1',
          queueStream: (_, {int limit = 20}) =>
              Stream.value(const <ReviewQueueItem>[]),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('File de revision vide'), findsOneWidget);
  });

  testWidgets('shows queued items from both modules', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReviewQueueScreen(
          uid: 'uid-1',
          queueStream: (_, {int limit = 20}) => Stream.value(const [
            ReviewQueueItem(
              id: 'CE:Q1',
              questionId: 'Q1',
              moduleType: 'CE',
              testId: 'ce_01',
              testTitle: 'CE Test 1',
              lastUserAnswer: 'B',
              correctAnswer: 'A',
              needsReview: true,
              lastUpdatedAt: null,
            ),
            ReviewQueueItem(
              id: 'CO:Q2',
              questionId: 'Q2',
              moduleType: 'CO',
              testId: 'co_01',
              testTitle: 'CO Test 1',
              lastUserAnswer: 'C',
              correctAnswer: 'D',
              needsReview: true,
              lastUpdatedAt: null,
            ),
          ]),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('2 question(s) necessitent une revision'), findsOneWidget);
    expect(find.text('CE Test 1'), findsOneWidget);
    expect(find.text('CO Test 1'), findsOneWidget);
    expect(find.text('Comprehension'), findsOneWidget);
    expect(find.text('Orale'), findsOneWidget);
    expect(find.text('2 question(s) prioritaire(s)'), findsOneWidget);
  });

  testWidgets('can open a queued comprehension review item', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReviewQueueScreen(
          uid: 'uid-1',
          queueStream: (_, {int limit = 20}) => Stream.value(const [
            ReviewQueueItem(
              id: 'CE:Q1',
              questionId: 'Q1',
              moduleType: 'CE',
              testId: 'ce_01',
              testTitle: 'CE Test 1',
              lastUserAnswer: 'B',
              correctAnswer: 'A',
              needsReview: true,
              lastUpdatedAt: null,
            ),
          ]),
          loadComprehensionTests: () async => [
            TestModel(
              id: 'ce_01',
              title: 'CE Test 1',
              type: 'CE',
              durationMinutes: 60,
              questions: [
                QuestionModel(
                  id: 'Q1',
                  imageUrl: 'https://example.com/image.png',
                  correctAnswer: 'A',
                  options: [
                    OptionModel(id: 'A', text: 'Option A'),
                    OptionModel(id: 'B', text: 'Option B'),
                  ],
                ),
              ],
            ),
          ],
          loadOralTests: () async => [
            OralTestModel(
              id: 'co_01',
              title: 'CO Test 1',
              type: 'CO',
              durationMinutes: 60,
              questions: [
                OralQuestionModel(
                  id: 'Q2',
                  audioUrl: 'https://example.com/audio.mp3',
                  correctAnswer: 'A',
                  options: [
                    OralOptionModel(id: 'A', text: 'Option A'),
                    OralOptionModel(id: 'B', text: 'Option B'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Revoir'));
    await tester.pumpAndSettle();

    expect(find.text('Revoir les reponses'), findsOneWidget);
    expect(find.text('Question 1'), findsOneWidget);
  });

  testWidgets('missing review source can be removed from queue', (
    tester,
  ) async {
    var markedDone = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ReviewQueueScreen(
          uid: 'uid-1',
          queueStream: (_, {int limit = 20}) => Stream.value(const [
            ReviewQueueItem(
              id: 'CE:Q9',
              questionId: 'Q9',
              moduleType: 'CE',
              testId: 'ce_01',
              testTitle: 'CE Test 1',
              lastUserAnswer: 'B',
              correctAnswer: 'A',
              needsReview: true,
              lastUpdatedAt: null,
            ),
          ]),
          loadComprehensionTests: () async => [],
          markItemDone: (uid, itemId) async {
            markedDone = uid == 'uid-1' && itemId == 'CE:Q9';
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Revoir'));
    await tester.pumpAndSettle();
    expect(find.text('Source de revision introuvable'), findsOneWidget);

    await tester.tap(find.text("Retirer l'element"));
    await tester.pumpAndSettle();

    expect(markedDone, isTrue);
    expect(find.text('Element retire de la file de revision.'), findsOneWidget);
  });
}
