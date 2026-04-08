import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/widgets/responsive_frame.dart';
import '../models/ee_combinaison.dart';
import '../models/ee_evaluation.dart';

class EEResultScreen extends StatelessWidget {
  final EECombinaison combinaison;
  final EECombinaisonEvaluation evaluation;

  const EEResultScreen({
    super.key,
    required this.combinaison,
    required this.evaluation,
  });

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
              if (evaluation.generalFeedback.isNotEmpty)
                _buildGeneralFeedback(context),
              if (evaluation.generalFeedback.isNotEmpty)
                const SizedBox(height: 20),
              if (evaluation.suggestions.isNotEmpty) _buildSuggestions(context),
              if (evaluation.suggestions.isNotEmpty) const SizedBox(height: 20),
              if (evaluation.corrections.isNotEmpty) _buildCorrections(context),
              if (evaluation.corrections.isNotEmpty) const SizedBox(height: 20),
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
    final score = evaluation.finalScoreOutOf20;
    final color = score >= 14
        ? Colors.green
        : score >= 10
        ? Colors.orange
        : Colors.red;

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
          Container(
            width: 120,
            height: 120,
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
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  Text(
                    '/20',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
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
            'Score total : ${evaluation.calculatedOverallScore.toInt()}/100 (${evaluation.taches.length} tâches évaluées)',
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
          ],
        ),
        const SizedBox(height: 12),
        _TacheResultCard(
          label: 'Tâche 1',
          title: combinaison.tache1.title,
          score: evaluation.taches.isNotEmpty ? evaluation.taches[0].score : 0,
          maxScore: 25,
          wordCount: evaluation.wordCounts['tache1'] ?? 0,
          expectedWords:
              '${combinaison.tache1.minWords}-${combinaison.tache1.maxWords}',
          feedback: evaluation.taches.isNotEmpty
              ? evaluation.taches[0].feedback
              : '',
        ),
        const SizedBox(height: 10),
        _TacheResultCard(
          label: 'Tâche 2',
          title: combinaison.tache2.title,
          score: evaluation.taches.length > 1 ? evaluation.taches[1].score : 0,
          maxScore: 25,
          wordCount: evaluation.wordCounts['tache2'] ?? 0,
          expectedWords:
              '${combinaison.tache2.minWords}-${combinaison.tache2.maxWords}',
          feedback: evaluation.taches.length > 1
              ? evaluation.taches[1].feedback
              : '',
        ),
        const SizedBox(height: 10),
        _TacheResultCard(
          label: 'Tâche 3',
          title: combinaison.tache3.title,
          score: evaluation.taches.length > 2 ? evaluation.taches[2].score : 0,
          maxScore: 25,
          wordCount: evaluation.wordCounts['tache3'] ?? 0,
          expectedWords:
              '${combinaison.tache3.minWords}-${combinaison.tache3.maxWords}',
          feedback: evaluation.taches.length > 2
              ? evaluation.taches[2].feedback
              : '',
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
            evaluation.generalFeedback,
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
            evaluation.suggestions,
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
            evaluation.corrections,
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
