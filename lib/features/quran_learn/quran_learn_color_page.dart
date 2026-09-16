import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_coloring_page.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';

const _paper = Color(0xFFFFFDF8);

void openQlColoring(
  BuildContext context, {
  required String arabic,
  required String title,
  String prompt = 'Parmağınla boya.',
  String? audio,
  QuranLearningPack? pack,
  String? progressKind,
  String? progressId,
  String celebrationSubtitle = 'Ne güzel boyadın!',
}) {
  final glyph = arabic.trim();
  if (glyph.isEmpty) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => QlColoringPage(
        arabic: glyph,
        title: title,
        prompt: prompt,
        audio: audio,
        pack: pack,
        progressKind: progressKind,
        progressId: progressId,
        celebrationSubtitle: celebrationSubtitle,
      ),
    ),
  );
}

class QlColorButton extends StatelessWidget {
  const QlColorButton({
    super.key,
    required this.arabic,
    required this.title,
    this.prompt = 'Parmağınla boya.',
    this.audio,
    this.pack,
    this.progressKind,
    this.progressId,
    this.celebrationSubtitle = 'Ne güzel boyadın!',
    this.label = 'Boya',
  });

  final String arabic;
  final String title;
  final String prompt;
  final String? audio;
  final QuranLearningPack? pack;
  final String? progressKind;
  final String? progressId;
  final String celebrationSubtitle;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (arabic.trim().isEmpty) return const SizedBox.shrink();
    return FilledButton.tonalIcon(
      onPressed: () => openQlColoring(
        context,
        arabic: arabic,
        title: title,
        prompt: prompt,
        audio: audio,
        pack: pack,
        progressKind: progressKind,
        progressId: progressId,
        celebrationSubtitle: celebrationSubtitle,
      ),
      icon: const Icon(Icons.palette_rounded),
      label: Text(label),
    );
  }
}

class QlColorIconButton extends StatelessWidget {
  const QlColorIconButton({
    super.key,
    required this.arabic,
    required this.title,
    this.prompt = 'Parmağınla boya.',
    this.audio,
    this.pack,
    this.progressKind,
    this.progressId,
    this.celebrationSubtitle = 'Ne güzel boyadın!',
  });

  final String arabic;
  final String title;
  final String prompt;
  final String? audio;
  final QuranLearningPack? pack;
  final String? progressKind;
  final String? progressId;
  final String celebrationSubtitle;

  @override
  Widget build(BuildContext context) {
    if (arabic.trim().isEmpty) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Boya',
      onPressed: () => openQlColoring(
        context,
        arabic: arabic,
        title: title,
        prompt: prompt,
        audio: audio,
        pack: pack,
        progressKind: progressKind,
        progressId: progressId,
        celebrationSubtitle: celebrationSubtitle,
      ),
      icon: const Icon(Icons.palette_rounded, color: MinikColors.green),
    );
  }
}

class QuranLearnColorHubPage extends StatefulWidget {
  const QuranLearnColorHubPage({super.key});

  @override
  State<QuranLearnColorHubPage> createState() => _QuranLearnColorHubPageState();
}

class _QuranLearnColorHubPageState extends State<QuranLearnColorHubPage> {
  Future<QuranLearningPack>? _future;

  @override
  Widget build(BuildContext context) {
    _future ??= context.read<ContentRepositories>().quranLearning.load();
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: const Text('Harfleri Boya')),
      body: AsyncBody<QuranLearningPack>(
        future: _future!,
        errorMessage: "Kur'an Öğren içeriği yüklenemedi.",
        onRetry: () => setState(
          () => _future =
              context.read<ContentRepositories>().quranLearning.load(),
        ),
        builder: (pack) => FutureBuilder<QuranLearnSnapshot>(
          future: QuranLearnProgress.load(store, pack),
          builder: (context, snapshot) {
            final snap = snapshot.data;
            return ListView(
              padding: AppSpacing.page,
              children: [
                const PageHeader(
                  title: 'Harfleri Boya',
                  subtitle: 'Bir harf seç, parmağınla boya.',
                  image: 'assets/images/home/card_quran_learn.png',
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pack.letters.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final letter = pack.letters[index];
                    final colored =
                        snap?.isDone('ql_color', letter.id) ?? false;
                    return MinikCard(
                      color: colored ? MinikColors.mint : Colors.white,
                      padding: const EdgeInsets.all(6),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuranLearnColorPage(
                            pack: pack,
                            letter: letter,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QlBigArabic(letter.letter, fontSize: 28),
                          Text(
                            letter.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: MinikColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class QuranLearnColorPage extends StatelessWidget {
  const QuranLearnColorPage({
    super.key,
    required this.pack,
    required this.letter,
  });

  final QuranLearningPack pack;
  final QuranArabicLetter letter;

  @override
  Widget build(BuildContext context) {
    return QlColoringPage(
      arabic: letter.letter,
      title: '${letter.name} boya',
      prompt: 'Parmağınla ${letter.name} harfini boya.',
      audio: letter.audio,
      pack: pack,
      progressKind: 'ql_color',
      progressId: letter.id,
      celebrationSubtitle: '${letter.name} harfini boyadın.',
    );
  }
}

class QlColoringPage extends StatefulWidget {
  const QlColoringPage({
    super.key,
    required this.arabic,
    required this.title,
    this.prompt = 'Parmağınla boya.',
    this.audio,
    this.pack,
    this.progressKind,
    this.progressId,
    this.celebrationSubtitle = 'Ne güzel boyadın!',
  });

  final String arabic;
  final String title;
  final String prompt;
  final String? audio;
  final QuranLearningPack? pack;
  final String? progressKind;
  final String? progressId;
  final String celebrationSubtitle;

  @override
  State<QlColoringPage> createState() => _QlColoringPageState();
}

class _QlColoringPageState extends State<QlColoringPage> {
  final _audio = AudioPlayerService();
  final _strokes = <_PaintStroke>[];
  Color _color = const Color(0xFF43A047);
  double _width = 22;
  bool _customBrush = false;
  bool _saved = false;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    await QuranLearnAudio.play(
      _audio,
      context.read<LocalProgressStore>(),
      widget.audio,
    );
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
    final pack = widget.pack;
    final kind = widget.progressKind;
    final id = widget.progressId;
    if (pack != null && kind != null && id != null && id.isNotEmpty) {
      await QuranLearnProgress.complete(
        context.read<LocalProgressStore>(),
        pack: pack,
        kind: kind,
        id: id,
        xp: 3,
      );
    }
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Ne güzel boyadın!',
      subtitle: widget.celebrationSubtitle,
      continueLabel: 'Tamam',
      onContinue: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (QuranLearnAudio.resolve(widget.audio) != null)
            IconButton(
              tooltip: 'Dinle',
              onPressed: _play,
              icon: const Icon(Icons.volume_up_rounded),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                widget.prompt,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: _paper,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: MinikColors.green.withValues(alpha: 0.18),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: MinikZoomablePaintArea(
                          onPaint: _addPoint,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return CustomPaint(
                                painter: _LetterPaintPainter(strokes: _strokes),
                                foregroundPainter: _GlyphOutlinePainter(
                                  text: widget.arabic,
                                  canvasSize: constraints.biggest,
                                ),
                                child: const SizedBox.expand(),
                              );
                            },
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MinikPaintPalette(
                    selected: _color,
                    onSelected: (color) => setState(() => _color = color),
                  ),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 8),
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
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(label: 'Bitti', onPressed: _finish),
                      ),
                    ],
                  ),
                ],
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

class _LetterPaintPainter extends CustomPainter {
  _LetterPaintPainter({required this.strokes});

  final List<_PaintStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
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
  bool shouldRepaint(covariant _LetterPaintPainter oldDelegate) => true;
}

class _GlyphOutlinePainter extends CustomPainter {
  _GlyphOutlinePainter({required this.text, required this.canvasSize});

  final String text;
  final Size canvasSize;

  @override
  void paint(Canvas canvas, Size size) {
    final fontSize = _fitFont(text, size);
    final stroke = (fontSize * 0.055).clamp(3.0, 8.0);
    final fill = _layoutGlyph(text, fontSize, filled: true, size: size);
    final outline = _layoutGlyph(
      text,
      fontSize,
      filled: false,
      size: size,
      strokeWidth: stroke,
    );
    final offset = Offset(
      (size.width - fill.width) / 2,
      (size.height - fill.height) / 2,
    );
    fill.paint(canvas, offset);
    outline.paint(canvas, offset);
  }

  /// Largest one-line size that still fits the paper. Long words grow
  /// with the canvas width instead of staying a small centered glyph.
  double _fitFont(String glyph, Size size) {
    final maxW = size.width * 0.94;
    final maxH = size.height * 0.78;
    var lo = 18.0;
    var hi = (size.shortestSide * 0.72).clamp(48.0, 240.0);
    var best = 28.0;
    for (var i = 0; i < 14; i++) {
      final mid = (lo + hi) / 2;
      final painter = _painter(glyph, mid, filled: true)..layout();
      if (painter.width <= maxW && painter.height <= maxH) {
        best = mid;
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return best;
  }

  TextPainter _layoutGlyph(
    String glyph,
    double fontSize, {
    required bool filled,
    required Size size,
    double strokeWidth = 5,
  }) {
    final painter = _painter(
      glyph,
      fontSize,
      filled: filled,
      strokeWidth: strokeWidth,
    )..layout();
    if (painter.width <= size.width * 0.96) return painter;
    return _painter(
      glyph,
      fontSize,
      filled: filled,
      strokeWidth: strokeWidth,
    )..layout(maxWidth: size.width * 0.92);
  }

  TextPainter _painter(
    String glyph,
    double fontSize, {
    required bool filled,
    double strokeWidth = 5,
  }) {
    return TextPainter(
      text: TextSpan(
        text: glyph,
        style: TextStyle(
          fontFamily: AssetPaths.arabicFontFamily,
          fontSize: fontSize,
          height: 1.35,
          color: filled ? const Color(0x14000000) : null,
          foreground: filled
              ? null
              : (Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = MinikColors.darkGreen),
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );
  }

  @override
  bool shouldRepaint(covariant _GlyphOutlinePainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.canvasSize != canvasSize;
  }
}
