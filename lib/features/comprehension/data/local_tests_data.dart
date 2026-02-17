import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/option_model.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/question_model.dart';
import 'package:tcf_canada_preparation/features/comprehension/data/models/test_model.dart';



class LocalTestsData {
  static Future<List<TestModel>> loadTests() async {
    final String jsonString =
    await rootBundle.loadString('assets/data/ce_tests.json');

    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((test) {
      return TestModel(
        id: test['id'],
        title: test['title'],
        type: test['type'],
        durationMinutes: test['durationMinutes'],
        questions: (test['questions'] as List).map((q) {
          return QuestionModel(
            id: q['id'],
            imagePath: q['imagePath'],
            correctAnswer: q['correctAnswer'],
            options: (q['options'] as List).map((o) {
              return OptionModel(
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
