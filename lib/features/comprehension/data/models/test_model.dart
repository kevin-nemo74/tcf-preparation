import 'package:tcf_canada_preparation/features/comprehension/data/models/question_model.dart';

class TestModel {
  final String id;
  final String title;
  final String type;
  final int durationMinutes;
  final List<QuestionModel> questions;

  TestModel({
    required this.id,
    required this.title,
    required this.type,
    required this.durationMinutes,
    required this.questions,
  });
}
