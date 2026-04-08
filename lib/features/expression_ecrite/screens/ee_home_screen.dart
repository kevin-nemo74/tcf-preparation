import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/widgets/responsive_frame.dart';
import '../models/ee_combinaison.dart';
import 'ee_editor_screen.dart';

class EEHomeScreen extends StatefulWidget {
  const EEHomeScreen({super.key});

  @override
  State<EEHomeScreen> createState() => _EEHomeScreenState();
}

class _EEHomeScreenState extends State<EEHomeScreen> {
  EEExamen? _examen;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  Future<void> _loadExam() async {
    try {
      final examen = await EEExamen.loadFromAssets();
      setState(() {
        _examen = examen;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expression Écrite',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: ResponsiveFrame(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(fontWeight: FontWeight.w800, color: cs.error),
          ),
          const SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: _loadExam, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildExamInfo(context),
          const SizedBox(height: 20),
          Text(
            '${_examen!.combinaisons.length} combinaisons disponibles',
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _examen!.combinaisons.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final comb = _examen!.combinaisons[index];
              return _CombinaisonCard(
                combinaison: comb,
                index: index,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EEEditorScreen(combinaison: comb),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.6),
            cs.tertiaryContainer.withValues(alpha: 0.35),
            cs.secondaryContainer.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.edit_note_rounded, color: cs.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _examen!.examTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _examen!.description,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamInfo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
              Icon(Icons.info_outline_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Format de l\'épreuve',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.looks_one_rounded,
            label: 'Tâche 1',
            value: 'Message : 60-120 mots',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.looks_two_rounded,
            label: 'Tâche 2',
            value: 'Blog : 120-150 mots',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.looks_3_rounded,
            label: 'Tâche 3',
            value: 'Synthèse + Opinion : 120-180 mots',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.assessment_rounded, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Score final : /20 (évaluation IA des 3 tâches)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          '$label : ',
          style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class _CombinaisonCard extends StatelessWidget {
  final EECombinaison combinaison;
  final int index;
  final VoidCallback onTap;

  const _CombinaisonCard({
    required this.combinaison,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: cs.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded, size: 20, color: cs.primary),
              ],
            ),
            const SizedBox(height: 12),
            _TachePreview(
              label: 'T1',
              title: combinaison.tache1.title,
              words:
                  '${combinaison.tache1.minWords}-${combinaison.tache1.maxWords}',
            ),
            const SizedBox(height: 8),
            _TachePreview(
              label: 'T2',
              title: combinaison.tache2.title,
              words:
                  '${combinaison.tache2.minWords}-${combinaison.tache2.maxWords}',
            ),
            const SizedBox(height: 8),
            _TachePreview(
              label: 'T3',
              title: combinaison.tache3.title,
              words:
                  '${combinaison.tache3.minWords}-${combinaison.tache3.maxWords}',
              hasDocs: combinaison.tache3.hasDocuments,
            ),
          ],
        ),
      ),
    );
  }
}

class _TachePreview extends StatelessWidget {
  final String label;
  final String title;
  final String words;
  final bool hasDocs;

  const _TachePreview({
    required this.label,
    required this.title,
    required this.words,
    this.hasDocs = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: cs.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$words mots',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        if (hasDocs) ...[
          const SizedBox(width: 6),
          Icon(
            Icons.article_outlined,
            size: 14,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ],
      ],
    );
  }
}
