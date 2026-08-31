import 'dart:math' as math;

import 'package:flutter/material.dart';

class TasbihBeadsView extends StatefulWidget {
  const TasbihBeadsView({
    super.key,
    required this.beadCount,
    required this.pulled,
    this.firstNumber = 1,
    this.maxNumber,
    this.burst = 0,
    this.onTap,
  });

  /// 0 = taneler yerinde kalır, 1 = her çekişte bir tane kadar imameye kayar.
  static const double beadSlide = 0.55;

  final int beadCount;
  final int pulled;
  final int firstNumber;
  final int? maxNumber;
  final double burst;
  final VoidCallback? onTap;

  @override
  State<TasbihBeadsView> createState() => _TasbihBeadsViewState();
}

class _TasbihBeadsViewState extends State<TasbihBeadsView> {
  var _animate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.beadCount.clamp(1, 100);
    final drawn = widget.pulled.clamp(0, count);
    final fade = (1 - widget.burst * 2.2).clamp(0.0, 1.0);
    return AspectRatio(
      aspectRatio: 1,
      child: Opacity(
        opacity: fade,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: widget.burst > 0.05 ? null : widget.onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFC4A36A), width: 2),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF6E7C8),
                    Color(0xFFE8D0A0),
                    Color(0xFFD9C08A),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 18),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: drawn.toDouble()),
                  duration: _animate && widget.burst <= 0.05
                      ? const Duration(milliseconds: 280)
                      : Duration.zero,
                  curve: Curves.easeOutCubic,
                  builder: (context, pulledAnim, _) {
                    return CustomPaint(
                      painter: _TesbihPainter(
                        beadCount: count,
                        pulled: pulledAnim,
                        firstNumber: widget.firstNumber,
                        maxNumber: widget.maxNumber ??
                            (widget.firstNumber + count - 1),
                        slide: TasbihBeadsView.beadSlide,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ZikrCelebrateBackdrop extends StatelessWidget {
  const ZikrCelebrateBackdrop({
    super.key,
    required this.progress,
    required this.beadCount,
  });

  final double progress;
  final int beadCount;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: _CelebratePainter(
          progress: progress.clamp(0, 1),
          beadCount: beadCount.clamp(1, 100),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

const _ambers = <Color>[
  Color(0xFFC47A2A),
  Color(0xFF8B4E1F),
  Color(0xFFD59A45),
  Color(0xFF6B3818),
  Color(0xFFB86A28),
  Color(0xFFA05822),
];

class _TesbihPainter extends CustomPainter {
  const _TesbihPainter({
    required this.beadCount,
    required this.pulled,
    required this.firstNumber,
    required this.maxNumber,
    required this.slide,
  });

  final int beadCount;
  final double pulled;
  final int firstNumber;
  final int maxNumber;
  final double slide;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 - 6;
    final rx = size.width / 2 - 24;
    final ry = size.height / 2 - 28;
    final radius = _beadRadius(rx, ry, beadCount);
    final imameR = radius * 1.55;
    final gap = ((imameR * 0.72 + radius * 0.95) / rx * 2).clamp(0.28, 0.58);
    final start = math.pi / 2 + gap / 2;
    final sweep = 2 * math.pi - gap;
    final pulledN = pulled.clamp(0.0, beadCount.toDouble());
    final highlight = pulledN.ceil() - 1;

    _drawRope(canvas, Offset(cx, cy), rx, ry, 0, 2 * math.pi, radius * 0.22);

    for (var i = 0; i < beadCount; i++) {
      final angle = _beadAngle(
        i: i,
        start: start,
        sweep: sweep,
        pulled: pulledN,
      );
      final counted = i < pulledN;
      final isNext = i == pulledN.floor() && pulledN < beadCount;
      var r = radius;
      if (counted && i == highlight) r *= 1.04;
      if (isNext) r *= 1.05;
      final center = Offset(
        cx + rx * math.cos(angle),
        cy + ry * math.sin(angle),
      );
      _paintTesbihBead(
        canvas,
        center,
        r,
        angle,
        _ambers[i % _ambers.length],
        dimmed: counted,
      );
      final label = firstNumber + i;
      if (label >= 1 && label <= maxNumber) {
        _drawNumber(canvas, center, r, label, dimmed: counted);
      }
      if ((isNext || i == highlight) && !counted) {
        _drawSpark(canvas, center + Offset(r * 0.55, -r * 0.7), r * 0.22);
      }
    }

    _drawImame(canvas, Offset(cx, cy + ry), imameR);
  }

  double _beadAngle({
    required int i,
    required double start,
    required double sweep,
    required double pulled,
  }) {
    final restT = beadCount == 1 ? 0.5 : i / (beadCount - 1);
    final rest = start + sweep * restT;
    final amount = slide.clamp(0.0, 1.0);
    if (amount <= 0 || beadCount <= 1) return rest;
    final spacing = sweep / (beadCount - 1);
    final packSpacing = spacing * (1 - amount * 0.7);
    final packedEnd = pulled * packSpacing;
    final double packed;
    if (i < pulled) {
      packed = start + i * packSpacing;
    } else {
      final remainCount = beadCount - pulled;
      final remainSweep = sweep - packedEnd;
      if (remainCount <= 1) {
        packed = start + packedEnd + remainSweep * 0.5;
      } else {
        packed = start + packedEnd + (i - pulled) / (remainCount - 1) * remainSweep;
      }
    }
    return rest + (packed - rest) * amount;
  }

  @override
  bool shouldRepaint(_TesbihPainter oldDelegate) {
    return oldDelegate.beadCount != beadCount ||
        oldDelegate.pulled != pulled ||
        oldDelegate.firstNumber != firstNumber ||
        oldDelegate.maxNumber != maxNumber ||
        oldDelegate.slide != slide;
  }
}

double _beadRadius(double rx, double ry, int beadCount) {
  final peri =
      math.pi * (3 * (rx + ry) - math.sqrt((3 * rx + ry) * (rx + 3 * ry)));
  return (peri / math.max(beadCount, 1) / 2.18).clamp(5.5, 18.0);
}

void _drawRope(
  Canvas canvas,
  Offset c,
  double rx,
  double ry,
  double start,
  double sweep,
  double hole,
) {
  const steps = 180;
  final base = Path();
  for (var s = 0; s <= steps; s++) {
    final t = s / steps;
    final a = start + sweep * t;
    final p = Offset(c.dx + rx * math.cos(a), c.dy + ry * math.sin(a));
    if (s == 0) {
      base.moveTo(p.dx, p.dy);
    } else {
      base.lineTo(p.dx, p.dy);
    }
  }
  canvas.drawPath(
    base,
    Paint()
      ..color = const Color(0x55201008)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
  );
  canvas.drawPath(
    base,
    Paint()
      ..color = const Color(0xFF4A2E14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round,
  );
  for (final phase in <double>[0, math.pi]) {
    final path = Path();
    for (var s = 0; s <= steps; s++) {
      final t = s / steps;
      final a = start + sweep * t;
      final p = Offset(c.dx + rx * math.cos(a), c.dy + ry * math.sin(a));
      final nx = ry * math.cos(a);
      final ny = rx * math.sin(a);
      final nLen = math.sqrt(nx * nx + ny * ny);
      final twist = math.sin(t * math.pi * 34 + phase) * 2.15;
      final q = Offset(p.dx + nx / nLen * twist, p.dy + ny / nLen * twist);
      if (s == 0) {
        path.moveTo(q.dx, q.dy);
      } else {
        path.lineTo(q.dx, q.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = phase == 0 ? const Color(0xFF2E1A0C) : const Color(0xFFD4B37A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = phase == 0 ? 2.4 : 1.35
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }
  canvas.drawPath(
    base,
    Paint()
      ..color = const Color(0x66F6E2B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = hole.clamp(1.1, 2.2)
      ..strokeCap = StrokeCap.round,
  );
}

void _paintTesbihBead(
  Canvas canvas,
  Offset c,
  double r,
  double angle,
  Color color, {
  required bool dimmed,
  bool smile = false,
}) {
  final body = dimmed ? Color.lerp(color, const Color(0xFF7A5A38), 0.35)! : color;
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(angle + math.pi / 2);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(1.4, 2.4), width: r * 1.35, height: r * 1.9),
    Paint()..color = const Color(0x33000000),
  );
  final oval = Rect.fromCenter(
    center: Offset.zero,
    width: r * 1.28,
    height: r * 1.82,
  );
  canvas.drawOval(
    oval,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.42),
        radius: 1.05,
        colors: [
          Color.lerp(body, const Color(0xFFFFE3B0), dimmed ? 0.12 : 0.45)!,
          body,
          Color.lerp(body, const Color(0xFF3A1C08), 0.42)!,
        ],
        stops: const [0.0, 0.46, 1.0],
      ).createShader(oval),
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(0, 0.4), width: r * 0.95, height: r * 1.45),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = Color.lerp(body, const Color(0xFF3A1C08), 0.35)!.withValues(alpha: 0.35),
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(0, -0.2), width: r * 0.55, height: r * 1.1),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55
      ..color = Color.lerp(body, const Color(0xFF5A3010), 0.2)!.withValues(alpha: 0.28),
  );
  canvas.drawOval(
    oval,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, r * 0.1)
      ..color = const Color(0xFF2A1608),
  );
  if (!smile) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 0.22, height: r * 0.16),
      Paint()..color = const Color(0xFF1A0C04),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 0.12, height: r * 0.08),
      Paint()..color = const Color(0xFFC4A36A),
    );
  }
  if (!dimmed) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-r * 0.18, -r * 0.42),
        width: r * 0.32,
        height: r * 0.48,
      ),
      Paint()..color = const Color(0x66FFFFFF),
    );
  }
  canvas.restore();
  if (smile) {
    _drawBeadSmile(canvas, c, r);
  }
}

void _drawBeadSmile(Canvas canvas, Offset c, double r) {
  final eyeR = (r * 0.13).clamp(1.8, 4.2);
  final eyeY = -r * 0.1;
  final eyeX = r * 0.22;
  final blush = Paint()..color = const Color(0x55E07050);
  canvas.drawCircle(c + Offset(-eyeX * 1.45, r * 0.06), r * 0.16, blush);
  canvas.drawCircle(c + Offset(eyeX * 1.45, r * 0.06), r * 0.16, blush);
  final eye = Paint()..color = const Color(0xFF1A0C04);
  canvas.drawCircle(c + Offset(-eyeX, eyeY), eyeR, eye);
  canvas.drawCircle(c + Offset(eyeX, eyeY), eyeR, eye);
  final glint = Paint()..color = const Color(0xEEFFFFFF);
  canvas.drawCircle(
    c + Offset(-eyeX - eyeR * 0.22, eyeY - eyeR * 0.28),
    eyeR * 0.38,
    glint,
  );
  canvas.drawCircle(
    c + Offset(eyeX - eyeR * 0.22, eyeY - eyeR * 0.28),
    eyeR * 0.38,
    glint,
  );
  canvas.drawArc(
    Rect.fromCenter(
      center: c + Offset(0, r * 0.08),
      width: r * 0.72,
      height: r * 0.58,
    ),
    0.35,
    math.pi - 0.7,
    false,
    Paint()
      ..color = const Color(0xFF1A0C04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (r * 0.11).clamp(1.8, 3.4)
      ..strokeCap = StrokeCap.round,
  );
}

void _drawNumber(
  Canvas canvas,
  Offset c,
  double r,
  int number, {
  required bool dimmed,
}) {
  final digits = number.toString().length;
  final fontSize = (r * (digits == 1 ? 0.92 : digits == 2 ? 0.72 : 0.52))
      .clamp(6.0, 14.0);
  final painter = TextPainter(
    text: TextSpan(
      text: '$number',
      style: TextStyle(
        fontFamily: 'NotoSans',
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        height: 1,
        color: dimmed ? const Color(0xFF4A3018) : const Color(0xFF1A0C04),
        shadows: const [
          Shadow(color: Color(0xF2FFE8C0), offset: Offset(-1, 0)),
          Shadow(color: Color(0xF2FFE8C0), offset: Offset(1, 0)),
          Shadow(color: Color(0xF2FFE8C0), offset: Offset(0, -1)),
          Shadow(color: Color(0xF2FFE8C0), offset: Offset(0, 1)),
        ],
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, c - Offset(painter.width / 2, painter.height / 2));
}

void _drawSpark(Canvas canvas, Offset c, double s) {
  final paint = Paint()..color = const Color(0xFFFFF2A8);
  final path = Path()
    ..moveTo(c.dx, c.dy - s)
    ..lineTo(c.dx + s * 0.2, c.dy - s * 0.2)
    ..lineTo(c.dx + s, c.dy)
    ..lineTo(c.dx + s * 0.2, c.dy + s * 0.2)
    ..lineTo(c.dx, c.dy + s)
    ..lineTo(c.dx - s * 0.2, c.dy + s * 0.2)
    ..lineTo(c.dx - s, c.dy)
    ..lineTo(c.dx - s * 0.2, c.dy - s * 0.2)
    ..close();
  canvas.drawPath(path, paint);
}

void _drawImame(Canvas canvas, Offset c, double r) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  final oval = Rect.fromCenter(center: Offset.zero, width: r * 1.15, height: r * 2.05);
  canvas.drawOval(
    oval.shift(const Offset(1.5, 3)),
    Paint()..color = const Color(0x33000000),
  );
  canvas.drawOval(
    oval,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 1,
        colors: [
          Color(0xFF5A3A22),
          Color(0xFF2A1810),
          Color(0xFF120C08),
        ],
      ).createShader(oval),
  );
  canvas.drawOval(
    oval,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = const Color(0xFF1A0C04),
  );
  canvas.drawArc(
    Rect.fromCenter(center: Offset.zero, width: r * 0.7, height: r * 0.7),
    0.2,
    2.4,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFD4B36A),
  );
  canvas.restore();

  final tasselTop = c + Offset(0, r * 1.05);
  for (var i = -2; i <= 2; i++) {
    final path = Path()
      ..moveTo(tasselTop.dx, tasselTop.dy)
      ..quadraticBezierTo(
        tasselTop.dx + i * 5.5,
        tasselTop.dy + r * 0.7,
        tasselTop.dx + i * 4.2,
        tasselTop.dy + r * 1.35 + i.abs() * 2,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = i.isEven ? const Color(0xFFB88A3A) : const Color(0xFF8A5A22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }
  canvas.drawCircle(tasselTop, r * 0.22, Paint()..color = const Color(0xFFD4B36A));
  canvas.drawCircle(
    tasselTop,
    r * 0.22,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = const Color(0xFF2A1608),
  );
}

class _CelebratePainter extends CustomPainter {
  const _CelebratePainter({
    required this.progress,
    required this.beadCount,
  });

  final double progress;
  final int beadCount;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOutCubic.transform(progress);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(255, 214, 90, 0.42 * (1 - t * 0.35)),
          Color.fromRGBO(33, 104, 78, 0.16 * (1 - t * 0.45)),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glow);

    final cx = size.width / 2;
    final cy = size.height * 0.46;
    final rx = size.width * 0.28;
    final ry = size.height * 0.18;
    const start = math.pi / 2 + 0.28;
    const sweep = 2 * math.pi - 0.55;
    final r = _beadRadius(rx, ry, beadCount).clamp(9.0, 18.0);

    for (var i = 0; i < beadCount; i++) {
      final u = beadCount == 1 ? 0.5 : i / (beadCount - 1);
      final angle = start + sweep * u;
      final rest = Offset(cx + rx * math.cos(angle), cy + ry * math.sin(angle));
      final rng = math.Random(i * 97 + 13);
      final fly = Offset(
        math.cos(angle + rng.nextDouble() * 0.9) * (80 + rng.nextDouble() * 260),
        math.sin(angle + rng.nextDouble() * 1.3) * (70 + rng.nextDouble() * 240) - t * 90,
      );
      final center = rest + fly * t;
      final spin = (rng.nextDouble() * 5 - 2.5) * t * math.pi;
      final fade = (1 - progress * 0.35).clamp(0.35, 1.0);
      canvas.saveLayer(
        Rect.fromCircle(center: center, radius: r * 2.6),
        Paint()..color = Color.fromRGBO(255, 255, 255, fade),
      );
      _paintTesbihBead(
        canvas,
        center,
        r * (1 + t * 0.12),
        angle + spin,
        _ambers[i % _ambers.length],
        dimmed: false,
        smile: true,
      );
      canvas.restore();
    }

    final rng = math.Random(21);
    for (var i = 0; i < 28; i++) {
      final a = rng.nextDouble() * math.pi * 2;
      final dist = (50 + rng.nextDouble() * 240) * t;
      final p = Offset(cx + math.cos(a) * dist, cy + math.sin(a) * dist - t * 40);
      final s = 3.0 + rng.nextDouble() * 5;
      canvas.drawCircle(
        p,
        s * (1 - t * 0.25),
        Paint()
          ..color = (i.isEven ? const Color(0xFFFFE08A) : const Color(0xFF7DCEA0))
              .withValues(alpha: (1 - t * 0.5).clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_CelebratePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.beadCount != beadCount;
}
