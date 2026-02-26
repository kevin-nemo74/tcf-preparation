import 'oral_question_model.dart';

class OralTestModel {
  final String id;
  final String title;
  final String type; // CO
  final int durationMinutes;
  final List<OralQuestionModel> questions;

  OralTestModel({
    required this.id,
    required this.title,
    required this.type,
    required this.durationMinutes,
    required this.questions,
  });
}