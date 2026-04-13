import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/widgets/french_keyboard.dart';
import 'package:tcf_canada_preparation/features/progress/progress_repository.dart';
import '../models/ee_combinaison.dart';
import '../services/ee_progress_service.dart';
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
  final _tache1Focus = FocusNode();
  final _tache2Focus = FocusNode();
  final _tache3Focus = FocusNode();
  bool _evaluating = false;
  String? _error;
  bool _showFrenchKeyboard = false;
  bool _instructionsExpanded = true;

  TextEditingController get _currentController {
    switch (_tabController.index) {
      case 0:
        return _tache1Controller;
      case 1:
        return _tache2Controller;
      case 2:
        return _tache3Controller;
      default:
        return _tache1Controller;
    }
  }

  FocusNode get _currentFocus {
    switch (_tabController.index) {
      case 0:
        return _tache1Focus;
      case 1:
        return _tache2Focus;
      case 2:
        return _tache3Focus;
      default:
        return _tache1Focus;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _tache1Controller.dispose();
    _tache2Controller.dispose();
    _tache3Controller.dispose();
    _tache1Focus.dispose();
    _tache2Focus.dispose();
    _tache3Focus.dispose();
    super.dispose();
  }

  int _wordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  bool _withinRange(int count, int min, int max) {
    return count >= min && count <= max;
  }

  EETache get _currentTache {
    switch (_tabController.index) {
      case 0:
        return widget.combinaison.tache1;
      case 1:
        return widget.combinaison.tache2;
      case 2:
        return widget.combinaison.tache3;
      default:
        return widget.combinaison.tache1;
    }
  }

  int _getWordCount(int taskIndex) {
    switch (taskIndex) {
      case 0:
        return _wordCount(_tache1Controller.text);
      case 1:
        return _wordCount(_tache2Controller.text);
      case 2:
        return _wordCount(_tache3Controller.text);
      default:
        return 0;
    }
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

      final uid = ProgressRepository.currentUid;
      if (uid != null) {
        try {
          await EEProgressService.saveAttempt(
            uid: uid,
            combinaisonId: widget.combinaison.id,
            monthId: widget.combinaison.id.split('-').first,
            scoreOutOf20: evaluation.finalScoreOutOf20,
            tache1WordCount: t1Words,
            tache2WordCount: t2Words,
            tache3WordCount: t3Words,
            tache1Score: evaluation.taches.isNotEmpty
                ? evaluation.taches[0].score
                : null,
            tache2Score: evaluation.taches.length > 1
                ? evaluation.taches[1].score
                : null,
            tache3Score: evaluation.taches.length > 2
                ? evaluation.taches[2].score
                : null,
            feedback: evaluation.generalFeedback,
          );
        } catch (err) {
          debugPrint('Failed to save EE attempt: $err');
        }
      }

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
    final isWeb = Responsive.isTabletWeb(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expression Écrite',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          if (isWeb && kIsWeb)
            IconButton(
              icon: Icon(
                _showFrenchKeyboard
                    ? Icons.keyboard_alt
                    : Icons.keyboard_alt_outlined,
                color: _showFrenchKeyboard ? cs.primary : null,
              ),
              onPressed: () =>
                  setState(() => _showFrenchKeyboard = !_showFrenchKeyboard),
              tooltip: 'Clavier français',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurface.withValues(alpha: 0.6),
          indicatorColor: cs.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: _buildTabLabel(
                1,
                widget.combinaison.tache1.minWords,
                widget.combinaison.tache1.maxWords,
              ),
            ),
            Tab(
              child: _buildTabLabel(
                2,
                widget.combinaison.tache2.minWords,
                widget.combinaison.tache2.maxWords,
              ),
            ),
            Tab(
              child: _buildTabLabel(
                3,
                widget.combinaison.tache3.minWords,
                widget.combinaison.tache3.maxWords,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_error != null) _buildErrorBanner(context),
          Expanded(
            child: isWeb && kIsWeb
                ? _buildWebLayout(context)
                : _buildMobileLayout(context),
          ),
          _buildEvaluateButton(context),
        ],
      ),
    );
  }

  Widget _buildTabLabel(int num, int min, int max) {
    final count = _getWordCount(num - 1);
    final ok = _withinRange(count, min, max);
    final hasContent = count > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Tâche $num'),
        if (hasContent) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ok
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: ok ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ],
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

  Widget _buildMobileLayout(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        _TacheEditor(
          tache: widget.combinaison.tache1,
          controller: _tache1Controller,
          focusNode: _tache1Focus,
          taskNumber: 1,
          onWordCountChanged: () => setState(() {}),
        ),
        _TacheEditor(
          tache: widget.combinaison.tache2,
          controller: _tache2Controller,
          focusNode: _tache2Focus,
          taskNumber: 2,
          onWordCountChanged: () => setState(() {}),
        ),
        _TacheEditor(
          tache: widget.combinaison.tache3,
          controller: _tache3Controller,
          focusNode: _tache3Focus,
          taskNumber: 3,
          onWordCountChanged: () => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tache = _currentTache;
    final controller = _currentController;

    return Row(
      children: [
        Container(
          width: 380,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow.withValues(alpha: 0.5),
            border: Border(
              right: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 20, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Consignes',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: cs.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _instructionsExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _instructionsExpanded = !_instructionsExpanded,
                      ),
                      tooltip: _instructionsExpanded ? 'Réduire' : 'Développer',
                    ),
                  ],
                ),
              ),
              if (_instructionsExpanded)
                Expanded(
                  child: _InstructionsPanel(
                    tache: tache,
                    taskNumber: _tabController.index + 1,
                    buildDocumentCard: _buildDocumentCard,
                  ),
                )
              else
                const SizedBox(height: 48),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _WebEditorPane(
                  controller: controller,
                  focusNode: _currentFocus,
                  tache: tache,
                  taskNumber: _tabController.index + 1,
                  onWordCountChanged: () => setState(() {}),
                ),
              ),
              if (_showFrenchKeyboard && kIsWeb)
                FrenchKeyboardToolbar(
                  controller: controller,
                  onClose: () => setState(() => _showFrenchKeyboard = false),
                ),
            ],
          ),
        ),
      ],
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

  Widget _buildEvaluateButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
      child: SizedBox(
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
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _TacheEditor extends StatelessWidget {
  final EETache tache;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int taskNumber;
  final VoidCallback onWordCountChanged;

  const _TacheEditor({
    required this.tache,
    required this.controller,
    required this.focusNode,
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
          _MobileEditor(
            controller: controller,
            focusNode: focusNode,
            onWordCountChanged: onWordCountChanged,
          ),
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
}

class _MobileEditor extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onWordCountChanged;

  const _MobileEditor({
    required this.controller,
    required this.focusNode,
    required this.onWordCountChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            focusNode: focusNode,
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

class _WebEditorPane extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final EETache tache;
  final int taskNumber;
  final VoidCallback onWordCountChanged;

  const _WebEditorPane({
    required this.controller,
    required this.focusNode,
    required this.tache,
    required this.taskNumber,
    required this.onWordCountChanged,
  });

  @override
  State<_WebEditorPane> createState() => _WebEditorPaneState();
}

class _WebEditorPaneState extends State<_WebEditorPane> {
  int _wordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = _wordCount(widget.controller.text);
    final progress = (count / widget.tache.maxWords).clamp(0.0, 1.0);
    final isInRange =
        count >= widget.tache.minWords && count <= widget.tache.maxWords;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 10),
              Text(
                'Votre réponse',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: count == 0
                      ? cs.surfaceContainerHighest
                      : (isInRange
                            ? Colors.green.withValues(alpha: 0.15)
                            : Colors.orange.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: count == 0
                            ? cs.onSurface
                            : (isInRange ? Colors.green : Colors.orange),
                      ),
                    ),
                    Text(
                      ' / ${widget.tache.minWords}-${widget.tache.maxWords} mots',
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                count == 0
                    ? cs.primary.withValues(alpha: 0.3)
                    : (isInRange ? Colors.green : Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText:
                      'Rédigez votre réponse ici...\n\nTips: Utilisez le clavier français pour les caractères accentués.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  hintStyle: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.3),
                    height: 1.5,
                  ),
                ),
                onChanged: (_) => widget.onWordCountChanged(),
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsPanel extends StatelessWidget {
  final EETache tache;
  final int taskNumber;
  final Widget Function(BuildContext, String, String) buildDocumentCard;

  const _InstructionsPanel({
    required this.tache,
    required this.taskNumber,
    required this.buildDocumentCard,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                  tache.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tache.instruction,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (tache.hasDocuments) ...[
            const SizedBox(height: 16),
            buildDocumentCard(context, 'Document A', tache.documentA!),
            const SizedBox(height: 12),
            buildDocumentCard(context, 'Document B', tache.documentB!),
          ],
        ],
      ),
    );
  }
}
