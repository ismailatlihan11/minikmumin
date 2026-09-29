import 'package:flutter/material.dart';

/// Two cupped palms raised side by side in dua; Material has no such glyph.
class DuaHandsIcon extends StatelessWidget {
  const DuaHandsIcon({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color ?? Colors.black;
    return Semantics(
      label: 'Dua',
      child: CustomPaint(
        size: Size.square(size),
        painter: _DuaHandsPainter(tint),
      ),
    );
  }
}

class _DuaHandsPainter extends CustomPainter {
  const _DuaHandsPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    canvas.saveLayer(const Rect.fromLTWH(0, 0, 24, 24), Paint());
    _hand(canvas);
    canvas.save();
    canvas.translate(24, 0);
    canvas.scale(-1, 1);
    _hand(canvas);
    canvas.restore();
    canvas.restore();
  }

  // Left hand in a 24×24 box: thumb outside, little finger against the other
  // hand. Finger gaps are cut out so the glyph works in a single colour.
  void _hand(Canvas canvas) {
    canvas.save();
    canvas.translate(11.6, 23.6);
    canvas.rotate(-0.06);
    canvas.translate(-11.6, -23.6);
    final fill = Paint()
      ..color = color
      ..isAntiAlias = true;
    // Index → little finger, each with its own rounded tip.
    const fingers = [
      (5.0, 6.65, 3.6),
      (6.65, 8.3, 1.9),
      (8.3, 9.95, 2.5),
      (9.95, 11.5, 4.4),
    ];
    for (final (left, right, top) in fingers) {
      canvas.drawRRect(
        RRect.fromLTRBR(left, top, right, 12, const Radius.circular(0.83)),
        fill,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(11.5, 23.6)
        ..lineTo(11.5, 10)
        ..lineTo(5.0, 10)
        ..cubicTo(4.9, 13.5, 5.4, 16.5, 6.4, 19.2)
        ..lineTo(6.6, 23.6)
        ..close(),
      fill,
    );
    canvas.drawLine(
      const Offset(5.8, 16.2),
      const Offset(2.3, 9.6),
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );

    final cut = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.6
      ..isAntiAlias = true;
    for (final (x, top) in const [(6.65, 3.6), (8.3, 2.5), (9.95, 4.4)]) {
      canvas.drawLine(Offset(x, top + 0.9), Offset(x, 10.4), cut);
    }
    canvas.drawPath(
      Path()
        ..moveTo(4.4, 11.6)
        ..cubicTo(4.9, 13.4, 5.6, 14.6, 6.6, 15.4),
      cut,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DuaHandsPainter old) => old.color != color;
}
