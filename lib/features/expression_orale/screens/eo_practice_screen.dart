import 'dart:async';
import 'dart:io' show Directory, File;
import 'dart:math' show Random;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import '../models/eo_evaluation.dart';
import '../services/eo_evaluation_service.dart';
import '../services/groq_stt_service.dart';

enum PracticeState { ready, recording, processing, done, error }

class EOPracticeScreen extends StatefulWidget {
  final String sujet;
  final int tache;
  final int maxDurationSeconds;

  const EOPracticeScreen({
    super.key,
    required this.sujet,
    this.tache = 2,
    this.maxDurationSeconds = 120,
  });

  @override
  State<EOPracticeScreen> createState() => _EOPracticeScreenState();
}

class _EOPracticeScreenState extends State<EOPracticeScreen>
    with TickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();

  PracticeState _state = PracticeState.ready;
  String? _audioPath;
  String _transcription = '';
  EOEvaluation? _evaluation;
  String? _errorMessage;
  int _elapsedSeconds = 0;
  Timer? _timer;
  Timer? _waveTimer;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  List<double> _waveHeights = [0.3, 0.5, 0.4, 0.6, 0.35];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveTimer?.cancel();
    _pulseCtrl.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  void _startWaveAnimation() {
    _waveTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (!mounted) return;
      setState(() {
        _waveHeights = List.generate(5, (_) => 0.2 + _random.nextDouble() * 0.8);
      });
    });
  }

  void _stopWaveAnimation() {
    _waveTimer?.cancel();
    _waveTimer = null;
  }

  Future<void> _startRecording() async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = kIsWeb
        ? 'eo_recording_$ts.webm'
        : '${Directory.systemTemp.path}/eo_recording_$ts.wav';

    try {
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: path,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = PracticeState.error;
        _errorMessage = kIsWeb
            ? 'Erreur micro : $e'
            : 'Permission microphonique non accordée';
      });
      return;
    }

    setState(() {
      _state = PracticeState.recording;
      _audioPath = path;
      _elapsedSeconds = 0;
    });

    _pulseCtrl.repeat(reverse: true);
    _startWaveAnimation();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
        if (_elapsedSeconds >= widget.maxDurationSeconds) _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    _stopWaveAnimation();
    final path = await _recorder.stop();
    if (path != null) _audioPath = path;

    setState(() => _state = PracticeState.processing);
    await _evaluate();
  }

  Future<void> _evaluate() async {
    try {
      final path = _audioPath;
      if (path == null) throw Exception('Fichier audio introuvable');

      List<int> audioBytes;
      if (kIsWeb) {
        final resp = await http.get(Uri.parse(path));
        if (resp.statusCode != 200) throw Exception('Impossible de lire l\'audio');
        audioBytes = resp.bodyBytes;
      } else {
        audioBytes = await File(path).readAsBytes();
      }

      final transcription = await GroqSTTService.transcribe(audioBytes);
      if (!mounted) return;

      final evaluation = await EoEvaluationService.evaluate(
        sujet: widget.sujet,
        transcription: transcription,
        tache: widget.tache,
      );

      if (!mounted) return;
      setState(() {
        _transcription = transcription;
        _evaluation = evaluation;
        _state = PracticeState.done;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = PracticeState.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _playRecording() async {
    if (_audioPath == null) return;
    try {
      await _player.setFilePath(_audioPath!);
      await _player.play();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de lecture: $e')));
    }
  }

  Future<void> _reset() async {
    _timer?.cancel();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    _stopWaveAnimation();
    await _player.stop();
    setState(() {
      _state = PracticeState.ready;
      _transcription = '';
      _evaluation = null;
      _errorMessage = null;
      _elapsedSeconds = 0;
    });
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRecording = _state == PracticeState.recording;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tâche ${widget.tache} — EO'),
        centerTitle: true,
        leading: isRecording
            ? Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _RecordingLed(),
              )
            : null,
        actions: [
          if (_state == PracticeState.done || _state == PracticeState.error)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _reset,
              tooltip: 'Réessayer',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSujetCard(cs),
            const SizedBox(height: 16),
            _buildRecordSection(cs),
            if (_state == PracticeState.processing)
              _buildProcessingIndicator(),
            if (_state == PracticeState.error) _buildErrorCard(cs),
            if (_transcription.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildTranscriptionCard(cs),
            ],
            if (_evaluation != null) ...[
              const SizedBox(height: 16),
              _buildEvaluationCard(cs),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSujetCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz_outlined, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Sujet',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.sujet,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: cs.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordSection(ColorScheme cs) {
    final isRecording = _state == PracticeState.recording;
    final isReady = _state == PracticeState.ready;
    final isDone = _state == PracticeState.done;
    final isDisabled = _state == PracticeState.processing || isDone;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          if (isRecording) ...[
            _RecordingBadge(),
            const SizedBox(height: 16),
            _WaveformBars(heights: _waveHeights, color: Colors.red.shade400),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                key: ValueKey('timer_$_elapsedSeconds'),
                _formatTime(_elapsedSeconds),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: _elapsedSeconds > widget.maxDurationSeconds * 0.75
                      ? Colors.red.shade600
                      : cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'sur ${_formatTime(widget.maxDurationSeconds)}',
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: _elapsedSeconds / widget.maxDurationSeconds,
                color: _elapsedSeconds > widget.maxDurationSeconds * 0.75
                    ? Colors.red
                    : cs.primary,
                backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
                minHeight: 6,
              ),
            ),
          ] else if (isReady) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic_rounded,
                size: 40,
                color: cs.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Prêt à enregistrer',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Appuyez sur le micro pour commencer',
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ] else ...[
            Icon(Icons.check_circle_rounded, size: 48, color: Colors.green.shade600),
            const SizedBox(height: 8),
            Text(
              'Enregistrement terminé',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.green.shade700,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_audioPath != null && !isRecording)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      IconButton.filled(
                        onPressed: _playRecording,
                        icon: const Icon(Icons.play_arrow_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.secondaryContainer,
                          foregroundColor: cs.onSecondaryContainer,
                          minimumSize: const Size(48, 48),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Écouter',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              GestureDetector(
                onTap: isReady
                    ? _startRecording
                    : (isRecording ? _stopRecording : null),
                child: isRecording
                    ? AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (context, child) {
                          final s = _pulseAnim.value;
                          return Container(
                            width: 80 * s,
                            height: 80 * s,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.4),
                                  blurRadius: 12 * s,
                                  spreadRadius: 2 * s,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: const Icon(Icons.stop_rounded, size: 36, color: Colors.white),
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDisabled
                              ? cs.outlineVariant
                              : cs.primary,
                          boxShadow: isReady
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          Icons.mic_rounded,
                          size: 32,
                          color: isDisabled
                              ? cs.onSurface.withValues(alpha: 0.3)
                              : Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyse de votre réponse...',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Transcription et évaluation en cours',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: cs.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Erreur',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: cs.error,
                ),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 13, color: cs.onSurface),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _reset,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionCard(ColorScheme cs) {
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
              Icon(Icons.transcribe_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Transcription',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _transcription,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: cs.onSurface.withValues(alpha: 0.85),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(ColorScheme cs) {
    final ev = _evaluation!;
    final levelColor = _getScoreColor(ev.overallScore);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Résultat',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: levelColor.withValues(alpha: 0.15),
                    border: Border.all(color: levelColor, width: 4),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ev.overallScore.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: levelColor,
                          ),
                        ),
                        Text(
                          '/${ev.maxScore.toInt()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: levelColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoreRow(
                  cs,
                  'Contenu & Pertinence',
                  ev.contentScore,
                  7,
                ),
                const SizedBox(height: 8),
                _buildScoreRow(cs, 'Vocabulaire', ev.vocabularyScore, 5),
                const SizedBox(height: 8),
                _buildScoreRow(cs, 'Grammaire', ev.grammarScore, 5),
                const SizedBox(height: 8),
                _buildScoreRow(cs, 'Cohérence & Aisance', ev.coherenceScore, 3),
                if (ev.generalFeedback.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    'Commentaire',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ev.generalFeedback,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: cs.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                if (ev.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Suggestions',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: cs.tertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ev.suggestions,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: cs.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                if (ev.corrections.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Corrections',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: cs.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ev.corrections,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: cs.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(
    ColorScheme cs,
    String label,
    double score,
    double max,
  ) {
    final pct = max > 0 ? score / max : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            '${score.toInt()}/${max.toInt()}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: _getScoreColor(score / max * 20),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              color: _getScoreColor(pct * 20),
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 16) return Colors.green;
    if (score >= 12) return Colors.lightGreen;
    if (score >= 10) return Colors.orange;
    if (score >= 7) return Colors.deepOrange;
    return Colors.red;
  }
}

class _RecordingLed extends StatefulWidget {
  @override
  State<_RecordingLed> createState() => _RecordingLedState();
}

class _RecordingLedState extends State<_RecordingLed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: _anim.value),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'REC',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.red.withValues(alpha: _anim.value),
                letterSpacing: 1.5,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecordingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, opacity, _) {
        return Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingDot(),
                const SizedBox(width: 8),
                Text(
                  'Enregistrement...',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: _anim.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _WaveformBars extends StatelessWidget {
  final List<double> heights;
  final Color color;

  const _WaveformBars({required this.heights, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(heights.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 4,
              height: 40 * heights[i],
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
