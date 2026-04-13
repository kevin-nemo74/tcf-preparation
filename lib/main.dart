import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tcf_canada_preparation/firebase_options.dart';
import 'package:tcf_canada_preparation/l10n/app_localizations.dart';

import 'app/locale_controller.dart';
import 'app/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_scroll_behavior.dart';
import 'features/admin/user_validation_service.dart';
import 'features/auth/auth_gate.dart';
import 'core/services/crashlytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  CrashlyticsService.setup();

  final themeController = ThemeController();
  await themeController.loadThemeMode();
  final localeController = LocaleController();
  await localeController.loadLocaleMode();

  UserValidationService.instance.startPeriodicCheck(
    interval: const Duration(seconds: 30),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeController),
        ChangeNotifierProvider(create: (_) => localeController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeController.themeMode,
      locale: localeController.locale,
      localeResolutionCallback: (locale, supportedLocales) {
        final appLocale = localeController.locale;
        if (appLocale != null) return appLocale;
        if (locale == null) return const Locale('fr');
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) return supported;
        }
        return const Locale('fr');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: kIsWeb
          ? []
          : [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
      home: const AuthGate(),
    );
  }
}
