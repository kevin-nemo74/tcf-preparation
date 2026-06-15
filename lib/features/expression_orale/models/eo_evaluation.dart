class EOEvaluation {
  final double overallScore;
  final double maxScore;
  final String generalFeedback;
  final String corrections;
  final String suggestions;
  final double contentScore;
  final double vocabularyScore;
  final double grammarScore;
  final double coherenceScore;
  final String transcription;

  const EOEvaluation({
    required this.overallScore,
    required this.maxScore,
    required this.generalFeedback,
    required this.corrections,
    required this.suggestions,
    required this.contentScore,
    required this.vocabularyScore,
    required this.grammarScore,
    required this.coherenceScore,
    required this.transcription,
  });

  factory EOEvaluation.fromJson(Map<String, dynamic> json) {
    return EOEvaluation(
      overallScore: (json['overall_score'] ?? 0).toDouble(),
      maxScore: (json['max_score'] ?? 20).toDouble(),
      generalFeedback: json['general_feedback'] ?? '',
      corrections: json['corrections'] ?? '',
      suggestions: json['suggestions'] ?? '',
      contentScore: (json['content_score'] ?? 0).toDouble(),
      vocabularyScore: (json['vocabulary_score'] ?? 0).toDouble(),
      grammarScore: (json['grammar_score'] ?? 0).toDouble(),
      coherenceScore: (json['coherence_score'] ?? 0).toDouble(),
      transcription: json['transcription'] ?? '',
    );
  }

  double get percentage => (overallScore / maxScore) * 100;
}
