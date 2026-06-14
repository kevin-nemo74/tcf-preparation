import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import '../models/eo_examen.dart';
import '../models/eo_month.dart';
import 'eo_month_screen.dart';

class EOHomeScreen extends StatefulWidget {
  const EOHomeScreen({super.key});

  @override
  State<EOHomeScreen> createState() => _EOHomeScreenState();
}

class _EOHomeScreenState extends State<EOHomeScreen> {
  EOExamen? _examen;
  bool _loading = true;
  String? _error;
  int _selectedTache = 2;

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  Future<void> _loadExam() async {
    setState(() { _loading = true; _error = null; });
    try {
      final examen =
          await EOExamen.loadFromAssets(tache: _selectedTache);
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

  void _switchTache(int tache) {
    if (tache == _selectedTache) return;
    setState(() => _selectedTache = tache);
    _loadExam();
  }

  void _openMonth(EOMonth month) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EOMonthScreen(month: month)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expression Orale'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: 200,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 2, label: Text('Tâche 2')),
                  ButtonSegment(value: 3, label: Text('Tâche 3')),
                ],
                selected: {_selectedTache},
                onSelectionChanged: (v) => _switchTache(v.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
        ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroCard(
            totalSujets: _examen!.totalSujets,
            tache: _selectedTache,
          ),
          const SizedBox(height: 24),
          Text(
            'Choisir par mois',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ..._examen!.months.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MonthCard(
                month: m,
                onTap: () => _openMonth(m),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow.withValues(alpha: 0.5),
            border: Border(
              bottom: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.record_voice_over_rounded,
                  color: cs.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TCF Canada',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: cs.primary,
                    ),
                  ),
                  Text(
                    'Expression Orale',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 2, label: Text('Tâche 2')),
                    ButtonSegment(value: 3, label: Text('Tâche 3')),
                  ],
                  selected: {_selectedTache},
                  onSelectionChanged: (v) => _switchTache(v.first),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _examen!.months
                  .map(
                    (m) => SizedBox(
                      width: 280,
                      child: _MonthCard(
                        month: m,
                        onTap: () => _openMonth(m),
                        compact: true,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int totalSujets;
  final int tache;

  const _HeroCard({required this.totalSujets, required this.tache});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
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
              Icons.record_voice_over_rounded,
              color: cs.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'TCF Canada',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: cs.primary,
            ),
          ),
          Text(
            'Expression Orale — Tâche $tache',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$totalSujets sujets',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: cs.primary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final EOMonth month;
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
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
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
                        '${month.parties.length} parties',
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
                  '${month.parties.length}',
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
