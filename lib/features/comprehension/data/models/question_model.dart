import 'option_model.dart';

class QuestionModel {
  final String id;
  final String imageUrl;
  final List<OptionModel> options;
  final String correctAnswer;
  final String explanation;

  QuestionModel({
    required this.id,
    required this.imageUrl,
    required this.options,
    required this.correctAnswer,
    this.explanation = '',
  });
}