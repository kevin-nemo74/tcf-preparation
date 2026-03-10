import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcf_canada_preparation/firebase_options.dart';

import 'app/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';

// If you used FlutterFire CLI, you'll have this file:

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Load theme preference
  final themeController = ThemeController();
  await themeController.loadThemeMode();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeController,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeController.themeMode,
      home: const AuthGate(),
    );
  }
}