import 'dart:convert';
import 'package:flutter/services.dart';
import 'eo_month.dart';

class EOExamen {
  final String description;
  final List<EOMonth> months;

  const EOExamen({required this.description, required this.months});

  factory EOExamen.fromJson(Map<String, dynamic> json) {
    return EOExamen(
      description: json['description'] ?? '',
      months: (json['months'] as List?)
              ?.map((m) => EOMonth.fromJson(m))
              .toList() ??
          [],
    );
  }

  static Future<EOExamen> loadFromAssets() async {
    try {
      final indexJson =
          await rootBundle.loadString('assets/data/eo/index.json');
      final indexData = jsonDecode(indexJson) as Map<String, dynamic>;
      final monthRefs = indexData['months'] as List<dynamic>? ?? [];

      final months = <EOMonth>[];
      for (final ref in monthRefs) {
        final id = ref['id'] as String?;
        if (id == null) continue;
        final monthJson =
            await rootBundle.loadString('assets/data/eo/$id.json');
        final monthData = jsonDecode(monthJson) as Map<String, dynamic>;
        months.add(EOMonth.fromJson(monthData));
      }

      return EOExamen(
        description: indexData['description'] as String? ?? '',
        months: months,
      );
    } catch (e) {
      throw Exception('Failed to load EO exam data: $e');
    }
  }

  int get totalParties => months.fold(0, (sum, m) => sum + m.parties.length);

  int get totalSujets => months.fold(0, (sum, m) => sum + m.totalSujets);
}
