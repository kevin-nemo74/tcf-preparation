import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);

    try {
      await _player.stop();
      await _player.seek(Duration.zero);
      await _player.setVolume(1.0);

      await _player.setUrl(widget.audioUrl);

      _duration = _player.duration ?? Duration.zero;

      _player.durationStream.listen((d) {
        if (!mounted) return;
        if (d != null) setState(() => _duration = d);
      });

      _player.positionStream.listen((p) {
        if (!mounted) return;
        setState(() => _position = p);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "Audio load failed");
    }
  }

  @override
  void didUpdateWidget(covariant AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) _load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: cs.surfaceContainerHighest.withOpacity(0.55),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(_error!, style: TextStyle(color: cs.error, fontWeight: FontWeight.w700)),
            ),
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;

              return Row(
                children: [
                  IconButton(
                    iconSize: 42,
                    onPressed: () async {
                      if (_error != null) {
                        await _load();
                        return;
                      }
                      if (playing) {
                        await _player.pause();
                      } else {
                        await _player.play();
                      }
                    },
                    icon: Icon(
                      playing ? Icons.pause_circle : Icons.play_circle,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          value: _position.inMilliseconds
                              .clamp(0, _duration.inMilliseconds)
                              .toDouble(),
                          max: (_duration.inMilliseconds == 0) ? 1 : _duration.inMilliseconds.toDouble(),
                          onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(_position), style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(_fmt(_duration), style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: "Restart",
                    onPressed: () => _player.seek(Duration.zero),
                    icon: Icon(Icons.replay_rounded, color: cs.primary),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}