import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/widgets/responsive_frame.dart';
import '../models/ee_combinaison.dart';
import '../services/openrouter_service.dart';
import 'ee_result_screen.dart';

class EEEditorScreen extends StatefulWidget {
  final EECombinaison combinaison;

  const EEEditorScreen({super.key, required this.combinaison});

  @override
  State<EEEditorScreen> createState() => _EEEditorScreenState();
}

class _EEEditorScreenState extends State<EEEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tache1Controller = TextEditingController();
  final _tache2Controller = TextEditingController();
  final _tache3Controller = TextEditingController();
  bool _evaluating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tache1Controller.dispose();
    _tache2Controller.dispose();
    _tache3Controller.dispose();
    super.dispose();
  }

  int _wordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  bool _withinRange(int count, int min, int max) {
    return count >= min && count <= max;
  }

  Future<void> _evaluate() async {
    final t1Words = _wordCount(_tache1Controller.text);
    final t2Words = _wordCount(_tache2Controller.text);
    final t3Words = _wordCount(_tache3Controller.text);

    if (t1Words < widget.combinaison.tache1.minWords) {
      setState(() {
        _error =
            'Tâche 1 : minimum ${widget.combinaison.tache1.minWords} mots requis (actuellement $t1Words)';
      });
      _tabController.animateTo(0);
      return;
    }

    if (t2Words < widget.combinaison.tache2.minWords) {
      setState(() {
        _error =
            'Tâche 2 : minimum ${widget.combinaison.tache2.minWords} mots requis (actuellement $t2Words)';
      });
      _tabController.animateTo(1);
      return;
    }

    if (t3Words < widget.combinaison.tache3.minWords) {
      setState(() {
        _error =
            'Tâche 3 : minimum ${widget.combinaison.tache3.minWords} mots requis (actuellement $t3Words)';
      });
      _tabController.animateTo(2);
      return;
    }

    setState(() {
      _evaluating = true;
      _error = null;
    });

    try {
      final evaluation = await OpenRouterService.evaluate(
        tache1Instruction: widget.combinaison.tache1.instruction,
        tache1MinWords: widget.combinaison.tache1.minWords,
        tache1MaxWords: widget.combinaison.tache1.maxWords,
        tache1Answer: _tache1Controller.text,
        tache2Instruction: widget.combinaison.tache2.instruction,
        tache2MinWords: widget.combinaison.tache2.minWords,
        tache2MaxWords: widget.combinaison.tache2.maxWords,
        tache2Answer: _tache2Controller.text,
        tache3Instruction: widget.combinaison.tache3.instruction,
        tache3MinWords: widget.combinaison.tache3.minWords,
        tache3MaxWords: widget.combinaison.tache3.maxWords,
        tache3Answer: _tache3Controller.text,
        tache3DocumentA: widget.combinaison.tache3.documentA,
        tache3DocumentB: widget.combinaison.tache3.documentB,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EEResultScreen(
            combinaison: widget.combinaison,
            evaluation: evaluation,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _evaluating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Examen',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurface.withValues(alpha: 0.6),
          indicatorColor: cs.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Tâche 1'),
            Tab(text: 'Tâche 2'),
            Tab(text: 'Tâche 3'),
          ],
        ),
      ),
      body: ResponsiveFrame(
        child: Column(
          children: [
            if (_error != null) _buildErrorBanner(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TacheEditor(
                    tache: widget.combinaison.tache1,
                    controller: _tache1Controller,
                    taskNumber: 1,
                    onWordCountChanged: () => setState(() {}),
                  ),
                  _TacheEditor(
                    tache: widget.combinaison.tache2,
                    controller: _tache2Controller,
                    taskNumber: 2,
                    onWordCountChanged: () => setState(() {}),
                  ),
                  _TacheEditor(
                    tache: widget.combinaison.tache3,
                    controller: _tache3Controller,
                    taskNumber: 3,
                    onWordCountChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
            _buildEvaluateButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: cs.errorContainer.withValues(alpha: 0.5),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: cs.onErrorContainer,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: cs.error, size: 18),
            onPressed: () => setState(() => _error = null),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluateButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t1Words = _wordCount(_tache1Controller.text);
    final t2Words = _wordCount(_tache2Controller.text);
    final t3Words = _wordCount(_tache3Controller.text);

    final t1Ok = _withinRange(
      t1Words,
      widget.combinaison.tache1.minWords,
      widget.combinaison.tache1.maxWords,
    );
    final t2Ok = _withinRange(
      t2Words,
      widget.combinaison.tache2.minWords,
      widget.combinaison.tache2.maxWords,
    );
    final t3Ok = _withinRange(
      t3Words,
      widget.combinaison.tache3.minWords,
      widget.combinaison.tache3.maxWords,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _WordStatus(
                label: 'T1',
                count: t1Words,
                min: widget.combinaison.tache1.minWords,
                max: widget.combinaison.tache1.maxWords,
                ok: t1Ok,
              ),
              _WordStatus(
                label: 'T2',
                count: t2Words,
                min: widget.combinaison.tache2.minWords,
                max: widget.combinaison.tache2.maxWords,
                ok: t2Ok,
              ),
              _WordStatus(
                label: 'T3',
                count: t3Words,
                min: widget.combinaison.tache3.minWords,
                max: widget.combinaison.tache3.maxWords,
                ok: t3Ok,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _evaluating ? null : _evaluate,
              icon: _evaluating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(
                _evaluating ? 'Évaluation...' : 'Évaluer (/20)',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordStatus extends StatelessWidget {
  final String label;
  final int count;
  final int min;
  final int max;
  final bool ok;

  const _WordStatus({
    required this.label,
    required this.count,
    required this.min,
    required this.max,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = count == 0 ? null : (ok ? Colors.green : Colors.orange);

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (count == 0
                ? cs.surfaceContainerHighest
                : color!.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: count == 0 ? cs.onSurface : color,
            ),
          ),
        ),
        Text(
          '$min-$max',
          style: TextStyle(
            fontSize: 10,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _TacheEditor extends StatelessWidget {
  final EETache tache;
  final TextEditingController controller;
  final int taskNumber;
  final VoidCallback onWordCountChanged;

  const _TacheEditor({
    required this.tache,
    required this.controller,
    required this.taskNumber,
    required this.onWordCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tache.hasDocuments) ...[
            _buildDocumentCard(context, 'Document A', tache.documentA!),
            const SizedBox(height: 12),
            _buildDocumentCard(context, 'Document B', tache.documentB!),
            const SizedBox(height: 16),
          ],
          _buildInstructionCard(context),
          const SizedBox(height: 16),
          _buildEditor(context),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    String title,
    String content,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
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
                  color: cs.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(fontSize: 13, height: 1.5, color: cs.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.4),
            cs.secondaryContainer.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
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
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Tâche $taskNumber',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: cs.primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${tache.minWords}-${tache.maxWords} mots',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tache.instruction,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
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
              Icon(Icons.edit_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Votre réponse',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'Rédigez votre réponse ici...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
            onChanged: (_) => onWordCountChanged(),
            textAlignVertical: TextAlignVertical.top,
          ),
        ],
      ),
    );
  }
}
