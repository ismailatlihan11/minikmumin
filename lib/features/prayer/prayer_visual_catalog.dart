import '../../core/utils/json_map.dart';

enum PrayerKind { farz, sunnah, adab, done }

class PrayerVisualStep {
  const PrayerVisualStep({
    required this.id,
    required this.number,
    required this.title,
    required this.prompt,
    required this.image,
    required this.kind,
    this.jsonStepId,
    this.duaId,
    this.caption = '',
  });

  final String id;
  final int number;
  final String title;
  final String prompt;
  final String image;
  final PrayerKind kind;
  final String? jsonStepId;
  final String? duaId;
  final String caption;

  factory PrayerVisualStep.fromJson(Map<String, dynamic> json) {
    final jsonStepId = JsonMap.str(json['jsonStepId']);
    final duaId = JsonMap.str(json['duaId']);
    return PrayerVisualStep(
      id: JsonMap.str(json['id']),
      number: JsonMap.integer(json['number']),
      title: JsonMap.str(json['title']),
      prompt: JsonMap.str(json['prompt']),
      image: JsonMap.str(json['image']),
      kind: kindFrom(json['kind']),
      jsonStepId: jsonStepId.isEmpty ? null : jsonStepId,
      duaId: duaId.isEmpty ? null : duaId,
      caption: JsonMap.str(json['caption']),
    );
  }

  static PrayerKind kindFrom(dynamic value) {
    switch (JsonMap.str(value)) {
      case 'farz':
        return PrayerKind.farz;
      case 'sunnah':
        return PrayerKind.sunnah;
      case 'adab':
        return PrayerKind.adab;
      case 'done':
        return PrayerKind.done;
      default:
        return PrayerKind.adab;
    }
  }
}

class PrayerRakat {
  const PrayerRakat({
    required this.id,
    required this.title,
    required this.farz,
    required this.summary,
    required this.detail,
  });

  final String id;
  final String title;
  final int farz;
  final String summary;
  final String detail;

  factory PrayerRakat.fromJson(Map<String, dynamic> json) {
    return PrayerRakat(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      farz: JsonMap.integer(json['farz']),
      summary: JsonMap.str(json['summary']),
      detail: JsonMap.str(json['detail']),
    );
  }
}

class PrayerTip {
  const PrayerTip({
    required this.title,
    required this.image,
  });

  final String title;
  final String image;

  factory PrayerTip.fromJson(Map<String, dynamic> json) {
    return PrayerTip(
      title: JsonMap.str(json['title']),
      image: JsonMap.str(json['image']),
    );
  }
}

abstract final class PrayerVisualCatalog {
  static const steps = [
    PrayerVisualStep(
      id: 'niyet',
      number: 1,
      title: 'Niyet',
      prompt: 'Niyet ederek namaza başlarız.',
      image: 'assets/images/prayer/step01_niyet.png',
      kind: PrayerKind.adab,
      jsonStepId: 'intention',
    ),
    PrayerVisualStep(
      id: 'tekbir',
      number: 2,
      title: 'Tekbir',
      prompt: 'Tekbir ile namaza başlarız. Allahu ekber deriz.',
      image: 'assets/images/prayer/step02_tekbir.png',
      kind: PrayerKind.farz,
      jsonStepId: 'takbir',
      caption: 'Allahu ekber',
    ),
    PrayerVisualStep(
      id: 'subhaneke',
      number: 3,
      title: 'Sübhâneke',
      prompt: 'Sübhâneke duasını okuruz.',
      image: 'assets/images/prayer/step03_subhaneke.png',
      kind: PrayerKind.sunnah,
      jsonStepId: 'qiyam',
      duaId: 'subhaneke',
    ),
    PrayerVisualStep(
      id: 'euzu',
      number: 4,
      title: 'Eûzü - Besmele',
      prompt: 'Eûzü besmele çeker, Fâtiha’yı okuruz.',
      image: 'assets/images/prayer/step04_euzu.png',
      kind: PrayerKind.sunnah,
      jsonStepId: 'qiyam',
      duaId: 'besmele',
    ),
    PrayerVisualStep(
      id: 'sure',
      number: 5,
      title: 'Bir Sure',
      prompt: 'Fâtiha’dan sonra bir sure okuruz.',
      image: 'assets/images/prayer/step05_sure.png',
      kind: PrayerKind.sunnah,
      jsonStepId: 'qiyam',
      duaId: 'surah_112',
    ),
    PrayerVisualStep(
      id: 'ruku',
      number: 6,
      title: 'Rükû',
      prompt: 'Rükûya vardıktan sonra 3 kere Sübhâne Rabbiye’l-Azîm deriz.',
      image: 'assets/images/prayer/step06_ruku.png',
      kind: PrayerKind.farz,
      jsonStepId: 'ruku',
      duaId: 'ruku',
      caption: 'Sübhâne Rabbiye’l-Azîm',
    ),
    PrayerVisualStep(
      id: 'ruku_rise',
      number: 7,
      title: 'Rükûdan Kalkış',
      prompt: 'Rükûdan doğruluruz ve Semi‘allâhü limen hamideh deriz.',
      image: 'assets/images/prayer/step08_kiyam.png',
      kind: PrayerKind.farz,
      jsonStepId: 'ruku_rise',
      duaId: 'qiyam_after_ruku',
      caption: 'Semi‘allâhü limen hamideh',
    ),
    PrayerVisualStep(
      id: 'kiyam',
      number: 8,
      title: 'Kıyam',
      prompt: 'Kıyamda dururuz ve Rabbenâ lekel-hamd deriz.',
      image: 'assets/images/prayer/step08_kiyam.png',
      kind: PrayerKind.farz,
      jsonStepId: 'qiyam',
      caption: 'Rabbenâ lekel-hamd',
    ),
    PrayerVisualStep(
      id: 'secde1',
      number: 9,
      title: 'Secde (1)',
      prompt: 'İlk secdeye gidince 3 kere Sübhâne Rabbiye’l-A‘lâ deriz.',
      image: 'assets/images/prayer/step09_secde1.png',
      kind: PrayerKind.farz,
      jsonStepId: 'sujud',
      duaId: 'sujud',
      caption: 'Sübhâne Rabbiye’l-A‘lâ',
    ),
    PrayerVisualStep(
      id: 'secde2',
      number: 10,
      title: 'Secde (2)',
      prompt: 'İkinci secdeye gidince 3 kere Sübhâne Rabbiye’l-A‘lâ deriz.',
      image: 'assets/images/prayer/step10_secde2.png',
      kind: PrayerKind.farz,
      jsonStepId: 'sujud',
      duaId: 'sujud',
      caption: 'Sübhâne Rabbiye’l-A‘lâ',
    ),
    PrayerVisualStep(
      id: 'oturus',
      number: 11,
      title: 'Oturuş',
      prompt: 'Oturuşta Tahiyyat duası okuruz.',
      image: 'assets/images/prayer/step11_oturus.png',
      kind: PrayerKind.farz,
      jsonStepId: 'sitting',
      duaId: 'tahiyyat',
    ),
    PrayerVisualStep(
      id: 'salli',
      number: 12,
      title: 'Salli - Barik',
      prompt: 'Salli ve Barik dualarını okuruz.',
      image: 'assets/images/prayer/step12_salli.png',
      kind: PrayerKind.sunnah,
      jsonStepId: 'sitting',
      duaId: 'allahumme_salli',
    ),
    PrayerVisualStep(
      id: 'rabbena',
      number: 13,
      title: 'Rabbenâ Duaları',
      prompt: 'Rabbenâ dualarını okuruz.',
      image: 'assets/images/prayer/step13_rabbena.png',
      kind: PrayerKind.sunnah,
      jsonStepId: 'sitting',
      duaId: 'rabbena_atina',
    ),
    PrayerVisualStep(
      id: 'selam_sag',
      number: 14,
      title: 'Selam (Sağa)',
      prompt: 'Sağa selam veririz.',
      image: 'assets/images/prayer/step14_selam_sag.png',
      kind: PrayerKind.farz,
      jsonStepId: 'salam',
    ),
    PrayerVisualStep(
      id: 'selam_sol',
      number: 15,
      title: 'Selam (Sola)',
      prompt: 'Sola selam veririz.',
      image: 'assets/images/prayer/step15_selam_sol.png',
      kind: PrayerKind.farz,
      jsonStepId: 'salam',
    ),
    PrayerVisualStep(
      id: 'tamam',
      number: 16,
      title: 'Namaz Tamamlandı',
      prompt: 'Maşallah! Namazı tamamladık.',
      image: 'assets/images/prayer/step16_tamam.png',
      kind: PrayerKind.done,
    ),
  ];

  static const farzLabels = [
    'Kıyam',
    'Kıraat',
    'Rükû',
    'Secde',
    'Oturuş',
  ];

  static const farzIds = ['kiyam', 'sure', 'ruku', 'secde1', 'oturus'];

  static const duaList = [
    (id: 'surah_1', title: 'Fâtiha'),
    (id: 'surah_112', title: 'İhlâs'),
    (id: 'subhaneke', title: 'Sübhâneke'),
  ];

  static const tips = [
    PrayerTip(
      title: 'Vaktinde kıl',
      image: 'assets/images/prayer/prayer_icon_clock.png',
    ),
    PrayerTip(
      title: 'Temiz giyin',
      image: 'assets/images/prayer/prayer_icon_clean.png',
    ),
    PrayerTip(
      title: 'Kıbleye dön',
      image: 'assets/images/prayer/prayer_icon_qibla.png',
    ),
    PrayerTip(
      title: 'Kalbinle dur',
      image: 'assets/images/prayer/prayer_icon_heart.png',
    ),
  ];

  static const rakats = [
    PrayerRakat(
      id: 'fajr',
      title: 'Sabah',
      farz: 2,
      summary: '2 rekat farz',
      detail: '2 sünnet + 2 farz',
    ),
    PrayerRakat(
      id: 'dhuhr',
      title: 'Öğle',
      farz: 4,
      summary: '4 rekat farz',
      detail: '4 sünnet + 4 farz + 2 sünnet',
    ),
    PrayerRakat(
      id: 'asr',
      title: 'İkindi',
      farz: 4,
      summary: '4 rekat farz',
      detail: '4 sünnet + 4 farz',
    ),
    PrayerRakat(
      id: 'maghrib',
      title: 'Akşam',
      farz: 3,
      summary: '3 rekat farz',
      detail: '3 farz + 2 sünnet',
    ),
    PrayerRakat(
      id: 'isha',
      title: 'Yatsı',
      farz: 4,
      summary: '4 rekat farz',
      detail: '4 sünnet + 4 farz + 2 sünnet + 3 vitir',
    ),
  ];

  static List<PrayerVisualStep> resolveSteps(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return steps;
    return [for (final row in rows) PrayerVisualStep.fromJson(row)];
  }

  static List<PrayerTip> resolveTips(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return tips;
    return [for (final row in rows) PrayerTip.fromJson(row)];
  }

  static List<PrayerRakat> resolveRakats(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return rakats;
    return [for (final row in rows) PrayerRakat.fromJson(row)];
  }

  static List<({String id, String title})> resolveDuaList(
    List<Map<String, dynamic>> rows,
  ) {
    if (rows.isEmpty) return duaList;
    return [
      for (final row in rows)
        (id: JsonMap.str(row['id']), title: JsonMap.str(row['title'])),
    ];
  }

  static String imageForJsonStep(String id) {
    switch (id) {
      case 'intention':
        return 'assets/images/prayer/step01_niyet.png';
      case 'takbir':
        return 'assets/images/prayer/step02_tekbir.png';
      case 'qiyam':
        return 'assets/images/prayer/step08_kiyam.png';
      case 'ruku':
        return 'assets/images/prayer/step06_ruku.png';
      case 'ruku_rise':
        return 'assets/images/prayer/step07_ruku_rise.png';
      case 'sujud':
        return 'assets/images/prayer/step09_secde1.png';
      case 'sitting':
        return 'assets/images/prayer/step11_oturus.png';
      case 'salam':
        return 'assets/images/prayer/step14_selam_sag.png';
      default:
        return 'assets/images/prayer/prayer.png';
    }
  }
}
