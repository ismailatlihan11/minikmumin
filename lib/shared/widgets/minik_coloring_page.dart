import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/asset_catalog.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import 'buttons.dart';

const _paper = Color(0xFFFFFDF8);

const _palette = <Color>[
  Color(0xFFE85D75),
  Color(0xFFF08A4B),
  Color(0xFFF2C14E),
  Color(0xFF7BC67E),
  Color(0xFF4DB6AC),
  Color(0xFF5BA3D9),
  Color(0xFF7E6BBE),
  Color(0xFF21684E),
  Color(0xFF5D4037),
  Color(0xFF1E392F),
  _paper,
];

const _brushes = <(double, String)>[
  (6, 'Çok ince'),
  (12, 'İnce'),
  (22, 'Normal'),
  (34, 'Kalın'),
];

const _customBrushMin = 2.0;
const _customBrushMax = 56.0;

/// Light sketch look so the lesson image can be colored like a boyama sayfası.
const _sketchFilter = ColorFilter.matrix(<double>[
  0.21,
  0.72,
  0.07,
  0,
  64,
  0.21,
  0.72,
  0.07,
  0,
  64,
  0.21,
  0.72,
  0.07,
  0,
  64,
  0,
  0,
  0,
  1,
  0,
]);

void openImageColoring(
  BuildContext context, {
  required String image,
  required String title,
  String prompt = 'Parmağınla resmi boya.',
  String? audio,
  String? progressKind,
  String? progressId,
  String celebrationSubtitle = 'Ne güzel boyadın!',
}) {
  if (image.trim().isEmpty) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MinikColoringPage(
        image: image,
        title: title,
        prompt: prompt,
        audio: audio,
        progressKind: progressKind,
        progressId: progressId,
        celebrationSubtitle: celebrationSubtitle,
      ),
    ),
  );
}

class MinikColoringPage extends StatefulWidget {
  const MinikColoringPage({
    super.key,
    required this.image,
    required this.title,
    this.prompt = 'Parmağınla resmi boya.',
    this.audio,
    this.progressKind,
    this.progressId,
    this.celebrationSubtitle = 'Ne güzel boyadın!',
  });

  final String image;
  final String title;
  final String prompt;
  final String? audio;
  final String? progressKind;
  final String? progressId;
  final String celebrationSubtitle;

  @override
  State<MinikColoringPage> createState() => _MinikColoringPageState();
}

class _MinikColoringPageState extends State<MinikColoringPage> {
  final _audio = AudioPlayerService();
  final _strokes = <_PaintStroke>[];
  Color _color = _palette[3];
  double _width = 22;
  bool _customBrush = false;
  bool _saved = false;

  String? get _playableAudio {
    final path = widget.audio?.trim() ?? '';
    if (path.isEmpty || !AssetCatalog.contains(path)) return null;
    return path;
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  void _addPoint(Offset point, {required bool start}) {
    setState(() {
      if (start || _strokes.isEmpty) {
        _strokes.add(
          _PaintStroke(color: _color, width: _width, points: [point]),
        );
      } else {
        _strokes.last.points.add(point);
      }
    });
  }

  Future<void> _finish() async {
    final points = _strokes.fold<int>(0, (n, s) => n + s.points.length);
    if (points < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biraz boya, sonra Bitti’ye bas.')),
      );
      return;
    }
    if (_saved) {
      Navigator.pop(context);
      return;
    }
    _saved = true;
    final kind = widget.progressKind;
    final id = widget.progressId;
    if (kind != null && id != null && id.isNotEmpty) {
      await context.read<LocalProgressStore>().markCompleted(kind, id, xp: 3);
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Ne güzel boyadın!', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 42)),
              const SizedBox(height: 8),
              Text(widget.celebrationSubtitle, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioPath = _playableAudio;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (audioPath != null)
            IconButton(
              tooltip: 'Dinle',
              onPressed: () => _audio.toggleAsset(audioPath),
              icon: const Icon(Icons.volume_up_rounded),
            ),
        ],
      ),
      body: Padding(
        padding: AppSpacing.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.prompt, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _paper,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: MinikColors.green.withValues(alpha: 0.18),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (d) =>
                            _addPoint(d.localPosition, start: true),
                        onPanUpdate: (d) =>
                            _addPoint(d.localPosition, start: false),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const ColoredBox(color: _paper),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: ColorFiltered(
                                colorFilter: _sketchFilter,
                                child: Image.asset(
                                  widget.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 72,
                                      color: MinikColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            CustomPaint(
                              painter: _StrokePainter(strokes: _strokes),
                              child: const SizedBox.expand(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_customBrush)
                    Positioned(
                      right: 8,
                      top: 16,
                      bottom: 16,
                      child: MinikCustomBrushRail(
                        width: _width,
                        onChanged: (width) => setState(() {
                          _customBrush = true;
                          _width = width;
                        }),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _color = color),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == color
                              ? MinikColors.darkGreen
                              : const Color(0x33000000),
                          width: _color == color ? 3 : 1,
                        ),
                      ),
                      child: color == _paper
                          ? const Icon(Icons.auto_fix_off_rounded, size: 18)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            MinikBrushSizePicker(
              width: _width,
              custom: _customBrush,
              onPreset: (width) => setState(() {
                _customBrush = false;
                _width = width;
              }),
              onCustom: (width) => setState(() {
                _customBrush = true;
                _width = width;
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Geri Al',
                    onPressed: _strokes.isEmpty
                        ? null
                        : () => setState(() => _strokes.removeLast()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SecondaryButton(
                    label: 'Sil',
                    onPressed: _strokes.isEmpty
                        ? null
                        : () => setState(_strokes.clear),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(label: 'Bitti', onPressed: _finish),
          ],
        ),
      ),
    );
  }
}

class MinikBrushSizePicker extends StatelessWidget {
  const MinikBrushSizePicker({
    super.key,
    required this.width,
    required this.custom,
    required this.onPreset,
    required this.onCustom,
  });

  final double width;
  final bool custom;
  final ValueChanged<double> onPreset;
  final ValueChanged<double> onCustom;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _brushes.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22,
                    height: (_brushes[i].$1 * 0.28).clamp(2.0, 10.0),
                    decoration: BoxDecoration(
                      color: MinikColors.darkGreen,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(_brushes[i].$2),
                ],
              ),
              selected: !custom && width == _brushes[i].$1,
              onSelected: (_) => onPreset(_brushes[i].$1),
            ),
          ],
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 18),
                SizedBox(width: 6),
                Text('Kendin seç'),
              ],
            ),
            selected: custom,
            onSelected: (_) =>
                onCustom(width.clamp(_customBrushMin, _customBrushMax)),
          ),
        ],
      ),
    );
  }
}

class MinikCustomBrushRail extends StatelessWidget {
  const MinikCustomBrushRail({
    super.key,
    required this.width,
    required this.onChanged,
  });

  final double width;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      elevation: 3,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: MinikColors.green.withValues(alpha: 0.2),
                ),
              ),
              child: Container(
                width: width.clamp(4, 32),
                height: width.clamp(4, 32),
                decoration: const BoxDecoration(
                  color: MinikColors.darkGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kalın',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: MinikColors.darkGreen,
              ),
            ),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 11,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                  ),
                  child: Slider(
                    min: _customBrushMin,
                    max: _customBrushMax,
                    value: width.clamp(_customBrushMin, _customBrushMax),
                    activeColor: MinikColors.green,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
            const Text(
              'İnce',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: MinikColors.darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaintStroke {
  _PaintStroke({
    required this.color,
    required this.width,
    required this.points,
  });

  final Color color;
  final double width;
  final List<Offset> points;
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({required this.strokes});

  final List<_PaintStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color.withValues(alpha: 0.82)
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.width / 2, paint);
        continue;
      }
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
