import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tcf_canada_preparation/core/widgets/responsive_frame.dart';
import '../models/ee_combinaison.dart';
import '../models/ee_evaluation.dart';

class EEResultScreen extends StatefulWidget {
  final EECombinaison combinaison;
  final EECombinaisonEvaluation evaluation;

  const EEResultScreen({
    super.key,
    required this.combinaison,
    required this.evaluation,
  });

  @override
  State<EEResultScreen> createState() => _EEResultScreenState();
}

class _EEResultScreenState extends State<EEResultScreen> {
  final Set<int> _expandedSections = {0, 1, 2};
  bool _allSectionsExpanded = true;

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
      _allSectionsExpanded = !_allSectionsExpanded;
      if (_allSectionsExpanded) {
        _expandedSections.addAll({0, 1, 2});
      } else {
        _expandedSections.clear();
      }
    });
  }

  void _copyAnswers() {
    final text =
        '''
Tâche 1: ${widget.combinaison.tache1.title}
Réponse: ${widget.evaluation.wordCounts['tache1Answer'] ?? 'N/A'}

Tâche 2: ${widget.combinaison.tache2.title}
Réponse: ${widget.evaluation.wordCounts['tache2Answer'] ?? 'N/A'}

Tâche 3: ${widget.combinaison.tache3.title}
Réponse: ${widget.evaluation.wordCounts['tache3Answer'] ?? 'N/A'}

Score: ${widget.evaluation.finalScoreOutOf20.toStringAsFixed(1)}/20
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Réponses copiées!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
              if (widget.evaluation.generalFeedback.isNotEmpty)
                _buildGeneralFeedback(context),
              if (widget.evaluation.generalFeedback.isNotEmpty)
                const SizedBox(height: 20),
              if (widget.evaluation.suggestions.isNotEmpty)
                _buildSuggestions(context),
              if (widget.evaluation.suggestions.isNotEmpty)
                const SizedBox(height: 20),
              if (widget.evaluation.corrections.isNotEmpty)
                _buildCorrections(context),
              if (widget.evaluation.corrections.isNotEmpty)
                const SizedBox(height: 20),
              _buildActions(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          cefrLevel,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                        Text(
                          'CEFR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
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
                ],
              ),
            ],
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

  String _getScoreLabel(double score) {
    if (score >= 16) return 'Excellent !';
    if (score >= 14) return 'Très bien';
    if (score >= 12) return 'Bien';
    if (score >= 10) return 'Passable';
    if (score >= 8) return 'À améliorer';
    return 'Besoin de travail';
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
                _allSectionsExpanded ? Icons.unfold_less : Icons.unfold_more,
                size: 18,
              ),
              label: Text(
                _allSectionsExpanded ? 'Tout réduire' : 'Tout déplier',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _CollapsibleTacheCard(
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
          isExpanded: _expandedSections.contains(0),
          onToggle: () => _toggleSection(0),
        ),
        const SizedBox(height: 8),
        _CollapsibleTacheCard(
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
          isExpanded: _expandedSections.contains(1),
          onToggle: () => _toggleSection(1),
        ),
        const SizedBox(height: 8),
        _CollapsibleTacheCard(
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
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.evaluation.generalFeedback,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.3),
            cs.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.06),
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
              Icon(Icons.lightbulb_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Suggestions d\'amélioration',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.evaluation.suggestions,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrections(BuildContext context) {
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
              Icon(Icons.edit_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Corrections',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.evaluation.corrections,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.6,
              fontSize: 14,
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
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Recommencer'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text('Accueil'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
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

  const _TacheResultCard({
    required this.label,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.wordCount,
    required this.expectedWords,
    required this.feedback,
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
            ],
          ),
          const SizedBox(height: 10),
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
          if (feedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              feedback,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CollapsibleTacheCard extends StatelessWidget {
  final String label;
  final String title;
  final double score;
  final double maxScore;
  final int wordCount;
  final String expectedWords;
  final String feedback;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _CollapsibleTacheCard({
    required this.label,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.wordCount,
    required this.expectedWords,
    required this.feedback,
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
                Padding(
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
                      if (feedback.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          feedback,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
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
