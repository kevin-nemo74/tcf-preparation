class EETacheEvaluation {
  final String title;
  final double score;
  final double maxScore;
  final String feedback;

  const EETacheEvaluation({
    required this.title,
    required this.score,
    required this.maxScore,
    required this.feedback,
  });

  double get percentage => (score / maxScore) * 100;
}

class EECombinaisonEvaluation {
  final double overallScore;
  final double maxScore;
  final List<EETacheEvaluation> taches;
  final String generalFeedback;
  final String corrections;
  final String suggestions;
  final Map<String, int> wordCounts;

  const EECombinaisonEvaluation({
    required this.overallScore,
    required this.maxScore,
    required this.taches,
    required this.generalFeedback,
    required this.corrections,
    required this.suggestions,
    required this.wordCounts,
  });

  double get scoreOutOf20 => (overallScore / 100) * 20;

  double get calculatedOverallScore {
    if (taches.isEmpty) return 0;
    return taches.fold(0.0, (sum, t) => sum + t.score);
  }

  double get calculatedScoreOutOf20 => (calculatedOverallScore / 100) * 20;

  bool get hasReasonableOverallScore {
    if (taches.isEmpty) return false;
    final avgTaskScore = calculatedOverallScore / taches.length;
    final expectedOverallFromAvg = avgTaskScore * taches.length;
    return (overallScore - expectedOverallFromAvg).abs() < 30;
  }

  double get finalScoreOutOf20 {
    if (!hasReasonableOverallScore && calculatedOverallScore > 0) {
      return calculatedScoreOutOf20;
    }
    return scoreOutOf20;
  }

  factory EECombinaisonEvaluation.fromJson(Map<String, dynamic> json) {
    final tachesList = <EETacheEvaluation>[];
    final tachesData = json['taches'] as Map<String, dynamic>?;
    if (tachesData != null) {
      for (final key in ['tache1', 'tache2', 'tache3']) {
        final data = tachesData[key] as Map<String, dynamic>?;
        if (data != null) {
          final score = (data['score'] ?? 0).toDouble();
          final maxScore = (data['max_score'] ?? 25).toDouble();
          final feedback = data['feedback']?.toString() ?? '';

          tachesList.add(
            EETacheEvaluation(
              title:
                  data['title']?.toString() ?? 'Tâche ${tachesList.length + 1}',
              score: score.clamp(0, 25),
              maxScore: maxScore,
              feedback: feedback,
            ),
          );
        }
      }
    }

    final wc = <String, int>{};
    final wcData = json['word_counts'] as Map<String, dynamic>?;
    if (wcData != null) {
      for (final key in ['tache1', 'tache2', 'tache3']) {
        wc[key] = (wcData[key] as num?)?.toInt() ?? 0;
      }
    }

    final reportedOverall = (json['overall_score'] ?? 0).toDouble();
    final calculatedOverall = tachesList.fold(0.0, (sum, t) => sum + t.score);

    double overallScore;
    if (tachesList.isNotEmpty && calculatedOverall > 0) {
      final avgTaskScore = calculatedOverall / tachesList.length;
      final expectedOverall = avgTaskScore * 4;
      if ((reportedOverall - expectedOverall).abs() > 30 &&
          reportedOverall < 20) {
        overallScore = calculatedOverall;
      } else {
        overallScore = reportedOverall;
      }
    } else {
      overallScore = reportedOverall;
    }

    return EECombinaisonEvaluation(
      overallScore: overallScore.clamp(0, 100),
      maxScore: (json['max_score'] ?? 100).toDouble(),
      taches: tachesList,
      generalFeedback: json['general_feedback']?.toString() ?? '',
      corrections: json['corrections']?.toString() ?? '',
      suggestions: json['suggestions']?.toString() ?? '',
      wordCounts: wc,
    );
  }
}
