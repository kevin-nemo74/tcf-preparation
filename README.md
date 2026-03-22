# TCF Canada Preparation

Flutter app for practicing TCF Canada comprehension and oral tests with Firebase-backed auth and user profile data.

## Stack

- Flutter (Dart SDK `^3.10.1`)
- Firebase: Auth, Firestore, Storage, Core
- State management: `provider`

## Prerequisites

- Flutter SDK installed and available in `PATH`
- A configured Firebase project (this repository already includes FlutterFire options)
- Android Studio or VS Code with Flutter extensions

## Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Verify Flutter environment:
   ```bash
   flutter doctor
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Firebase and Platform Support

The app initializes Firebase using `DefaultFirebaseOptions.currentPlatform` in `lib/main.dart`.

Current `firebase_options.dart` support:

- Supported: `android`, `ios`, `web`, `windows`
- Not configured yet: `macos`, `linux` (throws `UnsupportedError`)

If you need macOS/Linux support, regenerate Firebase config:

```bash
flutterfire configure
```

## Common Commands

- Run analyzer:
  ```bash
  flutter analyze
  ```
- Run tests (full suite):
  ```bash
  flutter test
  ```
- Run a single test file:
  ```bash
  flutter test test/widget_test.dart
  flutter test test/auth_onboarding_test.dart
  flutter test test/local_data_load_test.dart
  ```
- Run app in release mode (device required):
  ```bash
  flutter run --release
  ```
- Build Android release APK:
  ```bash
  flutter build apk --release
  ```

## Android Release Signing

Release signing is configured to use `android/key.properties` when present.  
Create your local `android/key.properties` (do not commit secrets) with:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=../keystore/upload-keystore.jks
```

Then place your keystore file at the path referenced by `storeFile`.

If `android/key.properties` is missing, Android release builds fall back to debug signing for local testing only.

## Profile Progress Fields

Profile stats read optional fields from the user document in Firestore:

- `attemptsCount` (or `attempts` / `totalAttempts`)
- `bestScore` (or `highestScore`)
- `lastAttemptAt` (or `latestAttemptAt`)

If fields are missing, the UI shows safe defaults.

## Testing

- **Commands**: `flutter test` runs the full suite (same expectation as CI in `.github/workflows/flutter.yml`). Use `flutter test path/to/test.dart` for focused runs.
- **Harness**: `test/test_helpers.dart` provides `ensureTestBinding()` and `setupTestSharedPreferences()` so widget tests can mock `SharedPreferences` before pumping widgets.
- **Auth / onboarding**: `AuthGate` accepts an optional `onboardingDoneCheck` so tests can drive the authenticated → onboarding → portal flow without Firestore. See `test/auth_onboarding_test.dart`.
- **Local exam data**: `test/local_data_load_test.dart` asserts bundled CE/CO JSON loads non-empty in the test environment (catches asset path regressions).

## UI & motion

- **Motion tokens**: `lib/core/theme/motion.dart` (`AppMotion`: durations + default curve).
- **Theme**: Warmer palette, `InkSparkle` splash, and `pageTransitionsTheme` in `lib/core/theme/app_theme.dart`.
- **Shared widgets**: `lib/core/widgets/app_motion.dart` — `AnimatedFadeSlide`, `PressableScale`, `StaggeredColumn`, `ShimmerSkeleton`; `contextReducedMotion()` respects `MediaQuery.disableAnimations`.
- **Routes**: `AppRoutes.fadeSlide()` in `lib/core/navigation/app_routes.dart` for fade + slide pushes where used.

## Pre-PR Quality Checklist

Before opening a PR:

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`
4. Run the app on at least one target platform (`flutter run`)
5. For Android release changes, verify `flutter build apk --release`

PowerShell shortcut for steps 1-3:

```powershell
./verify.ps1
```
