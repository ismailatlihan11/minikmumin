import 'package:flutter/material.dart';

import '../../core/utils/quran_font.dart';

const kMushafGold = Color(0xFFC8A96E);
const kMushafGoldDeep = Color(0xFF9B7B4A);
const kMushafGreen = Color(0xFF1A4A2A);
const kMushafInk = Color(0xFF1C0F02);
const kMushafSajdahRed = Color(0xFFB42318);
const kMushafNight = Color(0xFF0A1A0F);
const kMushafPage = Color(0xFFFBF6EA);
const kMushafPageBorder = Color(0xFFD8C9A3);
const kMushafPageLabel = Color(0xFF6B5A3A);

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
                  QuranFont.format(arabicName),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Color(0xFFF5E6C8),
                    fontSize: 24,
                    fontFamily: QuranFont.family,
                    fontFamilyFallback: QuranFont.fallback,
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
  static const text = QuranFont.basmala;

  const MushafBismillahBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
      child: Row(
        children: [
          Expanded(child: _rule()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              QuranFont.format(text),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: kMushafGreen,
                fontSize: 22,
                fontFamily: QuranFont.family,
                fontFamilyFallback: QuranFont.fallback,
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
