import '../../data/models/quran_learning.dart';
import 'elifba_models.dart';
import 'elifba_reading.dart';

/// Tenvin ve med derslerine bol pratik ekler.
///
/// Kaynak JSON'da bu iki ders birkaç örnekle geçiştirilmiş. Burada hem kural
/// motorundan üretilen hece alıştırmaları hem de Kur'an Öğrenme Serisi'ndeki
/// kayıtlı örnekler ve gerçek Kur'an kelimeleri eklenir.
abstract final class ElifbaPracticeBridge {
  static List<ElifbaLessonPatch> patches(QuranLearningPack? pack) {
    return [
      ElifbaLessonPatch(
        titleContains: 'Tenvin',
        exactTitle: true,
        content: _tenvin(pack),
      ),
      ElifbaLessonPatch(
        titleContains: 'Med Harfleri',
        exactTitle: true,
        content: _med(pack),
      ),
      ElifbaLessonPatch(
        titleContains: 'Kalkale Harfleri',
        exactTitle: true,
        content: _kalkale(pack),
      ),
    ];
  }

  /// Hece alıştırmalarında kullanılan harfler: ince, kalın ve ra bir arada
  /// ki çocuk hem -en/-an farkını hem ra'nın kuralını duysun.
  static const _drillLetters = ['ب', 'ت', 'ص', 'ط', 'ر'];

  static const _tenvinMarks = [
    ElifbaReading.fathatayn,
    ElifbaReading.kasratayn,
    ElifbaReading.dammatayn,
  ];

  static const _tenvinNames = {
    ElifbaReading.fathatayn: 'iki üstün',
    ElifbaReading.kasratayn: 'iki esre',
    ElifbaReading.dammatayn: 'iki ötre',
  };

  // ---------------------------------------------------------------- tenvin

  static Map<String, dynamic> _tenvin(QuranLearningPack? pack) {
    final drills = [
      for (final letter in _drillLetters)
        for (final mark in _tenvinMarks) _drill(letter, mark),
    ];
    final recorded = _tenvinSyllables(pack);
    final words = _tenvinWords(pack);
    return {
      // Önce kural motorunun ürettiği heceler, sonra Kur'an serisinin
      // kayıtlı alıştırmaları "şimdi sen dene" adımında.
      'examples': drills,
      if (recorded.isNotEmpty) 'practice': recorded,
      'comparison': _tenvinComparison(),
      'comparison_pairs': [
        for (final mark in _tenvinMarks)
          {
            'question': 'ب$mark nasıl okunur?',
            'answers': [
              for (final option in _tenvinMarks)
                ElifbaReading.of('ب', option, withTag: false),
            ],
            'answer': ElifbaReading.of('ب', mark, withTag: false),
            'pair': _tenvinNames[mark],
          },
      ],
      if (words.isNotEmpty) ...{
        'word_examples': words,
        'word_section_title': 'Tenvinli Kelime Okuma',
        'word_section_instruction':
            'Kelimenin sonundaki çift harekeyi bul, sonuna n sesini ekleyerek oku.',
      },
      'quiz': _tenvinQuiz(),
    };
  }

  static Map<String, dynamic> _drill(String letter, String mark) {
    return {
      'text': '$letter$mark',
      'reading': ElifbaReading.of(letter, mark, withTag: false),
      'note': 'Sonunda n sesi var: ${_tenvinNames[mark]}.',
    };
  }

  /// Kısa hareke ile tenvini yan yana koyar: بَ / بً.
  static List<Map<String, dynamic>> _tenvinComparison() {
    const pairs = {
      ElifbaReading.fatha: ElifbaReading.fathatayn,
      ElifbaReading.kasra: ElifbaReading.kasratayn,
      ElifbaReading.damma: ElifbaReading.dammatayn,
    };
    return [
      for (final pair in pairs.entries) ...[
        {
          'text': 'ب${pair.key}',
          'reading': ElifbaReading.of('ب', pair.key, withTag: false),
        },
        {
          'text': 'ب${pair.value}',
          'reading': ElifbaReading.of('ب', pair.value, withTag: false),
        },
      ],
    ];
  }

  /// Kur'an serisindeki kayıtlı tenvin heceleri: بًا, تًا ...
  static List<Map<String, dynamic>> _tenvinSyllables(QuranLearningPack? pack) {
    final rows = <String, Map<String, dynamic>>{};
    for (final item in _tenvinSource(pack)) {
      if (_letterCount(item.arabic) > 2) continue;
      rows[item.arabic] = {
        'text': item.arabic,
        'reading': item.reading,
        'note': 'Sonunda n sesi var: ${_tenvinNames[item.mark]}.',
        'audio': item.audio,
      };
    }
    return rows.values.toList(growable: false);
  }

  /// Gerçek Kur'an kelimeleri; okunuşu olmayan kayıtlar kelime kartına
  /// alınmaz, çünkü çocuk okunuşu göremeden tekrar edemez.
  static List<Map<String, dynamic>> _tenvinWords(QuranLearningPack? pack) {
    final rows = <String, Map<String, dynamic>>{};
    for (final item in _tenvinSource(pack)) {
      if (_letterCount(item.arabic) <= 2 || item.reading.isEmpty) continue;
      rows[item.arabic] = {
        'word': item.arabic,
        'reading': item.reading,
        'meaning': item.meaning,
        'focus': 'Sonda ${_tenvinNames[item.mark]} var.',
        'audio': item.audio,
      };
    }
    return rows.values.toList(growable: false);
  }

  static List<_Source> _tenvinSource(QuranLearningPack? pack) {
    if (pack == null) return const [];
    final items = <_Source>[];
    void add(String arabic, String reading, String meaning, String? audio) {
      final mark = _tenvinMarks.where(arabic.contains).firstOrNull;
      if (mark == null) return;
      items.add(_Source(arabic, reading, meaning, audio ?? '', mark));
    }

    for (final haraka in pack.harakat) {
      for (final example in haraka.examples) {
        add(example.arabic, example.reading, '', example.audio);
      }
    }
    for (final word in pack.words) {
      add(word.arabic, word.reading, word.meaningTr, word.audio);
    }
    for (final lesson in pack.tajweed) {
      for (final example in lesson.examples) {
        add(example.arabic, '', example.focus, example.audio);
      }
    }
    return items;
  }

  static int _letterCount(String text) {
    var letters = 0;
    for (final rune in text.runes) {
      final isMark = (rune >= 0x064B && rune <= 0x0652) || rune == 0x0670;
      if (!isMark) letters += 1;
    }
    return letters;
  }

  static List<Map<String, dynamic>> _tenvinQuiz() {
    return [
      {
        'question': 'صً nasıl okunur?',
        'options': ['sen', 'san', 'sin'],
        'answer': 'san',
      },
      {
        'question': 'بٍ nasıl okunur?',
        'options': ['ben', 'bin', 'bun'],
        'answer': 'bin',
      },
      {
        'question': 'Tenvin kelimenin neresinde bulunur?',
        'options': ['Başında', 'Ortasında', 'Sonunda'],
        'answer': 'Sonunda',
      },
      {
        'question': 'Tenvin okunurken hangi ses eklenir?',
        'options': ['n', 'm', 'l'],
        'answer': 'n',
      },
    ];
  }

  // ------------------------------------------------------------------- med

  static Map<String, dynamic> _med(QuranLearningPack? pack) {
    final syllables = _medSyllables(pack);
    final words = _medWords(pack);
    return {
      // Uzun listeyi ikiye bölüyoruz: önce tanıtım, sonra alıştırma adımı.
      if (syllables.isNotEmpty) 'examples': syllables.take(9).toList(),
      if (syllables.length > 9) 'practice': syllables.skip(9).toList(),
      'comparison': _medComparison(),
      'blending': [
        {'text': 'بَ + ا', 'reading': 'bâ'},
      ],
      'comparison_pairs': [
        {
          'question': 'بَ ile بَا arasındaki fark nedir?',
          'answers': ['Ses uzar', 'Ses kısalır', 'Fark yok'],
          'answer': 'Ses uzar',
          'pair': 'Uzatma',
        },
        {
          'question': 'Ötre + vav hangi sesi verir?',
          'answers': ['â', 'î', 'û'],
          'answer': 'û',
          'pair': 'Med harfi',
        },
      ],
      if (words.isNotEmpty) ...{
        'word_examples': words,
        'word_section_title': 'Uzatmalı Kelime Okuma',
        'word_section_instruction':
            'Uzun sesi bir elif miktarı uzat, aceleye getirme.',
      },
      'quiz': _medQuiz(),
    };
  }

  /// Kur'an serisindeki uzatma alıştırmaları kayıtlı geldiği için sesleri
  /// olduğu gibi kullanılır: بَا, بِي, بُو ...
  static List<Map<String, dynamic>> _medSyllables(QuranLearningPack? pack) {
    if (pack == null) return const [];
    const notes = {
      'fatha_madd': 'Üstün + elif = â',
      'kasra_madd': 'Esre + ya = î',
      'damma_madd': 'Ötre + vav = û',
    };
    final rows = <String, Map<String, dynamic>>{};
    for (final haraka in pack.harakat) {
      final note = notes[haraka.id];
      if (note == null) continue;
      for (final example in haraka.examples) {
        rows[example.arabic] = {
          'text': example.arabic,
          'reading': example.reading,
          'note': note,
          'audio': example.audio ?? '',
        };
      }
    }
    return rows.values.toList(growable: false);
  }

  static List<Map<String, dynamic>> _medComparison() {
    return [
      {'text': 'بَ', 'reading': 'be'},
      {'text': 'بَا', 'reading': 'bâ'},
      {'text': 'بِ', 'reading': 'bi'},
      {'text': 'بِي', 'reading': 'bî'},
      {'text': 'بُ', 'reading': 'bu'},
      {'text': 'بُو', 'reading': 'bû'},
    ];
  }

  static List<Map<String, dynamic>> _medWords(QuranLearningPack? pack) {
    if (pack == null) return const [];
    final rows = <String, Map<String, dynamic>>{};
    void add(String arabic, String reading, String meaning, String? audio) {
      final found = _medIn(arabic);
      if (found.isEmpty || reading.isEmpty) return;
      rows[arabic] = {
        'word': arabic,
        'reading': reading,
        'meaning': meaning,
        'focus': 'Uzatma: ${found.join(' · ')}',
        'audio': audio ?? '',
      };
    }

    for (final word in pack.words) {
      add(word.arabic, word.reading, word.meaningTr, word.audio);
    }
    return rows.values.toList(growable: false);
  }

  /// Kelimedeki doğal uzatmaları bulur: üstün+elif, esre+ya, ötre+vav.
  static List<String> _medIn(String word) {
    const pairs = {
      ElifbaReading.fatha: 'ا',
      ElifbaReading.kasra: 'ي',
      ElifbaReading.damma: 'و',
    };
    final found = <String>[];
    final runes = word.runes.toList();
    for (var i = 0; i + 1 < runes.length; i++) {
      final mark = String.fromCharCode(runes[i]);
      final next = String.fromCharCode(runes[i + 1]);
      if (pairs[mark] != next) continue;
      final piece = '$mark$next';
      if (!found.contains(piece)) found.add(piece);
    }
    return found;
  }

  static List<Map<String, dynamic>> _medQuiz() {
    return [
      {
        'question': 'بِي nasıl okunur?',
        'options': ['bi', 'bî', 'bu'],
        'answer': 'bî',
      },
      {
        'question': 'Ötreden sonra gelen و ne yapar?',
        'options': ['Sesi uzatır', 'Sesi keser', 'Sesi çiftler'],
        'answer': 'Sesi uzatır',
      },
      {
        'question': 'Hangisi med harfi değildir?',
        'options': ['ا', 'و', 'ب'],
        'answer': 'ب',
      },
      {
        'question': 'مَالِكِ kelimesinde uzatmayı hangi harf sağlar?',
        'options': ['ا', 'ل', 'ك'],
        'answer': 'ا',
      },
    ];
  }

  // --------------------------------------------------------------- kalkale

  /// Yankılanan beş harf ve onlara en çok karıştırılan sakin komşuları.
  static const _qalqala = ['ق', 'ط', 'ب', 'ج', 'د'];
  static const _quietPairs = {'ق': 'ك', 'ط': 'ت', 'ب': 'ف', 'ج': 'ش', 'د': 'ز'};

  static Map<String, dynamic> _kalkale(QuranLearningPack? pack) {
    return {
      'examples': [
        for (final letter in _qalqala) _sakin(letter, yankili: true),
      ],
      'practice': [
        // Önce yankılanmayan sakin komşular, sonra aynı harflerin harekeli
        // hâli: kalkale yalnızca harf cezimliyken duyulur.
        for (final letter in _qalqala)
          _sakin(_quietPairs[letter]!, yankili: false),
        for (final letter in _qalqala) _harekeli(letter),
      ],
      'comparison': [
        for (final letter in _qalqala) ...[
          _sakin(letter, yankili: true),
          _sakin(_quietPairs[letter]!, yankili: false),
        ],
      ],
      'comparison_pairs': [
        for (final letter in _qalqala)
          {
            'question': '$letter${ElifbaReading.sukun} ile '
                '${_quietPairs[letter]}${ElifbaReading.sukun}: hangisi yankılanır?',
            'answers': [
              '$letter${ElifbaReading.sukun}',
              '${_quietPairs[letter]}${ElifbaReading.sukun}',
            ],
            'answer': '$letter${ElifbaReading.sukun}',
            'pair': 'Kalkale harfi',
          },
      ],
      'word_examples': _kalkaleWords(pack),
      'quiz': _kalkaleQuiz(),
    };
  }

  static Map<String, dynamic> _sakin(String letter, {required bool yankili}) {
    final reading = ElifbaReading.of(letter, ElifbaReading.sukun, withTag: false);
    return {
      'text': '$letter${ElifbaReading.sukun}',
      'reading': reading,
      'note': yankili
          ? 'Kalkale harfi: sesi hafifçe sekerek yankılanır.'
          : 'Kalkale harfi değil: ses yankılanmadan durur.',
    };
  }

  static Map<String, dynamic> _harekeli(String letter) {
    return {
      'text': '$letter${ElifbaReading.fatha}',
      'reading': ElifbaReading.of(letter, ElifbaReading.fatha, withTag: false),
      'note': 'Harf harekeli: burada yankı yok.',
    };
  }

  /// Sakin kalkale harfi taşıyan gerçek kelimeler (يَلِدْ, يُولَدْ ...).
  static List<Map<String, dynamic>> _kalkaleWords(QuranLearningPack? pack) {
    if (pack == null) return const [];
    final rows = <String, Map<String, dynamic>>{};
    for (final word in pack.words) {
      final found = _sakinQalqalaIn(word.arabic);
      if (found.isEmpty || word.reading.isEmpty) continue;
      rows[word.arabic] = {
        'word': word.arabic,
        'reading': word.reading,
        'meaning': word.meaningTr,
        'focus': 'Yankılanan harf: ${found.join(' · ')}',
        'audio': word.audio ?? '',
      };
    }
    return rows.values.toList(growable: false);
  }

  static List<String> _sakinQalqalaIn(String word) {
    final runes = word.runes.toList();
    final found = <String>[];
    for (var i = 1; i < runes.length; i++) {
      if (String.fromCharCode(runes[i]) != ElifbaReading.sukun) continue;
      final letter = String.fromCharCode(runes[i - 1]);
      if (!_qalqala.contains(letter)) continue;
      final piece = '$letter${ElifbaReading.sukun}';
      if (!found.contains(piece)) found.add(piece);
    }
    return found;
  }

  static List<Map<String, dynamic>> _kalkaleQuiz() {
    return [
      {
        'question': 'Kalkale harfleri hangi cümleyle hatırlanır?',
        'options': ['قُطْبُ جَدٍ', 'يَرْمَلُونَ', 'حُرُوفُ الْمَدّ'],
        'answer': 'قُطْبُ جَدٍ',
      },
      {
        'question': 'Hangi harf cezimliyken yankılanmaz?',
        'options': ['س', 'ق', 'د'],
        'answer': 'س',
      },
      {
        'question': 'قَدْ kelimesinde yankı hangi harfte duyulur?',
        'options': ['ق', 'د', 'İkisinde de'],
        'answer': 'د',
      },
      {
        'question': 'Kalkale harfi harekeliyken ne olur?',
        'options': ['Yankı duyulmaz', 'Yine yankılanır', 'Ses uzar'],
        'answer': 'Yankı duyulmaz',
      },
      {
        'question': 'Kalkale kaç harfte olur?',
        'options': ['3', '5', '7'],
        'answer': '5',
      },
    ];
  }
}

/// Kur'an paketinden gelen ham örnek: kelime mi hece mi olduğuna sonra
/// karar verilir.
class _Source {
  const _Source(this.arabic, this.reading, this.meaning, this.audio, this.mark);

  final String arabic;
  final String reading;
  final String meaning;
  final String audio;
  final String mark;
}
