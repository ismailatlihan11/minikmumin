import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/constants/asset_paths.dart';

const kMushafParchment = Color(0xFFFBF3E2);
const kMushafParchmentDeep = Color(0xFFEDD9A3);
const kMushafGold = Color(0xFFC8A96E);
const kMushafGoldDeep = Color(0xFF9B7B4A);
const kMushafGreen = Color(0xFF1A4A2A);
const kMushafInk = Color(0xFF1C0F02);
const kMushafSajdahRed = Color(0xFFB42318);
const kMushafNight = Color(0xFF0A1A0F);

/// Parşömen sayfa: çift çerçeve, köşe süsü, kâğıt dokusu.
class MushafPageChrome extends StatelessWidget {
  const MushafPageChrome({
    super.key,
    required this.child,
    this.contentPadding = const EdgeInsets.fromLTRB(16, 10, 16, 8),
    this.compact = false,
  });

  final Widget child;
  final EdgeInsetsGeometry contentPadding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 6 : 10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: kMushafParchment),
          const CustomPaint(painter: _PaperTexturePainter(), size: Size.infinite),
          const CustomPaint(painter: _SpineShadowPainter(), size: Size.infinite),
          Padding(padding: contentPadding, child: child),
          const IgnorePointer(
            child: CustomPaint(
              painter: _MushafFramePainter(),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class MushafSurahUnwan extends StatelessWidget {
  const MushafSurahUnwan({
    super.key,
    required this.arabicName,
    required this.turkishName,
  });

  final String arabicName;
  final String turkishName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
      child: CustomPaint(
        painter: const _UnwanBorderPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(28, 14, 28, 12),
          child: Column(
            children: [
              if (arabicName.isNotEmpty)
                Text(
                  arabicName,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Color(0xFFF5E6C8),
                    fontSize: 24,
                    fontFamily: AssetPaths.arabicFontFamily,
                    height: 1.3,
                  ),
                ),
              if (arabicName.isNotEmpty && turkishName.isNotEmpty)
                const SizedBox(height: 4),
              if (turkishName.isNotEmpty)
                Text(
                  turkishName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kMushafGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MushafBismillahBanner extends StatelessWidget {
  /// Fâtiha 1:1 ile aynı Arapça (`kuran.json`).
  static const text = 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحٖیمِ';

  const MushafBismillahBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
      child: Row(
        children: [
          Expanded(child: _rule()),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: kMushafGreen,
                fontSize: 22,
                fontFamily: AssetPaths.arabicFontFamily,
                height: 1.8,
              ),
            ),
          ),
          Expanded(child: _rule()),
        ],
      ),
    );
  }

  Widget _rule() {
    return Column(
      children: [
        Container(
          height: 1.2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, kMushafGold, Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          height: 0.7,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                kMushafGoldDeep.withValues(alpha: 0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaperTexturePainter extends CustomPainter {
  const _PaperTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(11);
    final speckle = Paint()..style = PaintingStyle.fill;
    final count = (size.width * size.height / 280).clamp(80, 220).toInt();
    for (var i = 0; i < count; i++) {
      speckle.color = Color.fromRGBO(
        140 + rnd.nextInt(40),
        110 + rnd.nextInt(30),
        60,
        0.018 + rnd.nextDouble() * 0.03,
      );
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        0.4 + rnd.nextDouble() * 1.6,
        speckle,
      );
    }

    final wash = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x14EDD9A3),
          Color(0x00FBF3E2),
          Color(0x18E6C98A),
        ],
        stops: [0, 0.45, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wash);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpineShadowPainter extends CustomPainter {
  const _SpineShadowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black.withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, 18, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, 18, size.height), left);

    final right = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Colors.black.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(size.width - 18, 0, 18, size.height));
    canvas.drawRect(Rect.fromLTWH(size.width - 18, 0, 18, size.height), right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MushafFramePainter extends CustomPainter {
  const _MushafFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 6.0;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
      const Radius.circular(8),
    );

    final outer = Paint()
      ..color = kMushafGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2;
    canvas.drawRRect(r, outer);

    final gold = Paint()
      ..color = kMushafGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(r.deflate(3.2), gold);

    final inner = Paint()
      ..color = kMushafGreen.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(r.deflate(5.6), inner);

    const corner = 22.0;
    _drawCorner(canvas, const Offset(inset + 2, inset + 2), 0, corner);
    _drawCorner(canvas, Offset(size.width - inset - 2, inset + 2), math.pi / 2, corner);
    _drawCorner(
      canvas,
      Offset(size.width - inset - 2, size.height - inset - 2),
      math.pi,
      corner,
    );
    _drawCorner(canvas, Offset(inset + 2, size.height - inset - 2), -math.pi / 2, corner);
  }

  void _drawCorner(Canvas canvas, Offset origin, double rot, double arm) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(rot);

    final gold = Paint()
      ..color = kMushafGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = kMushafGoldDeep;

    canvas.drawLine(Offset.zero, Offset(arm, 0), gold);
    canvas.drawLine(Offset.zero, Offset(0, arm), gold);

    final petal = Path()
      ..moveTo(5, 5)
      ..quadraticBezierTo(14, 3, 18, 10)
      ..quadraticBezierTo(10, 14, 5, 5)
      ..close();
    canvas.drawPath(petal, Paint()..color = kMushafGold.withValues(alpha: 0.85));

    canvas.drawCircle(const Offset(8, 8), 2.2, fill);
    canvas.drawCircle(const Offset(8, 8), 3.4, gold);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UnwanBorderPainter extends CustomPainter {
  const _UnwanBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );

    canvas.drawRRect(rect, Paint()..color = kMushafGreen);

    final goldFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF245C38),
          Color(0xFF1A4A2A),
          Color(0xFF123520),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(rect.deflate(1.5), goldFill);

    final gold = Paint()
      ..color = kMushafGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(rect.deflate(1.2), gold);
    canvas.drawRRect(rect.deflate(4.2), gold..strokeWidth = 0.8);

    const midY = 7.0;
    final arch = Path()
      ..moveTo(18, midY + 8)
      ..quadraticBezierTo(size.width / 2, -2, size.width - 18, midY + 8);
    canvas.drawPath(
      arch,
      Paint()
        ..color = kMushafGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    _rosette(canvas, Offset(14, size.height / 2));
    _rosette(canvas, Offset(size.width - 14, size.height / 2));
  }

  void _rosette(Canvas canvas, Offset c) {
    final gold = Paint()
      ..color = kMushafGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(c, 5.5, gold);
    canvas.drawCircle(c, 2.2, Paint()..color = kMushafGold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
