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
            for (final step in PrayerVisualCatalog.orderGameSteps)
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
            final items =
                await context.read<ContentRepositories>().asma.getAll();
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
            final duas =
                await context.read<ContentRepositories>().duas.getAll();
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
    KidGame(
      title: 'Kıssa Sahneleri',
      blurb: 'Hikâyeyi sıraya koy',
      icon: Icons.auto_stories_rounded,
      color: MinikColors.lavender,
      open: (context) => _push(context, const StoryOrderGamePage()),
    ),
    KidGame(
      title: 'Peygamberi Tanı',
      blurb: 'Kısa tanıttan ismi seç',
      icon: Icons.star_rounded,
      color: MinikColors.peach,
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Peygamberi Tanı',
          accent: MinikColors.peach,
          load: (context) async {
            final items =
                await context.read<ContentRepositories>().prophets.getAll();
            final playable = items
                .where(
                  (item) => item.name.isNotEmpty && item.shortTitle.isNotEmpty,
                )
                .toList();
            return [
              for (final item in pickRounds(playable, 8))
                ChoiceQuestion(
                  prompt: 'Bu hangi peygamber?\n${item.shortTitle}',
                  options: pickOptions(
                    item.choiceName,
                    playable.map((row) => row.choiceName).toList(),
                  ),
                  correct: item.choiceName,
                ),
            ];
          },
        ),
      ),
    ),
    KidGame(
      title: 'Esmanın Anlamı',
      blurb: 'Anlama göre ismi seç',
      icon: Icons.light_mode_rounded,
      color: MinikColors.sky,
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Esmanın Anlamı',
          accent: MinikColors.sky,
          load: (context) async {
            final items =
                await context.read<ContentRepositories>().asma.getAll();
            final playable = items
                .where(
                  (item) => item.name.isNotEmpty && item.meaning.isNotEmpty,
                )
                .toList();
            return [
              for (final item in pickRounds(playable, 8))
                ChoiceQuestion(
                  prompt:
                      'Bu anlam hangi güzel isme ait?\n${_clip(item.meaning)}',
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
      title: 'Dua Meali',
      blurb: 'Meali oku, duayı seç',
      icon: Icons.chat_bubble_rounded,
      color: MinikColors.blush,
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Dua Meali',
          accent: MinikColors.blush,
          load: (context) async {
            final duas =
                await context.read<ContentRepositories>().duas.getAll();
            final playable = duas
                .where(
                  (dua) =>
                      dua.title.isNotEmpty && dua.meaning.trim().length >= 12,
                )
                .toList();
            return [
              for (final dua in pickRounds(playable, 8))
                ChoiceQuestion(
                  prompt: 'Bu meal hangi dua?\n${_clip(dua.meaning)}',
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
    KidGame(
      title: 'Namaz Duası',
      blurb: 'Namaz duasının adını seç',
      icon: Icons.mosque_outlined,
      color: MinikColors.butter,
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Namaz Duası',
          accent: MinikColors.butter,
          load: (context) async {
            final duas =
                await context.read<ContentRepositories>().duas.getPrayerDuas();
            final playable = duas
                .where(
                  (dua) =>
                      dua.title.isNotEmpty &&
                      dua.displayArabic.isNotEmpty &&
                      dua.displayArabic.length <= 180,
                )
                .toList();
            return [
              for (final dua in pickRounds(playable, 8))
                ChoiceQuestion(
                  prompt: 'Bu hangi namaz duası?',
                  arabicPrompt: dua.displayArabic,
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
    KidGame(
      title: 'Rekat Bilmece',
      blurb: 'Farz rekatı seç',
      icon: Icons.filter_3_rounded,
      color: MinikColors.pastelBlue,
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Rekat Bilmece',
          accent: MinikColors.pastelBlue,
          load: (context) async {
            final lesson =
                await context.read<ContentRepositories>().prayer.getLesson();
            final rakats = PrayerVisualCatalog.resolveRakats(lesson.rakats);
            return [
              for (final rakat in rakats)
                ChoiceQuestion(
                  prompt: '${rakat.title} namazının farzı kaç rekattır?',
                  options: pickOptions(
                    '${rakat.farz}',
                    rakats.map((row) => '${row.farz}').toList(),
                  ),
                  correct: '${rakat.farz}',
                ),
            ];
          },
        ),
      ),
    ),
    KidGame(
      title: 'Kelime Anlamı',
      blurb: 'Kur’an kelimesini tanı',
      icon: Icons.translate_rounded,
      color: MinikColors.lavender,
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Kelime Anlamı',
          accent: MinikColors.lavender,
          load: (context) async {
            final pack =
                await context.read<ContentRepositories>().quranLearning.load();
            final playable = pack.words
                .where(
                  (word) => word.arabic.isNotEmpty && word.meaningTr.isNotEmpty,
                )
                .toList();
            return [
              for (final word in pickRounds(playable, 8))
                ChoiceQuestion(
                  prompt: 'Bu kelimenin anlamı hangisi?',
                  arabicPrompt: word.arabic,
                  options: pickOptions(
                    word.meaningTr,
                    playable.map((row) => row.meaningTr).toList(),
                  ),
                  correct: word.meaningTr,
                ),
            ];
          },
        ),
      ),
    ),
    KidGame(
      title: 'Sureyi Tanı',
      blurb: 'Sure ismini seç',
      icon: Icons.menu_book_outlined,
      color: const Color(0xFFFFF1C2),
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Sureyi Tanı',
          accent: MinikColors.butter,
          load: (context) async {
            final pack =
                await context.read<ContentRepositories>().quranLearning.load();
            final playable = pack.surahs
                .where(
                  (surah) => surah.nameAr.isNotEmpty && surah.nameTr.isNotEmpty,
                )
                .toList();
            return [
              for (final surah in pickRounds(playable, 8))
                ChoiceQuestion(
                  prompt: 'Bu hangi sure?',
                  arabicPrompt: surah.nameAr,
                  options: pickOptions(
                    surah.nameTr,
                    playable.map((row) => row.nameTr).toList(),
                  ),
                  correct: surah.nameTr,
                ),
            ];
          },
        ),
      ),
    ),
    KidGame(
      title: 'Kalın mı İnce mi?',
      blurb: 'Harfin sesini ayırt et',
      icon: Icons.graphic_eq_rounded,
      color: MinikColors.peach,
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Kalın mı İnce mi?',
          accent: MinikColors.peach,
          load: (context) async {
            final pack =
                await context.read<ContentRepositories>().quranLearning.load();
            final heavy =
                pack.letters.where((item) => item.isHeavySound).toList();
            final light =
                pack.letters.where((item) => !item.isHeavySound).toList();
            final mixed = [
              ...pickRounds(heavy, 4),
              ...pickRounds(light, 4),
            ]..shuffle();
            return [
              for (final letter in mixed)
                ChoiceQuestion(
                  prompt: 'Bu harf kalın mı ince mi?',
                  arabicPrompt: letter.letter,
                  options: pickOptions(
                    letter.isHeavySound ? 'Kalın harf' : 'İnce harf',
                    const ['Kalın harf', 'İnce harf'],
                  ),
                  correct: letter.isHeavySound ? 'Kalın harf' : 'İnce harf',
                ),
            ];
          },
        ),
      ),
    ),
    KidGame(
      title: 'Farz mı Sünnet mi?',
      blurb: 'Abdest adımının hükmünü seç',
      icon: Icons.verified_rounded,
      color: MinikColors.mint,
      open: (context) => _push(
        context,
        ChoiceRoundPage(
          title: 'Farz mı Sünnet mi?',
          accent: MinikColors.mint,
          load: (context) async {
            final lesson =
                await context.read<ContentRepositories>().wudu.getLesson();
            final steps = WuduVisualCatalog.resolveSteps(lesson.visualSteps)
                .where((step) => step.kind != WuduKind.done)
                .toList();
            return [
              for (final step in pickRounds(steps, 8))
                ChoiceQuestion(
                  prompt: '${step.title}\nBu adım hangisi?',
                  options: pickOptions(
                    _wuduKindLabel(step.kind),
                    const ['Farz', 'Sünnet', 'Öğüt'],
                  ),
                  correct: _wuduKindLabel(step.kind),
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

String _clip(String text, [int max = 90]) {
  final trimmed = text.trim();
  if (trimmed.length <= max) return trimmed;
  return '${trimmed.substring(0, max).trim()}…';
}

String _wuduKindLabel(WuduKind kind) {
  switch (kind) {
    case WuduKind.farz:
      return 'Farz';
    case WuduKind.sunnah:
      return 'Sünnet';
    case WuduKind.adab:
      return 'Öğüt';
    case WuduKind.done:
      return '';
  }
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
