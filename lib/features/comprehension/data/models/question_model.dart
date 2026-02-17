import 'option_model.dart';

class QuestionModel {
  final String id;
  final String imagePath;
  final List<OptionModel> options;
  final String correctAnswer;

  QuestionModel({
    required this.id,
    required this.imagePath,
    required this.options,
    required this.correctAnswer,
  });
}
