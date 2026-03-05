import 'dart:convert';
import 'package:flutter/services.dart';

import 'models/oral_test_model.dart';
import 'models/oral_question_model.dart';
import 'models/oral_option_model.dart';

class LocalOralTestsData {
  static Future<List<OralTestModel>> loadTests() async {
    final String jsonString =
    await rootBundle.loadString('assets/data/co_tests.json');

    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((test) {
      return OralTestModel(
        id: test['id'],
        title: test['title'],
        type: test['type'],
        durationMinutes: test['durationMinutes'],
        questions: (test['questions'] as List).map((q) {
          return OralQuestionModel(
            id: q['id'],
            audioPath: q['audioPath'],
            imagePath: q['imagePath'], // null if missing
            correctAnswer: q['correctAnswer'],
            options: (q['options'] as List).map((o) {
              return OralOptionModel(
                id: o['id'],
                text: o['text'],
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }
}