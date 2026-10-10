import 'package:flutter/material.dart';

import 'package:wedding/core/music/music_controller.dart';
import 'package:wedding/core/theme/app_colors.dart';

/// A compact, elegant play/pause control that reflects real playback state.
class MusicButton extends StatelessWidget {
  const MusicButton({
    super.key,
    required this.controller,
    this.tooltip,
    this.foreground = AppColors.goldDeep,
  });

  final MusicController controller;
  final String? tooltip;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isPlaying = controller.isPlaying;
        final isLoading = controller.status == MusicStatus.loading;
        final hasError = controller.hasError;
        return Tooltip(
          message: tooltip ?? (isPlaying ? 'Pause' : 'Play'),
          child: Material(
            color: AppColors.cream,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.champagne),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isLoading ? null : controller.togglePlayPause,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.champagne,
                          ),
                        )
                      : _EqualizerIcon(
                          playing: isPlaying,
                          hasError: hasError,
                          color: foreground,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EqualizerIcon extends StatefulWidget {
  const _EqualizerIcon({
    required this.playing,
    required this.hasError,
    required this.color,
  });

  final bool playing;
  final bool hasError;
  final Color color;

  @override
  State<_EqualizerIcon> createState() => _EqualizerIconState();
}

class _EqualizerIconState extends State<_EqualizerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.playing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _EqualizerIcon old) {
    super.didUpdateWidget(old);
    if (widget.playing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.playing && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasError && !widget.playing) {
      return Icon(Icons.music_off_outlined, size: 20, color: widget.color);
    }
    if (!widget.playing) {
      return Icon(Icons.music_note_outlined, size: 20, color: widget.color);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: const Size(20, 18),
        painter: _BarsPainter(
          progress: _controller.value,
          color: widget.color,
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6;
    const bars = 4;
    final gap = size.width / bars;
    for (var i = 0; i < bars; i++) {
      final phase = (progress + i * 0.22) % 1.0;
      final eased = (phase < 0.5 ? phase : 1 - phase) * 2;
      final h = size.height * (0.28 + 0.72 * eased);
      final x = gap * i + gap / 2;
      canvas.drawLine(
        Offset(x, (size.height - h) / 2),
        Offset(x, (size.height + h) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) =>
      old.progress != progress || old.color != color;
}
