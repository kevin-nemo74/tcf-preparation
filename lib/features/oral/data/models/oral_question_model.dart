import 'oral_option_model.dart';

class OralQuestionModel {
  final String id;
  final String audioPath;
  final String? imagePath;
  final List<OralOptionModel> options;
  final String correctAnswer;

  OralQuestionModel({
    required this.id,
    required this.audioPath,
    this.imagePath,
    required this.options,
    required this.correctAnswer,
  });
}