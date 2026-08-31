import 'dart:math' as math;

import 'package:flutter/material.dart';

class TasbihBeadsView extends StatelessWidget {
  const TasbihBeadsView({
    super.key,
    required this.beadCount,
    required this.pulled,
    this.firstNumber = 1,
    this.maxNumber,
    this.onTap,
  });

  final int beadCount;
  final int pulled;
  final int firstNumber;
  final int? maxNumber;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final count = beadCount.clamp(1, 100);
    final drawn = pulled.clamp(0, count);
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(32),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFE8C56A), width: 3),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFBF0),
                  Color(0xFFFFF0C8),
                  Color(0xFFEAF7EE),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(drawn),
                tween: Tween(begin: 0.94, end: 1),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: CustomPaint(
                  painter: _CartoonTasbihPainter(
                    beadCount: count,
                    pulled: drawn,
                    firstNumber: firstNumber,
                    maxNumber: maxNumber ?? (firstNumber + count - 1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartoonTasbihPainter extends CustomPainter {
  const _CartoonTasbihPainter({
    required this.beadCount,
    required this.pulled,
    required this.firstNumber,
    required this.maxNumber,
  });

  final int beadCount;
  final int pulled;
  final int firstNumber;
  final int maxNumber;

  static const _candy = <Color>[
    Color(0xFF5EC8A0),
    Color(0xFFE8B84A),
    Color(0xFFFF8B6A),
    Color(0xFF6EC4E8),
    Color(0xFFC98BE0),
    Color(0xFFFFC85A),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width / 2 - 22;
    final ry = size.height / 2 - 22;
    const gap = 0.5;
    const start = math.pi / 2 + gap / 2;
    const sweep = 2 * math.pi - gap;
    final radius = (15.0 * (30 / math.max(beadCount, 8))).clamp(7.0, 17.0);
    final highlight = pulled - 1;

    _drawCord(canvas, Offset(cx, cy), rx, ry, radius);

    for (var i = 0; i < beadCount; i++) {
      final t = beadCount == 1 ? 0.5 : i / (beadCount - 1);
      final angle = start + sweep * t;
      final counted = i < pulled;
      final isNext = i == pulled && pulled < beadCount;
      var r = radius;
      if (counted && i == highlight) r *= 1.16;
      if (isNext) r *= 1.12;
      final inward = counted ? 0.08 : 0.0;
      final center = Offset(
        cx + rx * (1 - inward) * math.cos(angle),
        cy + ry * (1 - inward) * math.sin(angle),
      );
      _drawBead(
        canvas,
        center,
        r,
        counted ? const Color(0xFFC9B08A) : _candy[i % _candy.length],
        dimmed: counted,
        popped: isNext || i == highlight,
      );
      final label = firstNumber + i;
      if (label >= 1 && label <= maxNumber) {
        _drawNumber(canvas, center, r, label, dimmed: counted);
      }
    }

    _drawImame(canvas, Offset(cx, cy + ry), radius * 1.7);
  }

  void _drawCord(Canvas canvas, Offset c, double rx, double ry, double beadR) {
    final oval = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    canvas.drawOval(
      oval,
      Paint()
        ..color = const Color(0xFF5A3A18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(5, beadR * 0.42)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      oval,
      Paint()
        ..color = const Color(0xFFD7A04A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.2, beadR * 0.2)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawBead(
    Canvas canvas,
    Offset c,
    double r,
    Color color, {
    required bool dimmed,
    required bool popped,
  }) {
    final body = dimmed ? Color.lerp(color, const Color(0xFFBCA48A), 0.55)! : color;
    canvas.drawCircle(
      c.translate(r * 0.12, r * 0.22),
      r,
      Paint()..color = const Color(0x33000000),
    );
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.42, -0.48),
          radius: 1.05,
          colors: [
            Color.lerp(body, Colors.white, dimmed ? 0.18 : 0.62)!,
            body,
            Color.lerp(body, const Color(0xFF3A2410), dimmed ? 0.18 : 0.32)!,
          ],
          stops: const [0.0, 0.48, 1.0],
        ).createShader(rect),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.8, r * 0.18)
        ..color = const Color(0xFF2C1A0C),
    );
    if (!dimmed) {
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset(-r * 0.32, -r * 0.38),
          width: r * 0.38,
          height: r * 0.22,
        ),
        Paint()..color = const Color(0xCCFFFFFF),
      );
    }
    if (popped && !dimmed) {
      _drawSpark(canvas, c + Offset(r * 0.7, -r * 0.7), r * 0.28);
    }
  }

  void _drawNumber(
    Canvas canvas,
    Offset c,
    double r,
    int number, {
    required bool dimmed,
  }) {
    final digits = number.toString().length;
    final fontSize = (r * (digits == 1 ? 1.08 : digits == 2 ? 0.84 : 0.58))
        .clamp(6.0, 15.0);
    final painter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          fontFamily: 'NotoSans',
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1,
          color: dimmed ? const Color(0xFF4A3424) : const Color(0xFF1A1208),
          shadows: const [
            Shadow(color: Color(0xF2FFFFFF), offset: Offset(-1.1, 0)),
            Shadow(color: Color(0xF2FFFFFF), offset: Offset(1.1, 0)),
            Shadow(color: Color(0xF2FFFFFF), offset: Offset(0, -1.1)),
            Shadow(color: Color(0xF2FFFFFF), offset: Offset(0, 1.1)),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, c - Offset(painter.width / 2, painter.height / 2 + 0.4));
  }

  void _drawSpark(Canvas canvas, Offset c, double s) {
    final paint = Paint()..color = const Color(0xFFFFF2A8);
    final path = Path()
      ..moveTo(c.dx, c.dy - s)
      ..lineTo(c.dx + s * 0.22, c.dy - s * 0.22)
      ..lineTo(c.dx + s, c.dy)
      ..lineTo(c.dx + s * 0.22, c.dy + s * 0.22)
      ..lineTo(c.dx, c.dy + s)
      ..lineTo(c.dx - s * 0.22, c.dy + s * 0.22)
      ..lineTo(c.dx - s, c.dy)
      ..lineTo(c.dx - s * 0.22, c.dy - s * 0.22)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF2C1A0C),
    );
  }

  void _drawImame(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(
      c.translate(r * 0.1, r * 0.2),
      r,
      Paint()..color = const Color(0x33000000),
    );
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.45),
          radius: 1,
          colors: [
            Color(0xFF6FBF8C),
            Color(0xFF21684E),
            Color(0xFF123628),
          ],
        ).createShader(rect),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.2, r * 0.16)
        ..color = const Color(0xFF2C1A0C),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.62),
      -0.4,
      3.9,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, r * 0.18)
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFE8B84A),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(-r * 0.26, -r * 0.3),
        width: r * 0.48,
        height: r * 0.28,
      ),
      Paint()..color = const Color(0xCCFFFFFF),
    );

    final tasselTop = c + Offset(0, r * 0.95);
    final tasselPaint = Paint()..color = const Color(0xFFE8B84A);
    final tasselStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xFF2C1A0C);
    for (final dx in const [-8.0, 0.0, 8.0]) {
      final path = Path()
        ..moveTo(tasselTop.dx, tasselTop.dy)
        ..quadraticBezierTo(
          tasselTop.dx + dx,
          tasselTop.dy + r * 0.55,
          tasselTop.dx + dx * 0.7,
          tasselTop.dy + r * 1.05,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFC29739)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.2
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(tasselTop, r * 0.28, tasselPaint);
    canvas.drawCircle(tasselTop, r * 0.28, tasselStroke);
  }

  @override
  bool shouldRepaint(_CartoonTasbihPainter oldDelegate) {
    return oldDelegate.beadCount != beadCount ||
        oldDelegate.pulled != pulled ||
        oldDelegate.firstNumber != firstNumber ||
        oldDelegate.maxNumber != maxNumber;
  }
}
