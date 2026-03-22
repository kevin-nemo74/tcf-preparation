import 'package:flutter_test/flutter_test.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/local_tests_data.dart';
import 'package:tcf_canada_preparation/features/oral/data/local_oral_tests_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CE tests asset loads with questions', () async {
    final tests = await LocalTestsData.loadTests();
    expect(tests, isNotEmpty);
    expect(tests.first.questions, isNotEmpty);
    expect(tests.first.id, isNotEmpty);
  });

  test('CO oral tests asset loads with questions', () async {
    final tests = await LocalOralTestsData.loadTests();
    expect(tests, isNotEmpty);
    expect(tests.first.questions, isNotEmpty);
    expect(tests.first.id, isNotEmpty);
  });
}
