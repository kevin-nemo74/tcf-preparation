import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tcf_canada_preparation/features/auth/auth_gate.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import 'package:tcf_canada_preparation/features/progress/review_queue_screen.dart';
import 'package:tcf_canada_preparation/l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('auth + onboarding journey reaches portal', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: AuthGate.testable(
          checkConnectivity: () async => ConnectivityResult.wifi,
          connectivityChanges: Stream<List<ConnectivityResult>>.value(
            <ConnectivityResult>[ConnectivityResult.wifi],
          ),
          authStatusChanges: Stream<bool>.value(true),
          onboardingDoneCheck: () async => false,
          authenticatedWidget: const Scaffold(body: Text('PORTAL_READY')),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('How scoring works'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('PORTAL_READY'), findsOneWidget);
  });

  testWidgets('review queue missing item can be removed', (tester) async {
    var removed = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ReviewQueueScreen(
          uid: 'integration-user',
          queueStream: (_, {int limit = 20}) => Stream.value(
            const [
              ReviewQueueItem(
                id: 'CE:Q404',
                questionId: 'Q404',
                moduleType: 'CE',
                testId: 'ce_404',
                testTitle: 'Broken Test',
                lastUserAnswer: 'A',
                correctAnswer: 'B',
                needsReview: true,
                lastUpdatedAt: null,
              ),
            ],
          ),
          loadComprehensionTests: () async => const [],
          markItemDone: (uid, itemId) async {
            removed = uid == 'integration-user' && itemId == 'CE:Q404';
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Open review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove item'));
    await tester.pumpAndSettle();

    expect(removed, isTrue);
  });
}
