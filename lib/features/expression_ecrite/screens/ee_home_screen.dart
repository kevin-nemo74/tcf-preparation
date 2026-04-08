import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
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

  void _startExercise([EECombinaison? comb]) {
    if (_examen == null) return;

    final exercise = comb ?? _examen!.months.first.combinaisons.first;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EEEditorScreen(combinaison: exercise)),
    );
  }

  void _selectMonth(EEMonth month) {
    showDialog(
      context: context,
      builder: (context) => _MonthDialog(
        month: month,
        onSelect: (comb) {
          Navigator.pop(context);
          _startExercise(comb);
        },
      ),
    );
  }

  void _showAllExercises() {
    if (_examen == null) return;
    showDialog(
      context: context,
      builder: (context) => _AllExercisesDialog(
        examen: _examen!,
        onSelect: (comb) {
          Navigator.pop(context);
          _startExercise(comb);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expression Écrite'),
        centerTitle: true,
        actions: [
          if (_examen != null)
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              onPressed: _showAllExercises,
              tooltip: 'Tous les exercices',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : Responsive.isTabletWeb(context)
          ? _buildWebLayout()
          : _buildMobileLayout(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: _loadExam, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    final totalComb = _examen!.months.fold<int>(
      0,
      (sum, m) => sum + m.combinaisons.length,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroCard(totalExercises: totalComb, onStart: () => _startExercise()),
          const SizedBox(height: 24),
          Text(
            'Choisir par mois',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ..._examen!.months.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MonthCard(month: m, onTap: () => _selectMonth(m)),
            ),
          ),
          const SizedBox(height: 16),
          const _FormatCard(),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    final cs = Theme.of(context).colorScheme;
    final totalComb = _examen!.months.fold<int>(
      0,
      (sum, m) => sum + m.combinaisons.length,
    );

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCard(
                        totalExercises: totalComb,
                        onStart: () => _startExercise(),
                        large: true,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Tous les exercices',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _examen!.months
                            .expand(
                              (m) => m.combinaisons
                                  .take(4)
                                  .map(
                                    (c) => SizedBox(
                                      width: 280,
                                      child: _ExerciseCard(
                                        monthName: m.examTitle,
                                        index: m.combinaisons.indexOf(c),
                                        combinaison: c,
                                        onTap: () => _startExercise(c),
                                      ),
                                    ),
                                  ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: Border(
                    left: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Par mois',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      ..._examen!.months.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MonthCard(
                            month: m,
                            onTap: () => _selectMonth(m),
                            compact: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _FormatCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int totalExercises;
  final VoidCallback onStart;
  final bool large;

  const _HeroCard({
    required this.totalExercises,
    required this.onStart,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(large ? 32 : 24),
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
            padding: EdgeInsets.all(large ? 24 : 16),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: cs.primary,
              size: large ? 56 : 40,
            ),
          ),
          SizedBox(height: large ? 20 : 16),
          Text(
            'TCF Canada',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: large ? 28 : 22,
              color: cs.primary,
            ),
          ),
          Text(
            'Expression Écrite',
            style: TextStyle(
              fontSize: large ? 18 : 14,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: large ? 16 : 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$totalExercises exercices',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: cs.primary,
                fontSize: large ? 16 : 13,
              ),
            ),
          ),
          SizedBox(height: large ? 24 : 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(large ? 'Commencer maintenant' : 'Commencer'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: large ? 18 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final EEMonth month;
  final VoidCallback onTap;
  final bool compact;

  const _MonthCard({
    required this.month,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 8 : 10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: cs.primary,
                  size: compact ? 18 : 22,
                ),
              ),
              SizedBox(width: compact ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      month.examTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 14 : 15,
                      ),
                    ),
                    if (!compact)
                      Text(
                        '${month.combinaisons.length} exercices',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 10,
                  vertical: compact ? 4 : 5,
                ),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${month.combinaisons.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                    fontSize: compact ? 12 : 14,
                  ),
                ),
              ),
              SizedBox(width: compact ? 6 : 8),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.primary,
                size: compact ? 18 : 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String monthName;
  final int index;
  final EECombinaison combinaison;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.monthName,
    required this.index,
    required this.combinaison,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: cs.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      monthName,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                combinaison.tache1.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.text_fields_rounded, size: 14, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${combinaison.tache1.minWords}-${combinaison.tache1.maxWords} mots',
                    style: TextStyle(fontSize: 11, color: cs.primary),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: cs.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthDialog extends StatelessWidget {
  final EEMonth month;
  final Function(EECombinaison) onSelect;

  const _MonthDialog({required this.month, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      month.examTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: month.combinaisons.length,
                itemBuilder: (context, index) {
                  final comb = month.combinaisons[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => onSelect(comb),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comb.tache1.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cs.primaryContainer
                                                .withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            '${comb.tache1.minWords}-${comb.tache1.maxWords} mots',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: cs.primary,
                                            ),
                                          ),
                                        ),
                                        if (comb.tache3.hasDocuments) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.article_outlined,
                                            size: 14,
                                            color: cs.secondary,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: cs.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllExercisesDialog extends StatelessWidget {
  final EEExamen examen;
  final Function(EECombinaison) onSelect;

  const _AllExercisesDialog({required this.examen, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.grid_view_rounded, color: cs.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tous les exercices',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: examen.months.length,
                itemBuilder: (context, monthIndex) {
                  final month = examen.months[monthIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              month.examTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...month.combinaisons.map((comb) {
                        final idx = month.combinaisons.indexOf(comb);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Material(
                            color: cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () => onSelect(comb),
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: cs.primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${idx + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: cs.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        comb.tache1.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${comb.tache1.minWords}-${comb.tache1.maxWords}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Format',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FormatRow(
            icon: Icons.looks_one_rounded,
            label: 'Tâche 1',
            desc: 'Message 60-120 mots',
          ),
          const SizedBox(height: 8),
          _FormatRow(
            icon: Icons.looks_two_rounded,
            label: 'Tâche 2',
            desc: 'Blog 120-150 mots',
          ),
          const SizedBox(height: 8),
          _FormatRow(
            icon: Icons.looks_3_rounded,
            label: 'Tâche 3',
            desc: 'Synthèse 120-180 mots',
          ),
          const Divider(height: 20),
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 16, color: cs.tertiary),
              const SizedBox(width: 6),
              Text(
                'Score /20 (IA)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.tertiary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;

  const _FormatRow({
    required this.icon,
    required this.label,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        Expanded(
          child: Text(
            desc,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
