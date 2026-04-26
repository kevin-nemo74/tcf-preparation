import 'option_model.dart';

class QuestionModel {
  final String id;
  final String imageUrl;
  final String? audioUrl;
  final List<OptionModel> options;
  final String correctAnswer;
  final String explanation;

  QuestionModel({
    required this.id,
    required this.imageUrl,
    this.audioUrl,
    required this.options,
    required this.correctAnswer,
    this.explanation = '',
  });

  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
}