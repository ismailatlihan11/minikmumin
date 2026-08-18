import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/minik_ui.dart';
import '../prayer/prayer_visual_catalog.dart';
import '../quran_learn/quran_learn_color_page.dart';
import '../quran_learn/quran_learn_memory_page.dart';
import '../wudu/wudu_visual_catalog.dart';
import 'choice_round_game.dart';
import 'combine_word_game.dart';
import 'order_game_page.dart';
import 'zikr_collect_page.dart';

class KidGame {
  const KidGame({
    required this.title,
    required this.blurb,
    required this.icon,
    required this.color,
    required this.open,
  });

  final String title;
  final String blurb;
  final IconData icon;
  final Color color;
  final void Function(BuildContext context) open;
}

List<KidGame> kidGames() {
  return [
    KidGame(
      title: 'Harfleri Boya',
      blurb: 'Parmağınla boya',
      icon: Icons.palette_rounded,
      color: const Color(0xFFF8E4D0),
      open: (context) => _push(context, const QuranLearnColorHubPage()),
    ),
    KidGame(
      title: 'Harf Eşleştir',
      blurb: 'Aynı iki harfi bul',
      icon: Icons.grid_view_rounded,
      color: const Color(0xFFD5E8F6),
      open: (context) => _push(context, const QuranLearnMemoryPage()),
    ),
    KidGame(
      title: 'Harfi Bul',
      blurb: 'Söylenen harfi seç',
      icon: Icons.search_rounded,
      color: const Color(0xFFD8EFE4),
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Harfi Bul',
          accent: MinikColors.mint,
          load: (context) async {
            final pack =
                await context.read<ContentRepositories>().quranLearning.load();
            final letters = pack.letters;
            return [
              for (final letter in pickRounds(letters, 8))
                ChoiceQuestion(
                  prompt: '${letter.name} harfini bul.',
                  options: pickOptions(
                    letter.letter,
                    letters.map((item) => item.letter).toList(),
                  ),
                  correct: letter.letter,
                  arabicOptions: true,
                ),
            ];
          },
        ),
      ),
    ),
    KidGame(
      title: 'Sesini Bul',
      blurb: 'Harekeyi tanı',
      icon: Icons.hearing_rounded,
      color: const Color(0xFFF7EBC4),
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Sesini Bul',
          accent: MinikColors.butter,
          load: (context) async {
            final pack =
                await context.read<ContentRepositories>().quranLearning.load();
            final pool = <({String arabic, String reading})>[
              for (final haraka in pack.harakat)
                for (final example in haraka.examples)
                  (arabic: example.arabic, reading: example.reading),
            ];
            return [
              for (final item in pickRounds(pool, 8))
                ChoiceQuestion(
                  prompt: '“${item.reading}” hangisi?',
                  options: pickOptions(
                    item.arabic,
                    pool.map((row) => row.arabic).toList(),
                  ),
                  correct: item.arabic,
                  arabicOptions: true,
                ),
            ];
          },
        ),
      ),
    ),
    KidGame(
      title: 'Kelimeyi Kur',
      blurb: 'Harfleri birleştir',
      icon: Icons.extension_rounded,
      color: const Color(0xFFE6E0F4),
      open: (context) => _push(context, const CombineWordGamePage()),
    ),
    KidGame(
      title: 'Abdest Sırası',
      blurb: 'Adımları sıraya koy',
      icon: Icons.water_drop_rounded,
      color: const Color(0xFFD7E7E6),
      open: (context) => _push(
        context,
        OrderGamePage(
          title: 'Abdest sırası',
          prompt: 'Abdest adımlarına doğru sırayla dokun.',
          items: [
            for (final step in WuduVisualCatalog.playableSteps)
              OrderGameItem(id: step.id, title: step.title, image: step.image),
          ],
        ),
      ),
    ),
    KidGame(
      title: 'Namaz Sırası',
      blurb: 'Namazı adım adım diz',
      icon: Icons.mosque_rounded,
      color: const Color(0xFFFFF1C2),
      open: (context) => _push(
        context,
        OrderGamePage(
          title: 'Namaz sırası',
          prompt: 'Namaz adımlarına doğru sırayla dokun.',
          items: [
            for (final step in PrayerVisualCatalog.playableSteps)
              OrderGameItem(id: step.id, title: step.title, image: step.image),
          ],
        ),
      ),
    ),
    KidGame(
      title: 'Zikirleri Topla',
      blurb: 'Meali oku, zikri seç',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFF6DDE3),
      open: (context) => _push(context, const ZikrCollectPage()),
    ),
    KidGame(
      title: 'Esma Eşleştir',
      blurb: 'Güzel isimleri tanı',
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFFD8EFE4),
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Esma Eşleştir',
          accent: MinikColors.mint,
          load: (context) async {
            final items = await context.read<ContentRepositories>().asma.getAll();
            final playable = items
                .where((item) => item.arabic.isNotEmpty && item.name.isNotEmpty)
                .toList();
            return [
              for (final item in pickRounds(playable, 8))
                ChoiceQuestion(
                  prompt: 'Bu güzel isim hangisi?',
                  arabicPrompt: item.arabic,
                  options: pickOptions(
                    item.name,
                    playable.map((row) => row.name).toList(),
                  ),
                  correct: item.name,
                ),
            ];
          },
        ),
      ),
    ),
    KidGame(
      title: 'Dua Kartı',
      blurb: 'Duanın adını seç',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFFF8E4D0),
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Dua Kartı',
          accent: MinikColors.peach,
          load: (context) async {
            final duas = await context.read<ContentRepositories>().duas.getAll();
            final playable = duas
                .where(
                  (dua) =>
                      dua.title.isNotEmpty &&
                      dua.arabic.isNotEmpty &&
                      dua.arabic.length <= 160,
                )
                .toList();
            return [
              for (final dua in pickRounds(playable, 8))
                ChoiceQuestion(
                  prompt: 'Bu hangi dua?',
                  arabicPrompt: dua.arabic,
                  options: pickOptions(
                    dua.title,
                    playable.map((row) => row.title).toList(),
                  ),
                  correct: dua.title,
                ),
            ];
          },
        ),
      ),
    ),
  ];
}

void _push(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

class KidGamesList extends StatelessWidget {
  const KidGamesList({super.key, required this.games});

  final List<KidGame> games;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final game in games)
          ContentTile(
            title: game.title,
            subtitle: game.blurb,
            color: MinikColors.surface,
            leading: _GameIcon(icon: game.icon, color: game.color),
            onTap: () => game.open(context),
          ),
      ],
    );
  }
}

class _GameIcon extends StatelessWidget {
  const _GameIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, size: 30, color: MinikColors.darkGreen),
    );
  }
}
