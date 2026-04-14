import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/widgets/responsive_frame.dart';
import '../models/ee_attempt.dart';
import '../models/ee_combinaison.dart';
import '../models/ee_evaluation.dart';

class EEResultScreen extends StatefulWidget {
  final EECombinaison combinaison;
  final EECombinaisonEvaluation evaluation;
  final EEAttempt? attempt;

  const EEResultScreen({
    super.key,
    required this.combinaison,
    required this.evaluation,
    this.attempt,
  });

  @override
  State<EEResultScreen> createState() => _EEResultScreenState();
}

class _EEResultScreenState extends State<EEResultScreen> {
  final Set<int> _expandedSections = {0, 1, 2};
  bool _allExpanded = true;

  bool get _hasStoredAttempt => widget.attempt != null;

  void _toggleSection(int index) {
    setState(() {
      if (_expandedSections.contains(index)) {
        _expandedSections.remove(index);
      } else {
        _expandedSections.add(index);
      }
    });
  }

  void _toggleAllSections() {
    setState(() {
      _allExpanded = !_allExpanded;
      if (_allExpanded) {
        _expandedSections.addAll({0, 1, 2});
      } else {
        _expandedSections.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Résultat',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          if (_hasStoredAttempt)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: const Icon(Icons.history, size: 16),
                label: Text(
                  _formatDate(widget.attempt!.createdAt),
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
        ],
      ),
      body: ResponsiveFrame(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScoreOverview(context),
              const SizedBox(height: 20),
              _buildTacheResults(context),
              const SizedBox(height: 20),
              if (widget.evaluation.generalFeedback.isNotEmpty) ...[
                _buildGeneralFeedback(context),
                const SizedBox(height: 20),
              ],
              if (widget.evaluation.suggestions.isNotEmpty) ...[
                _buildSuggestions(context),
                const SizedBox(height: 20),
              ],
              if (widget.evaluation.corrections.isNotEmpty) ...[
                _buildCorrections(context),
                const SizedBox(height: 20),
              ],
              _buildActions(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildScoreOverview(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final score = widget.evaluation.finalScoreOutOf20;
    final color = _getLevelColor(score);
    final nclcLevel = _getNCLCLevel(score);
    final cefrLevel = _getCEFRLevel(score);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.4),
            cs.tertiaryContainer.withValues(alpha: 0.25),
            cs.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color, width: 4),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        score.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                      Text(
                        '/20',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildLevelBadge('CEFR $cefrLevel', color),
                      const SizedBox(width: 8),
                      _buildLevelBadge('NCLC $nclcLevel', color),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'NCLC $nclcLevel',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  'Canada',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getScoreLabel(score),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score total : ${widget.evaluation.calculatedOverallScore.toInt()}/100 (${widget.evaluation.taches.length} tâches évaluées)',
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  String _getScoreLabel(double score) {
    if (score >= 16) return 'Excellent !';
    if (score >= 14) return 'Très bien';
    if (score >= 12) return 'Bien';
    if (score >= 10) return 'Passable';
    if (score >= 8) return 'À améliorer';
    return 'Besoin de travail';
  }

  Widget _buildTacheResults(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_rounded, size: 20, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              'Résultats par tâche',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: cs.onSurface,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _toggleAllSections,
              icon: Icon(
                _allExpanded ? Icons.unfold_less : Icons.unfold_more,
                size: 18,
              ),
              label: Text(_allExpanded ? 'Tout réduire' : 'Tout déplier'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TacheResultCard(
          label: 'Tâche 1',
          title: widget.combinaison.tache1.title,
          score: widget.evaluation.taches.isNotEmpty
              ? widget.evaluation.taches[0].score
              : 0,
          maxScore: 25,
          wordCount: widget.evaluation.wordCounts['tache1'] ?? 0,
          expectedWords:
              '${widget.combinaison.tache1.minWords}-${widget.combinaison.tache1.maxWords}',
          feedback: widget.evaluation.taches.isNotEmpty
              ? widget.evaluation.taches[0].feedback
              : '',
          userAnswer: widget.attempt?.tache1Answer,
          corrections: widget.evaluation.corrections,
          isExpanded: _expandedSections.contains(0),
          onToggle: () => _toggleSection(0),
        ),
        const SizedBox(height: 8),
        _TacheResultCard(
          label: 'Tâche 2',
          title: widget.combinaison.tache2.title,
          score: widget.evaluation.taches.length > 1
              ? widget.evaluation.taches[1].score
              : 0,
          maxScore: 25,
          wordCount: widget.evaluation.wordCounts['tache2'] ?? 0,
          expectedWords:
              '${widget.combinaison.tache2.minWords}-${widget.combinaison.tache2.maxWords}',
          feedback: widget.evaluation.taches.length > 1
              ? widget.evaluation.taches[1].feedback
              : '',
          userAnswer: widget.attempt?.tache2Answer,
          corrections: widget.evaluation.corrections,
          isExpanded: _expandedSections.contains(1),
          onToggle: () => _toggleSection(1),
        ),
        const SizedBox(height: 8),
        _TacheResultCard(
          label: 'Tâche 3',
          title: widget.combinaison.tache3.title,
          score: widget.evaluation.taches.length > 2
              ? widget.evaluation.taches[2].score
              : 0,
          maxScore: 25,
          wordCount: widget.evaluation.wordCounts['tache3'] ?? 0,
          expectedWords:
              '${widget.combinaison.tache3.minWords}-${widget.combinaison.tache3.maxWords}',
          feedback: widget.evaluation.taches.length > 2
              ? widget.evaluation.taches[2].feedback
              : '',
          userAnswer: widget.attempt?.tache3Answer,
          corrections: widget.evaluation.corrections,
          isExpanded: _expandedSections.contains(2),
          onToggle: () => _toggleSection(2),
        ),
      ],
    );
  }

  Widget _buildGeneralFeedback(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Commentaire général',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.evaluation.generalFeedback,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final suggestions = widget.evaluation.suggestions
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.primaryContainer.withValues(alpha: 0.15),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Suggestions d\'amélioration',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.map(
            (suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      suggestion.trim(),
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrections(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final corrections = widget.evaluation.corrections
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.errorContainer.withValues(alpha: 0.15),
        border: Border.all(color: cs.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_rounded, size: 20, color: cs.error),
              const SizedBox(width: 8),
              Text(
                'Corrections',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...corrections.map(
            (correction) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: cs.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      correction.trim(),
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Retour'),
          ),
        ),
      ],
    );
  }

  int _getNCLCLevel(double score) {
    if (score >= 16) return 10;
    if (score >= 14) return 9;
    if (score >= 12) return 8;
    if (score >= 10) return 7;
    if (score >= 7) return 6;
    if (score >= 6) return 5;
    if (score >= 4) return 4;
    return 4;
  }

  String _getCEFRLevel(double score) {
    if (score >= 16) return 'C2';
    if (score >= 14) return 'C1';
    if (score >= 12) return 'B2';
    if (score >= 10) return 'B2';
    if (score >= 7) return 'B1';
    if (score >= 6) return 'B1';
    if (score >= 4) return 'A2';
    return 'A1';
  }

  Color _getLevelColor(double score) {
    if (score >= 14) return Colors.green;
    if (score >= 10) return Colors.orange;
    return Colors.red;
  }
}

class _TacheResultCard extends StatelessWidget {
  final String label;
  final String title;
  final double score;
  final double maxScore;
  final int wordCount;
  final String expectedWords;
  final String feedback;
  final String? userAnswer;
  final String corrections;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _TacheResultCard({
    required this.label,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.wordCount,
    required this.expectedWords,
    required this.feedback,
    this.userAnswer,
    required this.corrections,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percentage = (score / maxScore) * 100;
    final color = percentage >= 70
        ? Colors.green
        : percentage >= 50
        ? Colors.orange
        : Colors.red;
    final hasUserAnswer = userAnswer != null && userAnswer!.isNotEmpty;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${score.toInt()}/${maxScore.toInt()}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: cs.primary,
                    ),
                  ],
                ),
              ),
              if (isExpanded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
                          backgroundColor: color.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.text_fields_rounded,
                            size: 14,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$wordCount mots (attendu: $expectedWords)',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (hasUserAnswer) ...[
                        const SizedBox(height: 14),
                        _HighlightedAnswerView(
                          answer: userAnswer!,
                          corrections: corrections,
                        ),
                      ],
                      if (feedback.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.feedback_rounded,
                                    size: 14,
                                    color: cs.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Feedback',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                feedback,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.75),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightedAnswerView extends StatelessWidget {
  final String answer;
  final String corrections;

  const _HighlightedAnswerView({
    required this.answer,
    required this.corrections,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final errorWords = _extractErrorWords(corrections);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_note_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  'Votre réponse',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText.rich(
                    TextSpan(children: _buildHighlightedSpans(errorWords, cs)),
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                  ),
                ),
                if (errorWords.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Mots à améliorer:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cs.error,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: errorWords.take(8).map((word) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.errorContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: cs.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          word,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cs.error,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _extractErrorWords(String corrections) {
    if (corrections.isEmpty) return [];

    final words = <String>{};

    final quotedPatterns = [
      RegExp(r'[""""]([^""""]+)["""]'),
      RegExp(r"«\s*([^»]+)\s*»"),
      RegExp(r"'\s*([^']+)\s*'"),
      RegExp(r'""\s*([^""]+)\s*""'),
    ];

    for (final pattern in quotedPatterns) {
      final matches = pattern.allMatches(corrections);
      for (final match in matches) {
        final word = match.group(1)?.trim();
        if (word != null && word.length >= 3) {
          final cleanWord = word.replaceAll(
            RegExp(r'^[^\wÀ-ÿ]+|[^\wÀ-ÿ]+$'),
            '',
          );
          if (cleanWord.isNotEmpty && !_isCommonWord(cleanWord)) {
            words.add(cleanWord.toLowerCase());
          }
        }
      }
    }

    final errorPhrases = RegExp(
      r'(?:devrait|erreur|incorrect|mauvais|faute|faux|au lieu de|instead of|should be|incorrect|wrong)\s*[:\-]?\s*[""""]([^""""]+)["""]',
      caseSensitive: false,
    );
    final phraseMatches = errorPhrases.allMatches(corrections);
    for (final match in phraseMatches) {
      final word = match.group(1)?.trim();
      if (word != null && word.length >= 3) {
        final cleanWord = word.replaceAll(RegExp(r'^[^\wÀ-ÿ]+|[^\wÀ-ÿ]+$'), '');
        if (cleanWord.isNotEmpty && !_isCommonWord(cleanWord)) {
          words.add(cleanWord.toLowerCase());
        }
      }
    }

    return words.toList();
  }

  bool _isCommonWord(String word) {
    final commonWords = {
      'the',
      'and',
      'for',
      'are',
      'but',
      'not',
      'you',
      'all',
      'can',
      'had',
      'her',
      'was',
      'one',
      'our',
      'out',
      'day',
      'get',
      'has',
      'him',
      'his',
      'how',
      'its',
      'may',
      'new',
      'now',
      'old',
      'see',
      'two',
      'way',
      'who',
      'boy',
      'did',
      'own',
      'say',
      'she',
      'too',
      'use',
      'les',
      'des',
      'une',
      'est',
      'que',
      'qui',
      'dans',
      'pour',
      'nous',
      'vous',
      'avec',
      'sur',
      'this',
      'with',
      'have',
      'from',
      'they',
      'been',
      'that',
      'will',
      'your',
      'some',
      'more',
      'when',
      'time',
      'very',
      'what',
      'also',
      'ete',
      'sont',
      'par',
      'fait',
      'plus',
      'bien',
      'tres',
      'bien',
    };
    return commonWords.contains(word.toLowerCase());
  }

  List<TextSpan> _buildHighlightedSpans(
    List<String> errorWords,
    ColorScheme cs,
  ) {
    if (answer.isEmpty) return [const TextSpan(text: '')];
    if (errorWords.isEmpty) {
      return [TextSpan(text: answer)];
    }

    final spans = <TextSpan>[];
    final words = answer.split(RegExp(r'(\s+)'));

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      final wordLower = word.toLowerCase().replaceAll(RegExp(r'[^\wÀ-ÿ]'), '');

      final isError = errorWords.contains(wordLower);

      spans.add(
        TextSpan(
          text: word + (i < words.length - 1 ? ' ' : ''),
          style: isError
              ? TextStyle(
                  backgroundColor: cs.errorContainer.withValues(alpha: 0.5),
                  decoration: TextDecoration.underline,
                  decorationColor: cs.error,
                  decorationThickness: 2,
                )
              : null,
        ),
      );
    }

    return spans;
  }
}
