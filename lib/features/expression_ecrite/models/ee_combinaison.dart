import 'dart:convert';
import 'package:flutter/services.dart';

class EETache {
  final String title;
  final String instruction;
  final int minWords;
  final int maxWords;
  final String? documentA;
  final String? documentB;

  const EETache({
    required this.title,
    required this.instruction,
    required this.minWords,
    required this.maxWords,
    this.documentA,
    this.documentB,
  });

  factory EETache.fromJson(Map<String, dynamic> json) {
    return EETache(
      title: json['title'] ?? '',
      instruction: json['instruction'] ?? '',
      minWords: json['minWords'] ?? 0,
      maxWords: json['maxWords'] ?? 0,
      documentA: json['documentA'],
      documentB: json['documentB'],
    );
  }

  bool get hasDocuments => documentA != null && documentB != null;
}

class EECombinaison {
  final String id;
  final EETache tache1;
  final EETache tache2;
  final EETache tache3;

  const EECombinaison({
    required this.id,
    required this.tache1,
    required this.tache2,
    required this.tache3,
  });

  factory EECombinaison.fromJson(Map<String, dynamic> json) {
    return EECombinaison(
      id: json['id'] ?? '',
      tache1: EETache.fromJson(json['tache1'] ?? {}),
      tache2: EETache.fromJson(json['tache2'] ?? {}),
      tache3: EETache.fromJson(json['tache3'] ?? {}),
    );
  }
}

class EEMonth {
  final String id;
  final String examTitle;
  final List<EECombinaison> combinaisons;

  const EEMonth({
    required this.id,
    required this.examTitle,
    required this.combinaisons,
  });

  factory EEMonth.fromJson(Map<String, dynamic> json) {
    final combList =
        (json['combinaisons'] as List?)
            ?.map((c) => EECombinaison.fromJson(c))
            .toList() ??
        [];

    return EEMonth(
      id: json['id'] ?? '',
      examTitle: json['examTitle'] ?? '',
      combinaisons: combList,
    );
  }
}

class EEExamen {
  final String description;
  final List<EEMonth> months;

  const EEExamen({required this.description, required this.months});

  factory EEExamen.fromJson(Map<String, dynamic> json) {
    final monthsList =
        (json['months'] as List?)?.map((m) => EEMonth.fromJson(m)).toList() ??
        [];

    return EEExamen(description: json['description'] ?? '', months: monthsList);
  }

  static Future<EEExamen> loadFromAssets() async {
    try {
      final indexJson = await rootBundle.loadString(
        'assets/data/ee/index.json',
      );
      final indexData = jsonDecode(indexJson) as Map<String, dynamic>;
      final description = indexData['description'] as String? ?? '';
      final monthRefs = indexData['months'] as List<dynamic>? ?? [];

      final months = <EEMonth>[];
      for (final ref in monthRefs) {
        final id = ref['id'] as String?;
        if (id == null) continue;
        final monthJson = await rootBundle.loadString(
          'assets/data/ee/$id.json',
        );
        final monthData = jsonDecode(monthJson) as Map<String, dynamic>;
        months.add(EEMonth.fromJson(monthData));
      }

      return EEExamen(description: description, months: months);
    } catch (e) {
      throw Exception('Failed to load exam data: $e');
    }
  }
}
