import '../../data/models/quran_learning.dart';

/// "Harfler ve Şekilleri" dersi, Kur'an Öğrenme Serisi'ndeki aynı adlı
/// seviyenin (letter_forms) verisinden birebir üretilir. Böylece iki modül
/// aynı harf listesini paylaşır ve içerik JSON güncellemelerinde kaybolmaz.
abstract final class ElifbaLetterFormsLesson {
  /// JSON'daki ders id'leriyle çakışmayacak sabit kimlik.
  static const int id = 1001;

  static const String title = 'Harfler ve Şekilleri';

  /// Bu ders, macera JSON'undaki dar kapsamlı "Harflerin Kelimedeki
  /// Şekilleri" dersinin yerini alır; o ders haritadan çıkarılır.
  static const String replacesTitle = 'Harflerin Kelimedeki Şekilleri';

  static Map<String, dynamic>? build(QuranLearningPack? pack) {
    final letters = pack?.letters ?? const <QuranArabicLetter>[];
    if (letters.isEmpty) return null;
    final level = pack?.levels
        .where((item) => item.screen.trim() == 'letter_forms')
        .firstOrNull;
    final rows = [
      for (final letter in letters)
        {
          'letter': letter.letter,
          'name': letter.name,
          'sound': letter.approximateTurkishSound,
          'isolated': letter.forms.isolated,
          'initial': letter.forms.initial,
          'medial': letter.forms.medial,
          'final': letter.forms.finalForm,
          'connects': letter.connectsToNext,
          'audio': letter.audio ?? '',
        },
    ];
    return {
      'id': id,
      'title': title,
      'level': 'Başlangıç',
      'goal': level?.description.isNotEmpty ?? false
          ? level!.description
          : 'Harfin kelimedeki dört şekli: tek başına, başta, ortada, sonda.',
      'explanation':
          'Arap harfleri kelimenin neresinde durduğuna göre şekil değiştirir. '
              'Harfin sesi ve adı değişmez; sadece yazılışı değişir.',
      'character_message':
          'Harfler kelimeye girince şekil değiştiriyor. Hadi birlikte bakalım!',
      'letter_forms': rows,
      'interactive_activities': [
        {
          'type': 'listen_repeat',
          'title': 'Harfe dokun, adını dinle',
          'count': 5
        },
        {
          'type': 'find_rule',
          'title': 'Şekli hangi harfe ait, bul',
          'count': 4
        },
      ],
      'summary_points': const [
        'Her harfin tek başına, başta, ortada ve sonda yazılışı vardır.',
        'Şekil değişse de harfin adı aynı kalır.',
        'Bazı harfler kendinden sonraki harfe bağlanmaz.',
      ],
      'quiz': _quiz(rows),
      'mastery': const {
        'suggested_practice_items': 10,
        'quiz_pass_percent': 70,
        'retry_allowed': true,
      },
      'ui_learning_pattern': const {
        'show_large_arabic': true,
        'show_letter_name': true,
        'show_reading': true,
        'show_audio_button': true,
        'show_repeat_button': true,
        'allow_favorite_example': true,
      },
    };
  }

  /// Sorular harf verisinden üretilir; şıklar her zaman doğru cevabı içerir.
  static List<Map<String, dynamic>> _quiz(List<Map<String, dynamic>> rows) {
    final usable = [
      for (final row in rows)
        if ('${row['initial']}'.isNotEmpty && '${row['final']}'.isNotEmpty) row,
    ];
    if (usable.length < 4) return const [];
    final quiz = <Map<String, dynamic>>[];
    for (var i = 0; i < 4 && i < usable.length; i++) {
      final row = usable[(i * 5 + 1) % usable.length];
      final others = [
        for (final other in usable)
          if (other['letter'] != row['letter']) other,
      ];
      final slot = i.isEven ? 'initial' : 'final';
      final label = slot == 'initial' ? 'başta' : 'sonda';
      quiz.add({
        'question': '${row['name']} harfinin $label yazılışı hangisi?',
        'options': [
          '${row[slot]}',
          '${others[(i * 3) % others.length][slot]}',
          '${others[(i * 7 + 2) % others.length][slot]}',
        ],
        'answer': '${row[slot]}',
      });
    }
    quiz.add({
      'question': 'Harfin şekli değişince adı da değişir mi?',
      'options': const ['Hayır, adı aynı kalır', 'Evet, adı da değişir'],
      'answer': 'Hayır, adı aynı kalır',
    });
    return quiz;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
