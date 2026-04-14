import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ee_evaluation.dart';

class EEAttempt {
  final String id;
  final String combinaisonId;
  final String monthId;
  final double scoreOutOf20;
  final int nclcLevel;
  final String cefrLevel;
  final int tache1WordCount;
  final int tache2WordCount;
  final int tache3WordCount;
  final double? tache1Score;
  final double? tache2Score;
  final double? tache3Score;
  final String? feedback;
  final String? tache1Feedback;
  final String? tache2Feedback;
  final String? tache3Feedback;
  final String? corrections;
  final String? suggestions;
  final String? tache1Answer;
  final String? tache2Answer;
  final String? tache3Answer;
  final DateTime createdAt;

  const EEAttempt({
    required this.id,
    required this.combinaisonId,
    required this.monthId,
    required this.scoreOutOf20,
    required this.nclcLevel,
    required this.cefrLevel,
    required this.tache1WordCount,
    required this.tache2WordCount,
    required this.tache3WordCount,
    this.tache1Score,
    this.tache2Score,
    this.tache3Score,
    this.feedback,
    this.tache1Feedback,
    this.tache2Feedback,
    this.tache3Feedback,
    this.corrections,
    this.suggestions,
    this.tache1Answer,
    this.tache2Answer,
    this.tache3Answer,
    required this.createdAt,
  });

  factory EEAttempt.fromFirestore(String id, Map<String, dynamic> map) {
    final createdAtData = map['createdAt'];
    return EEAttempt(
      id: id,
      combinaisonId: (map['combinaisonId'] ?? '').toString(),
      monthId: (map['monthId'] ?? '').toString(),
      scoreOutOf20: _asDouble(map['scoreOutOf20']),
      nclcLevel: _asInt(map['nclcLevel']),
      cefrLevel: (map['cefrLevel'] ?? 'A1').toString(),
      tache1WordCount: _asInt(map['tache1WordCount']),
      tache2WordCount: _asInt(map['tache2WordCount']),
      tache3WordCount: _asInt(map['tache3WordCount']),
      tache1Score: map['tache1Score']?.toDouble(),
      tache2Score: map['tache2Score']?.toDouble(),
      tache3Score: map['tache3Score']?.toDouble(),
      feedback: map['feedback']?.toString(),
      tache1Feedback: map['tache1Feedback']?.toString(),
      tache2Feedback: map['tache2Feedback']?.toString(),
      tache3Feedback: map['tache3Feedback']?.toString(),
      corrections: map['corrections']?.toString(),
      suggestions: map['suggestions']?.toString(),
      tache1Answer: map['tache1Answer']?.toString(),
      tache2Answer: map['tache2Answer']?.toString(),
      tache3Answer: map['tache3Answer']?.toString(),
      createdAt: createdAtData is Timestamp
          ? createdAtData.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'combinaisonId': combinaisonId,
      'monthId': monthId,
      'scoreOutOf20': scoreOutOf20,
      'nclcLevel': nclcLevel,
      'cefrLevel': cefrLevel,
      'tache1WordCount': tache1WordCount,
      'tache2WordCount': tache2WordCount,
      'tache3WordCount': tache3WordCount,
      'tache1Score': tache1Score,
      'tache2Score': tache2Score,
      'tache3Score': tache3Score,
      'feedback': feedback,
      'tache1Feedback': tache1Feedback,
      'tache2Feedback': tache2Feedback,
      'tache3Feedback': tache3Feedback,
      'corrections': corrections,
      'suggestions': suggestions,
      'tache1Answer': tache1Answer,
      'tache2Answer': tache2Answer,
      'tache3Answer': tache3Answer,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String? getAnswerForTache(int index) {
    switch (index) {
      case 0:
        return tache1Answer;
      case 1:
        return tache2Answer;
      case 2:
        return tache3Answer;
      default:
        return null;
    }
  }

  String? getFeedbackForTache(int index) {
    switch (index) {
      case 0:
        return tache1Feedback;
      case 1:
        return tache2Feedback;
      case 2:
        return tache3Feedback;
      default:
        return null;
    }
  }

  double? getScoreForTache(int index) {
    switch (index) {
      case 0:
        return tache1Score;
      case 1:
        return tache2Score;
      case 2:
        return tache3Score;
      default:
        return null;
    }
  }

  EECombinaisonEvaluation toEvaluation() {
    final taches = <EETacheEvaluation>[];

    if (tache1Score != null) {
      taches.add(
        EETacheEvaluation(
          title: 'Tache 1',
          score: tache1Score!,
          maxScore: 25,
          feedback: tache1Feedback ?? '',
        ),
      );
    }
    if (tache2Score != null) {
      taches.add(
        EETacheEvaluation(
          title: 'Tache 2',
          score: tache2Score!,
          maxScore: 25,
          feedback: tache2Feedback ?? '',
        ),
      );
    }
    if (tache3Score != null) {
      taches.add(
        EETacheEvaluation(
          title: 'Tache 3',
          score: tache3Score!,
          maxScore: 25,
          feedback: tache3Feedback ?? '',
        ),
      );
    }

    return EECombinaisonEvaluation(
      overallScore: (scoreOutOf20 / 20) * 100,
      maxScore: 100,
      taches: taches,
      generalFeedback: feedback ?? '',
      corrections: corrections ?? '',
      suggestions: suggestions ?? '',
      wordCounts: {
        'tache1': tache1WordCount,
        'tache2': tache2WordCount,
        'tache3': tache3WordCount,
      },
    );
  }
}

class EEProgressSummary {
  final int attemptsCount;
  final double bestScore;
  final double lastScore;
  final DateTime? lastAttemptAt;
  final double averageScore;
  final int bestNclcLevel;
  final int currentNclcLevel;
  final String currentCefrLevel;
  final double averageTache1Score;
  final double averageTache2Score;
  final double averageTache3Score;
  final List<EEAttempt> recentAttempts;

  const EEProgressSummary({
    required this.attemptsCount,
    required this.bestScore,
    required this.lastScore,
    this.lastAttemptAt,
    required this.averageScore,
    required this.bestNclcLevel,
    required this.currentNclcLevel,
    required this.currentCefrLevel,
    required this.averageTache1Score,
    required this.averageTache2Score,
    required this.averageTache3Score,
    required this.recentAttempts,
  });

  factory EEProgressSummary.empty() {
    return const EEProgressSummary(
      attemptsCount: 0,
      bestScore: 0,
      lastScore: 0,
      lastAttemptAt: null,
      averageScore: 0,
      bestNclcLevel: 0,
      currentNclcLevel: 0,
      currentCefrLevel: 'A1',
      averageTache1Score: 0,
      averageTache2Score: 0,
      averageTache3Score: 0,
      recentAttempts: [],
    );
  }

  factory EEProgressSummary.fromAttempts(List<EEAttempt> attempts) {
    if (attempts.isEmpty) return EEProgressSummary.empty();

    final scores = attempts.map((a) => a.scoreOutOf20).toList();
    final best = scores.reduce((a, b) => a > b ? a : b);
    final last = attempts.first.scoreOutOf20;
    final avg = scores.reduce((a, b) => a + b) / scores.length;

    final nclcLevels = attempts.map((a) => a.nclcLevel).toList();
    final bestNclc = nclcLevels.reduce((a, b) => a > b ? a : b);
    final currentNclc = attempts.first.nclcLevel;
    final currentCefr = attempts.first.cefrLevel;

    final t1Scores = attempts
        .where((a) => a.tache1Score != null)
        .map((a) => a.tache1Score!)
        .toList();
    final t2Scores = attempts
        .where((a) => a.tache2Score != null)
        .map((a) => a.tache2Score!)
        .toList();
    final t3Scores = attempts
        .where((a) => a.tache3Score != null)
        .map((a) => a.tache3Score!)
        .toList();

    final avgT1 = t1Scores.isEmpty
        ? 0.0
        : t1Scores.reduce((a, b) => a + b) / t1Scores.length;
    final avgT2 = t2Scores.isEmpty
        ? 0.0
        : t2Scores.reduce((a, b) => a + b) / t2Scores.length;
    final avgT3 = t3Scores.isEmpty
        ? 0.0
        : t3Scores.reduce((a, b) => a + b) / t3Scores.length;

    return EEProgressSummary(
      attemptsCount: attempts.length,
      bestScore: best,
      lastScore: last,
      lastAttemptAt: attempts.first.createdAt,
      averageScore: avg,
      bestNclcLevel: bestNclc,
      currentNclcLevel: currentNclc,
      currentCefrLevel: currentCefr,
      averageTache1Score: avgT1,
      averageTache2Score: avgT2,
      averageTache3Score: avgT3,
      recentAttempts: attempts.take(10).toList(),
    );
  }
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _asDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int calculateNCLCFromScore(double score) {
  if (score >= 16) return 10;
  if (score >= 14) return 9;
  if (score >= 12) return 8;
  if (score >= 10) return 7;
  if (score >= 7) return 6;
  if (score >= 6) return 5;
  if (score >= 4) return 4;
  return 4;
}

String calculateCEFRFromScore(double score) {
  if (score >= 16) return 'C2';
  if (score >= 14) return 'C1';
  if (score >= 10) return 'B2';
  if (score >= 7) return 'B1';
  if (score >= 4) return 'A2';
  return 'A1';
}

Color getLevelColor(int nclcLevel) {
  if (nclcLevel >= 9) return Colors.green;
  if (nclcLevel >= 7) return Colors.lightGreen;
  if (nclcLevel >= 5) return Colors.orange;
  return Colors.red;
}
