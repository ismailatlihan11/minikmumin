import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/audio/asset_catalog.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import 'buttons.dart';

const _paper = Color(0xFFFFFDF8);

/// Tek boya paleti (ana / ara ayrımı yok).
const minikPaintColors = <(String, Color)>[
  ('Kırmızı', Color(0xFFE53935)),
  ('Pembe', Color(0xFFEC407A)),
  ('Turuncu', Color(0xFFFB8C00)),
  ('Sarı', Color(0xFFFDD835)),
  ('Limon', Color(0xFFC0CA33)),
  ('Yeşil', Color(0xFF43A047)),
  ('Mint', Color(0xFF26A69A)),
  ('Turkuaz', Color(0xFF00ACC1)),
  ('Gök', Color(0xFF29B6F6)),
  ('Mavi', Color(0xFF1E88E5)),
  ('Lacivert', Color(0xFF3949AB)),
  ('Mor', Color(0xFF8E24AA)),
  ('Fuşya', Color(0xFFD81B60)),
  ('Kahve', Color(0xFF8D6E63)),
  ('Ten', Color(0xFFFFCC80)),
  ('Gri', Color(0xFF90A4AE)),
  ('Siyah', Color(0xFF212121)),
  ('Beyaz', Color(0xFFFFFFFF)),
];

Color minikMixPaintColors(Color a, Color b) {
  return Color.lerp(a, b, 0.5)!.withValues(alpha: 1);
}

String? minikPaintColorName(Color color) {
  for (final item in minikPaintColors) {
    if (_nearColor(item.$2, color)) return item.$1;
  }
  if (_nearColor(_paper, color) || color == _paper) return 'Silgi';
  return null;
}

String minikMixPaintLabel(Color a, Color b, Color result) {
  final left = minikPaintColorName(a) ?? 'Renk';
  final right = minikPaintColorName(b) ?? 'Renk';
  final named = minikPaintColorName(result);
  if (named != null) return '$left + $right = $named';
  return '$left + $right = yeni renk';
}

bool _nearColor(Color a, Color b) {
  final dr = (a.r - b.r).abs();
  final dg = (a.g - b.g).abs();
  final db = (a.b - b.b).abs();
  return dr + dg + db < 0.12;
}

/// Kompakt renk şeridi + iki rengi karıştırma.
class MinikPaintPalette extends StatefulWidget {
  const MinikPaintPalette({
    super.key,
    required this.selected,
    required this.onSelected,
    this.eraser = _paper,
  });

  final Color selected;
  final ValueChanged<Color> onSelected;
  final Color eraser;

  @override
  State<MinikPaintPalette> createState() => _MinikPaintPaletteState();
}

class _MinikPaintPaletteState extends State<MinikPaintPalette> {
  Color? _slotA;
  Color? _slotB;
  final _mixes = <(String, Color)>[];
  bool _showMix = false;

  void _pick(Color color) {
    widget.onSelected(color);
  }

  void _fillSlot(Color color) {
    if (color == widget.eraser) {
      _pick(color);
      return;
    }
    setState(() {
      _showMix = true;
      if (_slotA == null) {
        _slotA = color;
      } else if (_slotB == null) {
        _slotB = color;
      } else {
        _slotA = color;
        _slotB = null;
      }
    });
  }

  void _applyMix() {
    final a = _slotA;
    final b = _slotB;
    if (a == null || b == null) return;
    final mixed = minikMixPaintColors(a, b);
    final label = minikMixPaintLabel(a, b, mixed);
    setState(() {
      if (!_mixes.any((item) => _nearColor(item.$2, mixed))) {
        _mixes.add((label, mixed));
      }
    });
    widget.onSelected(mixed);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(label),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearMix() => setState(() {
        _slotA = null;
        _slotB = null;
      });

  Widget _swatch(
    Color color, {
    required bool selected,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Widget? child,
    double size = 34,
  }) {
    final swatch = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? MinikColors.darkGreen : const Color(0x33000000),
            width: selected ? 3 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: MinikColors.green.withValues(alpha: 0.25),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
    if (onLongPress == null) return swatch;
    return Tooltip(message: 'Uzun bas → karıştır', child: swatch);
  }

  @override
  Widget build(BuildContext context) {
    final result =
        _slotA != null && _slotB != null ? minikMixPaintColors(_slotA!, _slotB!) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              Tooltip(
                message: 'Silgi',
                child: _swatch(
                  widget.eraser,
                  selected: widget.selected == widget.eraser,
                  onTap: () => _pick(widget.eraser),
                  child: const MinikEraserIcon(size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 28,
                color: MinikColors.green.withValues(alpha: 0.25),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final item in minikPaintColors) ...[
                      _swatch(
                        item.$2,
                        selected: _nearColor(widget.selected, item.$2),
                        onTap: () => _pick(item.$2),
                        onLongPress: () => _fillSlot(item.$2),
                      ),
                      const SizedBox(width: 7),
                    ],
                    for (final item in _mixes) ...[
                      Tooltip(
                        message: item.$1,
                        child: _swatch(
                          item.$2,
                          selected: _nearColor(widget.selected, item.$2),
                          onTap: () => _pick(item.$2),
                          onLongPress: () => _fillSlot(item.$2),
                        ),
                      ),
                      const SizedBox(width: 7),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Sabit yükseklik: karışım açılınca tuval küçülmesin (boya kayması olmasın).
        SizedBox(
          height: 40,
          child: _showMix
              ? ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _showMix = false),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 36),
                      ),
                      icon: const Icon(Icons.expand_more_rounded, size: 18),
                      label: const Text('Gizle'),
                    ),
                    const SizedBox(width: 4),
                    _swatch(
                      _slotA ?? const Color(0xFFE8EEEA),
                      selected: false,
                      size: 34,
                      child: _slotA == null
                          ? Icon(
                              Icons.add,
                              size: 16,
                              color: MinikColors.textMuted,
                            )
                          : null,
                      onTap: () {
                        if (_slotA != null) _pick(_slotA!);
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        child: Text(
                          '+',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    _swatch(
                      _slotB ?? const Color(0xFFE8EEEA),
                      selected: false,
                      size: 34,
                      child: _slotB == null
                          ? Icon(
                              Icons.add,
                              size: 16,
                              color: MinikColors.textMuted,
                            )
                          : null,
                      onTap: () {
                        if (_slotB != null) _pick(_slotB!);
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        child: Text(
                          '=',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    _swatch(
                      result ?? const Color(0xFFE8EEEA),
                      selected:
                          result != null && _nearColor(widget.selected, result),
                      size: 34,
                      child: result == null
                          ? Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: MinikColors.textMuted,
                            )
                          : null,
                      onTap:
                          result == null ? null : () => widget.onSelected(result),
                    ),
                    if (_slotA != null || _slotB != null)
                      IconButton(
                        tooltip: 'Temizle',
                        visualDensity: VisualDensity.compact,
                        onPressed: _clearMix,
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                      ),
                    const SizedBox(width: 4),
                    FilledButton(
                      onPressed: result == null ? null : _applyMix,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Kullan'),
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              : Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _showMix = true),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 36),
                      ),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const Text('Karıştır'),
                    ),
                    const Spacer(),
                    Text(
                      'Uzun bas → karıştır',
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 11,
                        color: MinikColors.textMuted,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

const _brushes = <(double, String)>[
  (6, 'Çok ince'),
  (12, 'İnce'),
  (22, 'Normal'),
  (34, 'Kalın'),
];

const _customBrushMin = 2.0;
const _customBrushMax = 56.0;

const _zoomMin = 1.0;
const _zoomMax = 4.0;
const _zoomStep = 0.35;

/// Boyama alanı: yakınlaştır / uzaklaştır / pinch + kaydır.
class MinikZoomablePaintArea extends StatefulWidget {
  const MinikZoomablePaintArea({
    super.key,
    required this.onPaint,
    required this.child,
  });

  final void Function(Offset point, {required bool start}) onPaint;
  final Widget child;

  @override
  State<MinikZoomablePaintArea> createState() => _MinikZoomablePaintAreaState();
}

class _MinikZoomablePaintAreaState extends State<MinikZoomablePaintArea> {
  double _scale = 1;
  Offset _offset = Offset.zero;
  double _baseScale = 1;
  bool _painting = false;
  Size _viewport = Size.zero;

  void _zoomBy(double delta) {
    setState(() {
      final next = (_scale + delta).clamp(_zoomMin, _zoomMax);
      _scale = next;
      if (_scale <= _zoomMin) _offset = Offset.zero;
      _clampOffset();
    });
  }

  void _resetZoom() {
    setState(() {
      _scale = 1;
      _offset = Offset.zero;
    });
  }

  void _clampOffset() {
    if (_viewport == Size.zero || _scale <= 1) {
      if (_scale <= 1) _offset = Offset.zero;
      return;
    }
    final overflowX = _viewport.width * (_scale - 1) / 2 + 48;
    final overflowY = _viewport.height * (_scale - 1) / 2 + 48;
    _offset = Offset(
      _offset.dx.clamp(-overflowX, overflowX),
      _offset.dy.clamp(-overflowY, overflowY),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRect(
              child: Transform.translate(
                offset: _offset,
                child: Transform.scale(
                  scale: _scale,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: (details) {
                        _baseScale = _scale;
                        _painting = details.pointerCount < 2;
                        if (_painting) {
                          widget.onPaint(details.localFocalPoint, start: true);
                        }
                      },
                      onScaleUpdate: (details) {
                        if (details.pointerCount >= 2) {
                          _painting = false;
                          setState(() {
                            _scale = (_baseScale * details.scale)
                                .clamp(_zoomMin, _zoomMax);
                            _offset += details.focalPointDelta * _scale;
                            if (_scale <= _zoomMin) _offset = Offset.zero;
                            _clampOffset();
                          });
                          return;
                        }
                        if (_painting) {
                          widget.onPaint(
                            details.localFocalPoint,
                            start: false,
                          );
                        }
                      },
                      onScaleEnd: (_) => _painting = false,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: Material(
                color: Colors.white.withValues(alpha: 0.94),
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Yakınlaştır',
                      visualDensity: VisualDensity.compact,
                      onPressed: _scale >= _zoomMax
                          ? null
                          : () => _zoomBy(_zoomStep),
                      icon: const Icon(Icons.add_rounded),
                    ),
                    Text(
                      '${_scale.toStringAsFixed(1)}×',
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: MinikColors.darkGreen,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Uzaklaştır',
                      visualDensity: VisualDensity.compact,
                      onPressed: _scale <= _zoomMin
                          ? null
                          : () => _zoomBy(-_zoomStep),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    if (_scale > _zoomMin || _offset != Offset.zero)
                      IconButton(
                        tooltip: 'Sıfırla',
                        visualDensity: VisualDensity.compact,
                        onPressed: _resetZoom,
                        icon: const Icon(Icons.center_focus_strong_rounded),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

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
  Color _color = const Color(0xFF43A047);
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
                                    errorBuilder: (_, __, ___) => Center(
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

class MinikEraserIcon extends StatelessWidget {
  const MinikEraserIcon({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ui/eraser.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
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
                decoration: BoxDecoration(
                  color: MinikColors.darkGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
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
            Text(
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
