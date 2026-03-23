import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/screens/connection_required_screen.dart';
import '../dashboard/exam_portal_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../progress/progress_repository.dart';
import 'screens/login_screen.dart';

class AuthGate extends StatefulWidget {
  final Future<ConnectivityResult> Function()? checkConnectivity;
  final Stream<List<ConnectivityResult>>? connectivityChanges;
  final Stream<User?>? authStateChanges;
  final Stream<bool>? authStatusChanges;
  final Widget? loadingWidget;
  final Widget? unauthenticatedWidget;
  final Widget? authenticatedWidget;
  final Widget Function(VoidCallback onRetry)? offlineBuilder;
  /// When set, used instead of [ProgressRepository.isOnboardingDone] after sign-in.
  /// Use in tests to avoid Firestore. When null on the [authStatusChanges] path,
  /// onboarding is skipped (shows app immediately).
  final Future<bool> Function()? onboardingDoneCheck;

  const AuthGate({
    super.key,
    this.checkConnectivity,
    this.connectivityChanges,
    this.authStateChanges,
    this.authStatusChanges,
    this.loadingWidget,
    this.unauthenticatedWidget,
    this.authenticatedWidget,
    this.offlineBuilder,
    this.onboardingDoneCheck,
  });
  const AuthGate.testable({
    super.key,
    this.checkConnectivity,
    this.connectivityChanges,
    this.authStateChanges,
    this.authStatusChanges,
    this.loadingWidget,
    this.unauthenticatedWidget,
    this.authenticatedWidget,
    this.offlineBuilder,
    this.onboardingDoneCheck,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _hasInternet = true;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  late Stream<User?> _userStream;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    final stream = widget.connectivityChanges ?? Connectivity().onConnectivityChanged;
    _sub = stream.listen((results) {
      final online = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      if (mounted) setState(() => _hasInternet = online);
    });

    if (widget.authStatusChanges != null) {
      _userStream = const Stream<User?>.empty();
    } else {
      _userStream = widget.authStateChanges ?? FirebaseAuth.instance.authStateChanges();
    }
  }

  @override
  void didUpdateWidget(covariant AuthGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authStateChanges != widget.authStateChanges ||
        oldWidget.authStatusChanges != widget.authStatusChanges) {
      if (widget.authStatusChanges != null) {
        _userStream = const Stream<User?>.empty();
      } else {
        _userStream = widget.authStateChanges ?? FirebaseAuth.instance.authStateChanges();
      }
    }
  }

  Future<void> _checkConnectivity() async {
    final check = widget.checkConnectivity ?? Connectivity().checkConnectivity;
    final results = await check();
    final online = results != ConnectivityResult.none;
    if (mounted) setState(() => _hasInternet = online);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      final offlineBuilder = widget.offlineBuilder;
      if (offlineBuilder != null) return offlineBuilder(_checkConnectivity);
      return ConnectionRequiredScreen(onRetry: _checkConnectivity);
    }

    final authStatusChanges = widget.authStatusChanges;
    if (authStatusChanges != null) {
      return StreamBuilder<bool>(
        stream: authStatusChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return widget.loadingWidget ??
                const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
          }

          final isAuthenticated = snapshot.data ?? false;
          if (!isAuthenticated) {
            return widget.unauthenticatedWidget ?? const LoginScreen();
          }
          final app = widget.authenticatedWidget ?? const ExamPortalScreen();
          final onboardingCheck = widget.onboardingDoneCheck;
          if (onboardingCheck == null) return app;
          return FutureBuilder<bool>(
            future: onboardingCheck(),
            builder: (context, onboardSnap) {
              if (onboardSnap.connectionState == ConnectionState.waiting) {
                return widget.loadingWidget ??
                    const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              final done = onboardSnap.data ?? false;
              if (done) return app;
              return OnboardingScreen(child: app);
            },
          );
        },
      );
    }

    return StreamBuilder<User?>(
      stream: _userStream,
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        // Loading (only show while we have no data yet).
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingWidget ??
              const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
        }

        final user = snapshot.data;

        // Not logged in -> Login
        if (user == null) {
          return widget.unauthenticatedWidget ?? const LoginScreen();
        }

        // Logged in -> Onboarding (first run) -> App
        final app = widget.authenticatedWidget ?? ExamPortalScreen(uid: user.uid);
        final onboardingFuture = widget.onboardingDoneCheck ??
            () => ProgressRepository.isOnboardingDone(uid: user.uid);
        return FutureBuilder<bool>(
          future: onboardingFuture(),
          builder: (context, onboardSnap) {
            if (onboardSnap.connectionState == ConnectionState.waiting) {
              return widget.loadingWidget ??
                  const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
            }
            final done = onboardSnap.data ?? false;
            if (done) return app;
            return OnboardingScreen(child: app);
          },
        );
      },
    );
  }
}