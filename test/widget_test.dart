import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tcf_canada_preparation/features/auth/auth_gate.dart';

void main() {
  testWidgets('shows login when unauthenticated and online', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate.testable(
          checkConnectivity: () async => ConnectivityResult.wifi,
          connectivityChanges: Stream<List<ConnectivityResult>>.value(
            <ConnectivityResult>[ConnectivityResult.wifi],
          ),
          authStatusChanges: Stream<bool>.value(false),
          unauthenticatedWidget: const Scaffold(body: Text('LOGIN_SCREEN')),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('LOGIN_SCREEN'), findsOneWidget);
  });

  testWidgets('shows exam portal when authenticated and online', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate.testable(
          checkConnectivity: () async => ConnectivityResult.mobile,
          connectivityChanges: Stream<List<ConnectivityResult>>.value(
            <ConnectivityResult>[ConnectivityResult.mobile],
          ),
          authStatusChanges: Stream<bool>.value(true),
          authenticatedWidget: const Scaffold(body: Text('EXAM_PORTAL')),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('EXAM_PORTAL'), findsOneWidget);
  });

  testWidgets('shows offline screen when there is no connectivity', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate.testable(
          checkConnectivity: () async => ConnectivityResult.none,
          connectivityChanges: Stream<List<ConnectivityResult>>.value(
            <ConnectivityResult>[ConnectivityResult.none],
          ),
          authStatusChanges: Stream<bool>.value(false),
          offlineBuilder: (_) => const Scaffold(body: Text('OFFLINE_SCREEN')),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('OFFLINE_SCREEN'), findsOneWidget);
  });
}
