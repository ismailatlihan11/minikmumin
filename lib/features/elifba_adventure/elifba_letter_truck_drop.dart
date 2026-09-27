import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';

/// Harfler kamyona yüklenir, sayfaya dökülür ve yaklaşık 5 saniyede
/// kendi ızgara yuvalarına yerleşir.
class LetterTruckDropIntro extends StatefulWidget {
  const LetterTruckDropIntro({
    super.key,
    required this.glyphs,
    required this.onFinished,
    this.names = const [],
    this.columns = 5,
    this.cellWidth = 64,
    this.cellHeight = 72,
    this.rtl = true,
    this.duration = const Duration(milliseconds: 5000),
  });

  final List<String> glyphs;
  final List<String> names;
  final VoidCallback onFinished;
  final int columns;
  final double cellWidth;
  final double cellHeight;
  final bool rtl;
  final Duration duration;

  @override
  State<LetterTruckDropIntro> createState() => _LetterTruckDropIntroState();
}

class _LetterTruckDropIntroState extends State<LetterTruckDropIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Scatter> _scatter;

  static const _gap = 8.0;
  static const _truckH = 96.0;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(28);
    _scatter = [
      for (var i = 0; i < widget.glyphs.length; i++)
        _Scatter(
          dx: (rng.nextDouble() - 0.5) * 140,
          dy: (rng.nextDouble() - 0.2) * 70,
          spin: (rng.nextDouble() - 0.5) * 1.2,
        ),
    ];
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onFinished();
      });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        widget.onFinished();
      } else {
        _ctrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double get _gridWidth {
    final cols = widget.columns;
    return cols * widget.cellWidth + (cols - 1) * _gap;
  }

  double get _gridHeight {
    final rows = (widget.glyphs.length / widget.columns).ceil().clamp(1, 99);
    return rows * widget.cellHeight + (rows - 1) * _gap;
  }

  Offset _slot(int index, Size area) {
    final col = index % widget.columns;
    final row = index ~/ widget.columns;
    final left = (area.width - _gridWidth) / 2;
    const top = _truckH + 12;
    // RTL: ilk harf (ا) sağ üstte.
    final visualCol = widget.rtl ? widget.columns - 1 - col : col;
    return Offset(
      left + visualCol * (widget.cellWidth + _gap),
      top + row * (widget.cellHeight + _gap),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = _truckH + 12 + _gridHeight + 8;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final area = Size(constraints.maxWidth, height);
              final t = _ctrl.value;
              final drive = Curves.easeOutCubic.transform(
                (t / 0.24).clamp(0.0, 1.0),
              );
              final tip = Curves.easeInOut.transform(
                ((t - 0.22) / 0.16).clamp(0.0, 1.0),
              );
              final truckX = -180 + (area.width * 0.5 + 40) * drive;
              final tipAngle = -0.55 * tip;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Hafif yol izi
                  Positioned(
                    left: 0,
                    right: 0,
                    top: _truckH - 18,
                    child: Opacity(
                      opacity: (1 - ((t - 0.35) / 0.2).clamp(0.0, 1.0)),
                      child: Container(
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E0D0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // Harfler
                  for (var i = 0; i < widget.glyphs.length; i++)
                    _letterLayer(
                      index: i,
                      t: t,
                      area: area,
                      truckX: truckX,
                      tipAngle: tipAngle,
                    ),
                  // Kamyon (harflerin üstünde görünmesin diye dump sonrası soluklaşır)
                  Positioned(
                    left: truckX,
                    top: 8,
                    child: Opacity(
                      opacity: (1 - ((t - 0.42) / 0.18).clamp(0.0, 1.0)),
                      child: Transform.rotate(
                        angle: tipAngle,
                        alignment: const Alignment(-0.2, 0.6),
                        child: const _CartoonTruck(),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _letterLayer({
    required int index,
    required double t,
    required Size area,
    required double truckX,
    required double tipAngle,
  }) {
    final glyph = widget.glyphs[index];
    final name =
        index < widget.names.length ? widget.names[index] : '';
    final n = widget.glyphs.length;
    final scatter = _scatter[index];

    // Kamyon kasasında istif
    final bedLocal = Offset(
      28 + (index % 5) * 14.0,
      10 + (index ~/ 5) * 8.0,
    );
    final bed = Offset(truckX, 8) +
        _rotate(bedLocal, tipAngle, const Offset(70, 70));

    // Ortaya dökülmüş yığın
    final pile = Offset(
      area.width / 2 - widget.cellWidth / 2 + scatter.dx,
      _truckH + 40 + scatter.dy,
    );

    // Son yuva
    final slot = _slot(index, area);

    // Fazlar
    final dumpStart = 0.26 + (index / n) * 0.08;
    final dumpT = Curves.easeIn.transform(
      ((t - dumpStart) / 0.14).clamp(0.0, 1.0),
    );
    final settleStart = 0.46 + (index / n) * 0.28;
    final settleT = Curves.easeOutBack.transform(
      ((t - settleStart) / 0.26).clamp(0.0, 1.0),
    );

    Offset pos;
    double rot;
    double scale;
    if (settleT > 0) {
      pos = Offset.lerp(pile, slot, settleT)!;
      rot = scatter.spin * (1 - settleT);
      scale = 0.55 + 0.45 * settleT;
    } else if (dumpT > 0) {
      pos = Offset.lerp(bed, pile, dumpT)!;
      rot = scatter.spin * dumpT;
      scale = 0.45 + 0.1 * dumpT;
    } else {
      pos = bed;
      rot = tipAngle * 0.3;
      scale = 0.42;
    }

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Transform.rotate(
        angle: rot,
        child: Transform.scale(
          scale: scale,
          child: _FlyingLetter(
            glyph: glyph,
            name: name,
            width: widget.cellWidth,
            height: widget.cellHeight,
          ),
        ),
      ),
    );
  }

  Offset _rotate(Offset local, double angle, Offset pivot) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    final x = local.dx - pivot.dx;
    final y = local.dy - pivot.dy;
    return Offset(
      pivot.dx + x * c - y * s,
      pivot.dy + x * s + y * c,
    );
  }
}

class _Scatter {
  const _Scatter({required this.dx, required this.dy, required this.spin});
  final double dx;
  final double dy;
  final double spin;
}

class _FlyingLetter extends StatelessWidget {
  const _FlyingLetter({
    required this.glyph,
    required this.name,
    required this.width,
    required this.height,
  });

  final String glyph;
  final String name;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MinikColors.mint),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            glyph,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: AssetPaths.arabicFontFamily,
              fontSize: 26,
              color: MinikColors.darkGreen,
              height: 1,
            ),
          ),
          if (name.isNotEmpty)
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: MinikColors.green,
              ),
            ),
        ],
      ),
    );
  }
}

/// Basit çizgi-film kamyonu (yeşil kabin + sarı kasa).
class _CartoonTruck extends StatelessWidget {
  const _CartoonTruck();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 88,
      child: Stack(
        children: [
          // Kasa
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              width: 78,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF2C94C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC9A227), width: 2),
              ),
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'ٱ ب ت',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: AssetPaths.arabicFontFamily,
                    fontSize: 12,
                    color: MinikColors.darkGreen,
                  ),
                ),
              ),
            ),
          ),
          // Kabin
          Positioned(
            left: 84,
            top: 14,
            child: Container(
              width: 52,
              height: 40,
              decoration: BoxDecoration(
                color: MinikColors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: const Alignment(0.2, -0.3),
                child: Container(
                  width: 22,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8E0F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          // Tekerlekler
          const Positioned(left: 22, top: 48, child: _Wheel()),
          const Positioned(left: 58, top: 48, child: _Wheel()),
          const Positioned(left: 100, top: 48, child: _Wheel()),
        ],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF777777), width: 3),
      ),
      child: const Center(
        child: CircleAvatar(radius: 3, backgroundColor: Color(0xFFBBBBBB)),
      ),
    );
  }
}
