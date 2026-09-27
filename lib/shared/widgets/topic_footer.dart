import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'buttons.dart';
import 'minik_ui.dart';

/// Sıradaki konu ve ait olduğu bölüm başlığı.
typedef UpcomingTopic<T> = ({T item, String group});

/// Konu sayfalarının ortak alt kısmı: "Öğrendim" → "Öğrendin" kartı →
/// sıradaki konuya (bölüm değişiyorsa kutlama kartıyla) geçiş.
///
/// [onLearn] null ise sayfa ilerleme tutmuyordur; geçiş butonu hemen görünür.
class TopicFooter extends StatelessWidget {
  const TopicFooter({
    super.key,
    this.learned = false,
    this.onLearn,
    this.learnedText = 'Aferin, bu konuyu öğrendin!',
    required this.hasNext,
    required this.onNext,
    this.currentGroup,
    this.nextGroup,
    this.nextLabel = 'Sonraki konuya geç',
    this.backLabel = 'Konulara dön',
  });

  final bool learned;
  final VoidCallback? onLearn;
  final String learnedText;
  final bool hasNext;
  final VoidCallback onNext;
  final String? currentGroup;
  final String? nextGroup;
  final String nextLabel;
  final String backLabel;

  bool get _groupChanges =>
      hasNext &&
      currentGroup != null &&
      nextGroup != null &&
      currentGroup != nextGroup;

  @override
  Widget build(BuildContext context) {
    if (onLearn != null && !learned) {
      return PrimaryButton(label: 'Öğrendim', onPressed: onLearn);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onLearn != null) ...[
          LearnedBanner(text: learnedText),
          const SizedBox(height: AppSpacing.md),
        ],
        if (_groupChanges) ...[
          MinikCard(
            color: MinikColors.of(
              const Color(0xFFFFF6DC),
              const Color(0xFF3D3317),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: MinikColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '“$currentGroup” bölümündeki tüm konuları tamamladın! '
                    'Şimdi “$nextGroup” başlığına geçiyoruz.',
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: MinikColors.darkGreen,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: '$nextGroup bölümüne geç', onPressed: onNext),
        ] else if (hasNext)
          PrimaryButton(label: nextLabel, onPressed: onNext)
        else
          SecondaryButton(
            label: backLabel,
            onPressed: () => Navigator.maybePop(context),
          ),
      ],
    );
  }
}

class LearnedBanner extends StatelessWidget {
  const LearnedBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return MinikCard(
      color: MinikColors.of(const Color(0xFFE7F4EC), const Color(0xFF233128)),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: MinikColors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: MinikColors.darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
