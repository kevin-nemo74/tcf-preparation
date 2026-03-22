import 'oral_option_model.dart';

class OralQuestionModel {
  final String id;
  final String audioUrl;
  final String? imageUrl;
  final List<OralOptionModel> options;
  final String correctAnswer;
  final String explanation;

  OralQuestionModel({
    required this.id,
    required this.audioUrl,
    this.imageUrl,
    required this.options,
    required this.correctAnswer,
    this.explanation = '',
  });
}