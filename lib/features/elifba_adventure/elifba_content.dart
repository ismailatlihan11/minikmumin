import 'package:flutter/material.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../core/audio/audio_player_service.dart';
import '../../shared/widgets/favorite_button.dart';
import 'elifba_audio.dart';
import 'elifba_cards.dart';
import 'elifba_games.dart';
import 'elifba_models.dart';
import 'elifba_widgets.dart';

const _fatha = 'َ';
const _kasra = 'ِ';
const _damma = 'ُ';
const _shadda = 'ّ';

/// Türkçe hareke adı; şedde bölümlerinde ve oyunlarda ortak kullanılır.
String elifbaVowelLabel(String marked) {
  if (marked.contains(_fatha)) return 'Üstün';
  if (marked.contains(_kasra)) return 'Esre';
  if (marked.contains(_damma)) return 'Ötre';
  return '';
}

/// 📖 Kelime kartı: Arapça · okunuş · anlam · dikkat · dinle · tekrar · favori.
class ElifbaWordCard extends StatefulWidget {
  const ElifbaWordCard({
    super.key,
    required this.word,
    required this.audio,
    this.color = Colors.white,
  });

  final ElifbaWordExample word;
  final AudioPlayerService audio;
  final Color color;

  @override
  State<ElifbaWordCard> createState() => _ElifbaWordCardState();
}

class _ElifbaWordCardState extends State<ElifbaWordCard> {
  var _sayNow = false;

  String? get _path => ElifbaAudio.forExample(
        widget.word.text,
        audio: widget.word.audio,
        reading: widget.word.reading,
      );

  Future<void> _play() async {
    await ElifbaAudio.play(widget.audio, _path);
    if (mounted) setState(() => _sayNow = true);
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    return ElifbaSoftCard(
      color: widget.color,
      child: Column(
        children: [
          ElifbaArabicTap(
            text: word.text,
            fontSize: 44,
            onTap: _path == null ? null : _play,
          ),
          if (word.reading.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text('Okunuşu', textDirection: TextDirection.ltr),
            Text(
              word.reading,
              textDirection: TextDirection.ltr,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: MinikColors.gold),
            ),
          ],
          if (word.meaning.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Anlamı: ${word.meaning}',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
            ),
          ],
          if (word.focus.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MinikColors.butter,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'Dikkat: ${word.focus}',
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (_sayNow)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Şimdi sen oku!'),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElifbaListenButton(audio: widget.audio, path: _path),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _path == null ? null : _play,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Tekrar Et'),
                ),
              ),
              FavoriteButton(
                kind: 'elifba_example',
                id: word.text,
                title: [
                  word.text,
                  if (word.reading.isNotEmpty) word.reading,
                  if (word.meaning.isNotEmpty) word.meaning,
                ].join(' · '),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Hareke derslerinde tablodan sonra gelen "Kelime Okuma" bölümü.
class ElifbaWordSection extends StatelessWidget {
  const ElifbaWordSection({
    super.key,
    required this.words,
    required this.audio,
    this.title = '',
    this.instruction = '',
  });

  final List<ElifbaWordExample> words;
  final AudioPlayerService audio;
  final String title;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        ElifbaLessonHeader(
          title: title.isEmpty ? '📖 Kelime Okuma' : '📖 $title',
          subtitle: instruction,
        ),
        const SizedBox(height: 10),
        Text('${words.length} kelime örneği'),
        const SizedBox(height: 10),
        for (final word in words)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElifbaWordCard(word: word, audio: audio),
          ),
      ],
    );
  }
}

/// Kalın / ince / peltek derslerinde harfin fetha-esre-ötre hâlleri bir arada.
class ElifbaTripleFormTable extends StatelessWidget {
  const ElifbaTripleFormTable({
    super.key,
    required this.rows,
    required this.audio,
    this.title = '',
    this.note = '',
  });

  final List<ElifbaLetterRow> rows;
  final AudioPlayerService audio;
  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        if (title.isNotEmpty) ElifbaLessonHeader(title: title, subtitle: note),
        const SizedBox(height: 10),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TripleFormCard(row: row, audio: audio),
          ),
      ],
    );
  }
}

class _TripleFormCard extends StatelessWidget {
  const _TripleFormCard({required this.row, required this.audio});

  final ElifbaLetterRow row;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    final forms = <_FormCell>[
      if (row.fatha.isNotEmpty)
        _FormCell('Fetha (Üstün)', row.fatha, row.fathaReading, 'fatha'),
      if (row.kasra.isNotEmpty)
        _FormCell('Esre', row.kasra, row.kasraReading, 'kasra'),
      if (row.damma.isNotEmpty)
        _FormCell('Ötre', row.damma, row.dammaReading, 'damma'),
    ];
    return ElifbaSoftCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text('Harf'),
                  ElifbaArabicTap(
                    text: row.letter,
                    fontSize: 44,
                    onTap: () => ElifbaAudio.play(
                      audio,
                      ElifbaAudio.letterName(row.name) ??
                          ElifbaAudio.letterGlyph(row.letter),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  const Text('Harfin adı'),
                  Text(
                    row.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for (final form in forms)
                _FormTile(row: row, form: form, audio: audio),
            ],
          ),
          if (row.compare.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Karıştırma: ${row.compare} ile aynı değil.',
              textAlign: TextAlign.center,
            ),
          ],
          if (row.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(row.note, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

class _FormCell {
  const _FormCell(this.label, this.text, this.reading, this.haraka);

  final String label;
  final String text;
  final String reading;
  final String haraka;
}

class _FormTile extends StatelessWidget {
  const _FormTile({
    required this.row,
    required this.form,
    required this.audio,
  });

  final ElifbaLetterRow row;
  final _FormCell form;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    final path = ElifbaAudio.letterSound(row.name, haraka: form.haraka) ??
        ElifbaAudio.letterSound(row.letter, haraka: form.haraka);
    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: MinikColors.sky,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(form.label, style: const TextStyle(fontSize: 12)),
          ElifbaArabicTap(
            text: form.text,
            fontSize: 36,
            onTap: () => ElifbaAudio.play(audio, path),
          ),
          if (form.reading.isNotEmpty)
            Text(
              form.reading,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          const SizedBox(height: 4),
          IconButton(
            tooltip: 'Dinle',
            onPressed: path == null
                ? null
                : () => ElifbaAudio.play(audio, path),
            icon: const Icon(Icons.volume_up_rounded),
          ),
        ],
      ),
    );
  }
}

/// Şedde her zaman hareke ile: üstün / esre / ötre bölümleri ayrı ayrı.
class ElifbaShaddaSections extends StatelessWidget {
  const ElifbaShaddaSections({
    super.key,
    required this.tables,
    required this.audio,
    this.note = '',
  });

  final Map<String, List<ElifbaLetterRow>> tables;
  final AudioPlayerService audio;
  final String note;

  static const _titles = {
    'fetha': 'Şedde + Üstün',
    'kasra': 'Şedde + Esre',
    'damma': 'Şedde + Ötre',
  };

  static const _order = ['fetha', 'kasra', 'damma'];

  @override
  Widget build(BuildContext context) {
    final keys = [
      ..._order.where(tables.containsKey),
      ...tables.keys.where((key) => !_order.contains(key)),
    ];
    return Column(
      children: [
        if (note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElifbaSoftCard(
              color: MinikColors.butter,
              child: Text(note, textAlign: TextAlign.center),
            ),
          ),
        for (final key in keys) ...[
          ElifbaLetterTable(
            rows: tables[key] ?? const [],
            audio: audio,
            title: _titles[key] ?? key,
            // Şeddeli hecelerin kaydı iyi çıkmadığı için bu bölümde ses
            // düğmesi yok; çocuk kartı kendisi okur.
            allowListen: false,
            instruction: 'Şedde tek başına okunmaz; harekeyi söyle, '
                'sonra harfi iki kez oku.',
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

/// ⭐ Ra gibi duruma göre kalın/ince okunan harfler için özel kart.
class ElifbaSpecialLetterCard extends StatelessWidget {
  const ElifbaSpecialLetterCard({
    super.key,
    required this.item,
    required this.audio,
  });

  final ElifbaSpecialLetter item;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    return ElifbaSoftCard(
      color: MinikColors.butter,
      child: Column(
        children: [
          Text(
            '⭐ Özel Harf: ${item.name}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ElifbaArabicTap(
            text: item.letter,
            fontSize: 56,
            onTap: () => ElifbaAudio.play(
              audio,
              ElifbaAudio.letterName(item.name) ??
                  ElifbaAudio.letterGlyph(item.letter),
            ),
          ),
          if (item.classification.isNotEmpty) Text(item.classification),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FormsColumn(
                  title: 'Kalın okunur',
                  color: MinikColors.peach,
                  forms: item.thickWhen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FormsColumn(
                  title: 'İnce okunur',
                  color: MinikColors.mint,
                  forms: item.thinWhen,
                ),
              ),
            ],
          ),
          if (item.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(item.note, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

class _FormsColumn extends StatelessWidget {
  const _FormsColumn({
    required this.title,
    required this.color,
    required this.forms,
  });

  final String title;
  final Color color;
  final List<String> forms;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          for (final form in forms)
            Text(
              form,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: AssetPaths.arabicFontFamily,
                fontSize: 32,
              ),
            ),
          if (forms.isEmpty) const Text('—'),
        ],
      ),
    );
  }
}

class ElifbaRaTableView extends StatelessWidget {
  const ElifbaRaTableView({
    super.key,
    required this.rows,
    required this.audio,
  });

  final List<ElifbaRaRow> rows;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ElifbaSoftCard(
              color: row.isThick ? MinikColors.peach : MinikColors.mint,
              child: Row(
                children: [
                  ElifbaArabicTap(
                    text: row.form,
                    fontSize: 44,
                    onTap: () => ElifbaAudio.play(
                      audio,
                      ElifbaAudio.forMarked(row.form, name: row.name),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.reading,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        if (row.reason.isNotEmpty) Text(row.reason),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Genel tekrar dersinde ince / kalın / peltek tabloları.
class ElifbaCategoryTablesView extends StatelessWidget {
  const ElifbaCategoryTablesView({
    super.key,
    required this.tables,
    required this.audio,
    this.note = '',
  });

  final Map<String, List<ElifbaLetterRow>> tables;
  final AudioPlayerService audio;
  final String note;

  static const _titles = {
    'kalin_harfler': '🟠 Kalın Harfler',
    'peltek_harfler': '🔵 Peltek Harfler',
    'ince_harfler': '🟢 İnce Harfler',
  };

  static const _colors = {
    'kalin_harfler': MinikColors.peach,
    'peltek_harfler': MinikColors.sky,
    'ince_harfler': MinikColors.mint,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElifbaSoftCard(
              color: MinikColors.butter,
              child: Text(note, textAlign: TextAlign.center),
            ),
          ),
        for (final entry in tables.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElifbaSoftCard(
              color: _colors[entry.key] ?? MinikColors.mint,
              child: Column(
                children: [
                  Text(
                    _titles[entry.key] ?? entry.key,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final row in entry.value)
                        SizedBox(
                          width: 84,
                          child: ElifbaSoftCard(
                            onTap: () => ElifbaAudio.play(
                              audio,
                              ElifbaAudio.letterName(row.name) ??
                                  ElifbaAudio.letterGlyph(row.letter),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  row.letter,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontFamily: AssetPaths.arabicFontFamily,
                                    fontSize: 30,
                                  ),
                                ),
                                Text(
                                  row.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (entry.value.isNotEmpty &&
                      entry.value.first.memory.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      entry.value.first.memory,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: AssetPaths.arabicFontFamily,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ElifbaActivityList extends StatelessWidget {
  const ElifbaActivityList({super.key, required this.activities});

  final List<ElifbaActivity> activities;

  @override
  Widget build(BuildContext context) {
    return ElifbaSoftCard(
      color: MinikColors.lavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bugünün görevleri',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          for (final activity in activities)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${activity.emoji} ${activity.title}'
                '${activity.count > 0 ? ' · ${activity.count} tekrar' : ''}',
              ),
            ),
        ],
      ),
    );
  }
}

/// JSON'daki hazır soru-cevap çiftleri (comparison_pairs / comparison_game).
class ElifbaAskPairGame extends StatelessWidget {
  const ElifbaAskPairGame({
    super.key,
    required this.pair,
    required this.onAnswer,
  });

  final ElifbaAskPair pair;
  final ElifbaAnswer onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (pair.label.isNotEmpty)
          Text(
            pair.label,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: AssetPaths.arabicFontFamily,
              fontSize: 34,
            ),
          ),
        const SizedBox(height: 10),
        ElifbaChoiceRow(
          prompt: pair.question,
          options: pair.options,
          answer: pair.answer,
          onAnswer: onAnswer,
        ),
      ],
    );
  }
}

/// Şedde oyunu: önce şeddeli harfi bul, sonra hangi hareke ile okunduğunu seç.
class ElifbaShaddaHunt extends StatefulWidget {
  const ElifbaShaddaHunt({
    super.key,
    required this.word,
    required this.onAnswer,
  });

  final ElifbaWordExample word;
  final ElifbaAnswer onAnswer;

  @override
  State<ElifbaShaddaHunt> createState() => _ElifbaShaddaHuntState();
}

class _ElifbaShaddaHuntState extends State<ElifbaShaddaHunt> {
  var _found = false;
  String? _picked;

  /// Harf + üzerindeki işaretleri tek parça olarak kümeler.
  List<String> get _clusters {
    final out = <String>[];
    for (final rune in widget.word.text.runes) {
      final ch = String.fromCharCode(rune);
      final isMark = rune >= 0x064B && rune <= 0x0652 || rune == 0x0670;
      if (isMark && out.isNotEmpty) {
        out[out.length - 1] = '${out.last}$ch';
      } else if (ch.trim().isEmpty) {
        continue;
      } else {
        out.add(ch);
      }
    }
    return out;
  }

  String get _target =>
      _clusters.firstWhere((c) => c.contains(_shadda), orElse: () => '');

  @override
  Widget build(BuildContext context) {
    final target = _target;
    final vowel = elifbaVowelLabel(target);
    if (!_found) {
      return Column(
        children: [
          const Text('Şeddeli harfi bul!'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            textDirection: TextDirection.rtl,
            alignment: WrapAlignment.center,
            children: [
              for (final cluster in _clusters)
                InkWell(
                  onTap: () {
                    final correct = cluster == target && target.isNotEmpty;
                    if (correct) setState(() => _found = true);
                    widget.onAnswer(correct: correct);
                  },
                  child: Container(
                    width: 64,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MinikColors.mint),
                    ),
                    child: Text(
                      cluster,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: AssetPaths.arabicFontFamily,
                        fontSize: 34,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    }
    return Column(
      children: [
        ElifbaArabicTap(text: target, fontSize: 64),
        const SizedBox(height: 8),
        ElifbaChoiceRow(
          prompt: 'Şedde hangi hareke ile birlikte?',
          options: const ['Üstün', 'Esre', 'Ötre'],
          answer: vowel.isEmpty ? 'Üstün' : vowel,
          onAnswer: ({required bool correct}) {
            setState(() => _picked = correct ? 'ok' : 'retry');
            widget.onAnswer(correct: correct);
          },
        ),
        if (_picked == 'ok' && widget.word.reading.isNotEmpty)
          Text('${widget.word.text} → ${widget.word.reading}'),
      ],
    );
  }
}

/// İnce / kalın / peltek sürükle-bırak görevi; harfler JSON gruplarından gelir.
class ElifbaSortMission extends StatefulWidget {
  const ElifbaSortMission({
    super.key,
    required this.letters,
    required this.onAnswer,
    this.onFinished,
  });

  final List<String> letters;
  final ElifbaAnswer onAnswer;
  final VoidCallback? onFinished;

  @override
  State<ElifbaSortMission> createState() => _ElifbaSortMissionState();
}

class _ElifbaSortMissionState extends State<ElifbaSortMission> {
  var _index = 0;
  var _solved = 0;

  @override
  Widget build(BuildContext context) {
    final letters = widget.letters;
    if (letters.isEmpty) return const SizedBox.shrink();
    if (_index >= letters.length) {
      return ElifbaSoftCard(
        color: MinikColors.mint,
        child: Column(
          children: [
            Text('🎉 $_solved harfi doğru yerleştirdin!'),
            const SizedBox(height: 8),
            ElifbaPrimary(
              label: 'Devam',
              onPressed: widget.onFinished,
            ),
          ],
        ),
      );
    }
    final letter = letters[_index];
    return Column(
      children: [
        Text('${_index + 1} / ${letters.length}'),
        const SizedBox(height: 8),
        ElifbaSortDrop(
          key: ValueKey(letter),
          letter: letter,
          onAnswer: ({required bool correct}) {
            widget.onAnswer(correct: correct);
            if (!correct) return;
            setState(() {
              _solved += 1;
              _index += 1;
            });
          },
        ),
      ],
    );
  }
}

/// ✍️ Harfin kelimedeki dört şekli: tek başına, başta, ortada, sonda.
class ElifbaFormBoard extends StatelessWidget {
  const ElifbaFormBoard({
    super.key,
    required this.rows,
    required this.audio,
  });

  final List<ElifbaFormRow> rows;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElifbaFormCard(row: row, audio: audio),
          ),
      ],
    );
  }
}

class ElifbaFormCard extends StatelessWidget {
  const ElifbaFormCard({
    super.key,
    required this.row,
    required this.audio,
  });

  final ElifbaFormRow row;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    final path = ElifbaAudio.resolve(row.audio);
    return ElifbaSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElifbaArabicTap(
                text: row.letter,
                fontSize: 40,
                onTap: () => ElifbaAudio.play(audio, path),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (row.sound.isNotEmpty)
                      Text('Sesi: ${row.sound}'),
                    if (!row.connects)
                      const Text('Sonraki harfe bağlanmaz'),
                  ],
                ),
              ),
              IconButton(
                tooltip: '${row.name} sesini dinle',
                icon: const Icon(Icons.volume_up_rounded),
                onPressed: () => ElifbaAudio.play(audio, path),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ShapeCell(label: 'Tek başına', form: row.isolated),
              _ShapeCell(label: 'Başta', form: row.initial),
              _ShapeCell(label: 'Ortada', form: row.medial),
              _ShapeCell(label: 'Sonda', form: row.finalForm),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShapeCell extends StatelessWidget {
  const _ShapeCell({required this.label, required this.form});

  final String label;
  final String form;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$label: $form',
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: MinikColors.cream,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: [
              Text(
                form,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: AssetPaths.arabicFontFamily,
                  fontSize: 30,
                  color: MinikColors.darkGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎯 "Bu şekil hangi harfin?" — dört şekil dersinin mini oyunu.
class ElifbaFormHunt extends StatefulWidget {
  const ElifbaFormHunt({
    super.key,
    required this.rows,
    required this.onAnswer,
    this.onFinished,
    this.rounds = 4,
  });

  final List<ElifbaFormRow> rows;
  final ElifbaAnswer onAnswer;
  final VoidCallback? onFinished;
  final int rounds;

  @override
  State<ElifbaFormHunt> createState() => _ElifbaFormHuntState();
}

class _ElifbaFormHuntState extends State<ElifbaFormHunt> {
  var _index = 0;
  var _solved = 0;

  @override
  Widget build(BuildContext context) {
    final usable = [
      for (final row in widget.rows)
        if (row.initial.isNotEmpty && row.finalForm.isNotEmpty) row,
    ];
    if (usable.length < 3) return const SizedBox.shrink();
    final total = widget.rounds.clamp(1, usable.length);
    if (_index >= total) {
      return ElifbaSoftCard(
        color: MinikColors.mint,
        child: Column(
          children: [
            Text('🎉 $_solved şekli doğru buldun!'),
            const SizedBox(height: 8),
            ElifbaPrimary(label: 'Devam', onPressed: widget.onFinished),
          ],
        ),
      );
    }
    final target = usable[(_index * 6 + 2) % usable.length];
    final others = [
      for (final row in usable)
        if (row.letter != target.letter) row,
    ];
    final atStart = _index.isEven;
    final shape = atStart ? target.initial : target.finalForm;
    final options = <String>{
      target.name,
      others[(_index * 4) % others.length].name,
      others[(_index * 9 + 3) % others.length].name,
    }.toList();
    return Column(
      children: [
        Text('${_index + 1} / $total'),
        const SizedBox(height: 8),
        ElifbaArabicTap(text: shape, fontSize: 56),
        const SizedBox(height: 8),
        ElifbaChoiceRow(
          prompt: atStart
              ? 'Bu başta yazılış hangi harfin?'
              : 'Bu sonda yazılış hangi harfin?',
          options: options,
          answer: target.name,
          onAnswer: ({required bool correct}) {
            widget.onAnswer(correct: correct);
            if (!correct) return;
            setState(() {
              _solved += 1;
              _index += 1;
            });
          },
        ),
      ],
    );
  }
}
