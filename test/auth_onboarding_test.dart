import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcf_canada_preparation/features/auth/auth_gate.dart';
import 'package:tcf_canada_preparation/l10n/app_localizations.dart';

import 'test_helpers.dart';

void main() {
  setUp(() {
    ensureTestBinding();
    setupTestSharedPreferences();
  });

  testWidgets('authenticated + onboardingDoneCheck false shows onboarding', (tester) async {
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
          authenticatedWidget: const Scaffold(body: Text('PORTAL')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('How scoring works'), findsOneWidget);
  });

  testWidgets('onboarding Next then Start reaches portal', (tester) async {
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
          authenticatedWidget: const Scaffold(body: Text('PORTAL')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Study rhythm'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Track your progress'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('PORTAL'), findsOneWidget);
  });

  testWidgets('onboardingDoneCheck true skips onboarding', (tester) async {
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
          onboardingDoneCheck: () async => true,
          authenticatedWidget: const Scaffold(body: Text('PORTAL')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('PORTAL'), findsOneWidget);
    expect(find.text('How scoring works'), findsNothing);
  }, skip: true);
}
