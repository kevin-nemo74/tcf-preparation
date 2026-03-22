import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Call in setUp before any code that uses [ProgressRepository.isOnboardingDone]
/// or onboarding completion persistence.
void setupTestSharedPreferences() {
  SharedPreferences.setMockInitialValues({});
}

void ensureTestBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
}
