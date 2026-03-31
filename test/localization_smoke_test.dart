import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcf_canada_preparation/features/onboarding/onboarding_screen.dart';
import 'package:tcf_canada_preparation/l10n/app_localizations.dart';

void main() {
  Widget appWithLocale(Locale locale) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OnboardingScreen(
        child: Scaffold(body: Text('PORTAL')),
      ),
    );
  }

  testWidgets('onboarding localizes in French', (tester) async {
    await tester.pumpWidget(appWithLocale(const Locale('fr')));
    await tester.pumpAndSettle();
    expect(find.text('Comprendre le score'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
  });

  testWidgets('onboarding localizes in English', (tester) async {
    await tester.pumpWidget(appWithLocale(const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('How scoring works'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}

