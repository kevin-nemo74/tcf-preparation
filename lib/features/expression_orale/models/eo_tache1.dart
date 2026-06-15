import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class EOTache1 {
  static List<String> _questions = [];

  static Future<void> load() async {
    if (_questions.isNotEmpty) return;
    final json = await rootBundle.loadString('assets/data/eo/tache1.json');
    final data = jsonDecode(json) as Map<String, dynamic>;
    _questions = List<String>.from(data['questions'] as List);
  }

  static String random() {
    if (_questions.isEmpty) return '';
    return _questions[Random().nextInt(_questions.length)];
  }

  static int get total => _questions.length;
}
