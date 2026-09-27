import '../../data/models/quran_learning.dart';
import 'elifba_models.dart';

/// Tecvid derslerini (18 ve sonrası) Kur'an Öğrenme Serisi'nin kayıtlı
/// örnekleri, kural açıklamaları ve hazır oyun sorularıyla besler.
///
/// Kaynak JSON'da bu dersler iki üç örnekle geçiliyordu. Buradaki eşleme
/// tablosu her Elifbâ dersini ilgili tecvid konularına bağlar; örnekler
/// kaydıyla birlikte geldiği için yeni ses üretmeye gerek kalmaz.
abstract final class ElifbaTajweedBridge {
  static List<ElifbaLessonPatch> patches(QuranLearningPack? pack) {
    if (pack == null) return const [];
    return [
      for (final topic in _topics)
        ElifbaLessonPatch(
          titleContains: topic.lessonTitle,
          exactTitle: true,
          content: _build(pack, topic),
        ),
      for (final topic in _wordTopics)
        ElifbaLessonPatch(
          titleContains: topic.lessonTitle,
          exactTitle: true,
          content: _words(pack, topic),
        ),
    ];
  }

  static const _topics = <_Topic>[
    _Topic(
      lessonTitle: 'İzhâr-ı Halkî',
      sources: ['tajweed_11'],
      rule: 'İzhâr',
      gameWords: ['izhâr'],
    ),
    _Topic(
      lessonTitle: 'İdğam',
      sources: [
        'tajweed_07',
        'tajweed_15',
        'tajweed_16',
        'tajweed_18',
        'tajweed_19'
      ],
      rule: 'İdğam',
      gameWords: ['idğâm', 'idgam'],
    ),
    _Topic(
      lessonTitle: 'İklâb',
      sources: ['tajweed_09'],
      rule: 'İklâb',
      gameWords: ['iklâb'],
    ),
    _Topic(
      lessonTitle: 'İhfâ',
      sources: ['tajweed_08'],
      rule: 'İhfâ',
      gameWords: ['ihfâ'],
    ),
    _Topic(
      lessonTitle: 'Mim Sâkin',
      sources: ['tajweed_09', 'tajweed_16', 'tajweed_18'],
      gameWords: ['mîm', 'mim'],
    ),
    _Topic(
      lessonTitle: 'Gunne',
      sources: ['tajweed_05', 'tajweed_16'],
      gameWords: ['gunne', 'geniz'],
    ),
    _Topic(
      lessonTitle: 'Ra Harfi: Kalın ve İnce Okunuş',
      sources: ['tajweed_13'],
      gameWords: ['râ ', 'ra harfi'],
    ),
    _Topic(
      lessonTitle: 'Lafzatullah (اللّٰه)',
      sources: ['tajweed_14'],
      gameWords: ['lafzatullah', 'lâm'],
    ),
    _Topic(
      lessonTitle: 'Vakıf ve İbtidâ',
      sources: ['tajweed_10'],
      gameWords: ['vakf', 'durmak', 'dur'],
    ),
    _Topic(
      lessonTitle: 'Durak İşaretleri',
      sources: ['tajweed_21'],
      gameWords: ['durak', 'işaret'],
    ),
    _Topic(
      lessonTitle: 'Zamir ve Uzatma Alışkanlığı',
      sources: ['tajweed_12'],
      gameWords: ['zamir'],
    ),
  ];

  /// Kelime dersleri Kur'an serisinin kayıtlı kelimelerini kullanır; her ders
  /// ayrı bir sûre/ayet aralığı alır ki aynı kelime iki derste tekrarlanmasın.
  static const _wordTopics = <_WordTopic>[
    _WordTopic(
      lessonTitle: 'Kelime Okumaya Geçiyorum',
      references: ['112:', '2:255', '1:1'],
      instruction: 'Kelimeyi önce parçala, sonra kesmeden oku.',
    ),
    _WordTopic(
      lessonTitle: "Kısa Kur'an Kelimeleriyle Pratik",
      references: ['1:2', '1:3', '1:4'],
      instruction: 'Fâtiha\'nın ilk ayetlerindeki kelimeleri tanı.',
    ),
    _WordTopic(
      lessonTitle: 'Fâtiha ile Uygulama',
      references: ['1:5', '1:6', '1:7'],
      instruction: 'Ayeti kelime kelime dinle, sonra birleştirerek oku.',
    ),
  ];

  static Map<String, dynamic> _words(QuranLearningPack pack, _WordTopic topic) {
    final rows = [
      for (final word in pack.words)
        if (topic.references.any(word.quranReference.startsWith))
          {
            'word': word.arabic,
            'reading': word.reading,
            'meaning': word.meaningTr,
            'focus': word.teachingNote.isEmpty
                ? word.quranReference
                : word.teachingNote,
            'audio': word.audio ?? '',
          },
    ];
    if (rows.isEmpty) return const {};
    return {
      'word_examples': rows,
      'word_section_title': 'Kelime Kelime Oku',
      'word_section_instruction': topic.instruction,
    };
  }

  static Map<String, dynamic> _build(QuranLearningPack pack, _Topic topic) {
    final lessons = [
      for (final id in topic.sources)
        ...pack.tajweed.where((lesson) => lesson.id == id),
    ];
    if (lessons.isEmpty) return const {};

    final examples = <Map<String, dynamic>>[];
    final rules = <Map<String, dynamic>>[];
    for (final lesson in lessons) {
      rules.add({'name': lesson.title, 'meaning': lesson.shortDescription});
      for (final example in lesson.examples) {
        examples.add({
          'text': example.arabic,
          'focus': example.focus,
          'note': '${lesson.title} · ${example.reference}',
          if (topic.rule.isNotEmpty) 'rule': topic.rule,
          'audio': example.audio ?? '',
        });
      }
    }

    // İlk yarısı tanıtım, kalanı "şimdi sen dene" adımına gider.
    final split = examples.length > 8 ? 8 : examples.length;
    return {
      'examples': examples.take(split).toList(growable: false),
      if (examples.length > split)
        'practice': examples.skip(split).toList(growable: false),
      'rules': rules,
      'quiz': _quiz(pack, topic),
    };
  }

  /// Kur'an serisindeki hazır oyun soruları; konuyla ilgili olanlar bu dersin
  /// mini testine eklenir.
  static List<Map<String, dynamic>> _quiz(
    QuranLearningPack pack,
    _Topic topic,
  ) {
    final words = [
      ...topic.gameWords,
      if (topic.rule.isNotEmpty) topic.rule.toLowerCase(),
    ];
    final rows = <Map<String, dynamic>>[];
    for (final game in pack.games) {
      final haystack =
          '${game.question} ${game.options.join(' ')} ${game.correctAnswer}'
              .toLowerCase();
      if (!words.any(haystack.contains)) continue;
      if (game.options.length < 2 || game.correctAnswer.isEmpty) continue;
      rows.add({
        'question': game.question,
        'options': game.options,
        'answer': game.correctAnswer,
      });
    }
    return rows;
  }
}

class _Topic {
  const _Topic({
    required this.lessonTitle,
    required this.sources,
    this.rule = '',
    this.gameWords = const [],
  });

  final String lessonTitle;
  final List<String> sources;

  /// Dolu olduğunda örneklere kural etiketi eklenir ve derste "hangi kural
  /// gizlenmiş?" oyunu açılır.
  final String rule;
  final List<String> gameWords;
}

class _WordTopic {
  const _WordTopic({
    required this.lessonTitle,
    required this.references,
    required this.instruction,
  });

  final String lessonTitle;
  final List<String> references;
  final String instruction;
}
