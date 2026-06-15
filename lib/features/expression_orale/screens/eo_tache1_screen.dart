import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'eo_practice_screen.dart';

class EOTache1Screen extends StatefulWidget {
  const EOTache1Screen({super.key});

  @override
  State<EOTache1Screen> createState() => _EOTache1ScreenState();
}

class _EOTache1ScreenState extends State<EOTache1Screen> {
  List<String> _questions = [];
  String _current = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final json =
        await rootBundle.loadString('assets/data/eo/tache1.json');
    final data = jsonDecode(json) as Map<String, dynamic>;
    final qs = List<String>.from(data['questions'] as List);
    setState(() {
      _questions = qs;
      _current = qs[Random().nextInt(qs.length)];
      _loading = false;
    });
  }

  void _pickNew() {
    if (_questions.isEmpty) return;
    String next;
    do {
      next = _questions[Random().nextInt(_questions.length)];
    } while (next == _current && _questions.length > 1);
    setState(() => _current = next);
  }

  void _practice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EOPracticeScreen(
          sujet: _current,
          tache: 1,
          maxDurationSeconds: 120,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primaryContainer,
                  cs.tertiaryContainer.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: cs.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tâche 1 — Entretien dirigé',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2 minutes — Sans préparation',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_questions.length} questions',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.quiz_outlined, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Question',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.shuffle_rounded, size: 20),
                      onPressed: _pickNew,
                      tooltip: 'Question aléatoire',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _current,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _practice,
              icon: const Icon(Icons.mic_rounded),
              label: const Text(
                'S\'entraîner',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'L\'examinateur vous posera une question.\nRépondez de façon naturelle et développée (3-4 phrases minimum).',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
