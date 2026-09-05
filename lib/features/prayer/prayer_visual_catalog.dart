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
    this.extraDuaIds = const [],
    this.caption = '',
    this.imageGirl = '',
    this.girlNote = '',
    this.motionFrames = const [],
    this.motionFramesGirl = const [],
    this.rakat = 1,
  });

  final String id;
  final int number;
  final String title;
  final String prompt;
  final String image;
  final PrayerKind kind;
  final String? jsonStepId;
  final String? duaId;
  final List<String> extraDuaIds;
  final String caption;
  final String imageGirl;
  final String girlNote;
  final List<String> motionFrames;
  final List<String> motionFramesGirl;
  final int rakat;

  List<String> get duaIds => [
        if (duaId != null && duaId!.isNotEmpty) duaId!,
        ...extraDuaIds,
      ];

  String imageFor({required bool girl}) {
    if (girl && imageGirl.isNotEmpty) return imageGirl;
    return image;
  }

  List<String> motionFramesFor({required bool girl}) {
    if (girl && motionFramesGirl.isNotEmpty) return motionFramesGirl;
    return motionFrames;
  }

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
      extraDuaIds: JsonMap.strings(json['extraDuaIds']),
      caption: JsonMap.str(json['caption']),
      imageGirl: JsonMap.str(json['imageGirl']),
      girlNote: JsonMap.str(json['girlNote']),
      motionFrames: JsonMap.strings(json['motion_frames']),
      motionFramesGirl: JsonMap.strings(json['motion_frames_girl']),
      rakat: JsonMap.integer(json['rakat'], 1),
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
      imageGirl: 'assets/images/prayer/step01_niyet_girl.png',
      girlNote: 'Kızlar namazda başlarını da örter.',
      kind: PrayerKind.adab,
      jsonStepId: 'intention',
    ),
    PrayerVisualStep(
      id: 'tekbir',
      number: 2,
      title: 'Tekbir',
      prompt: 'Tekbir ile namaza başlarız. Allahu ekber deriz.',
      image: 'assets/images/prayer/step02_tekbir.png',
      imageGirl: 'assets/images/prayer/step02_tekbir_girl.png',
      girlNote: 'Kızlar ellerini omuz hizasına kadar kaldırır.',
      kind: PrayerKind.farz,
      jsonStepId: 'takbir',
      caption: 'Allahu ekber',
      duaId: 'iftitah_tekbir',
      motionFrames: [
        'assets/images/prayer/step01_niyet.png',
        'assets/images/prayer/step02_tekbir.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step01_niyet_girl.png',
        'assets/images/prayer/step02_tekbir_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'subhaneke',
      number: 3,
      title: 'Sübhâneke',
      prompt: 'Sübhâneke duasını okuruz.',
      image: 'assets/images/prayer/step03_subhaneke.png',
      imageGirl: 'assets/images/prayer/step03_qiyam_girl.png',
      girlNote: 'Kızlar ellerini göğüs hizasında bağlar; sağ el sol elin üstündedir.',
      kind: PrayerKind.sunnah,
      jsonStepId: 'qiyam',
      duaId: 'subhaneke',
    ),
    PrayerVisualStep(
      id: 'euzu',
      number: 4,
      title: 'Eûzü - Besmele',
      prompt: 'Eûzü besmele çekeriz.',
      image: 'assets/images/prayer/step04_euzu.png',
      imageGirl: 'assets/images/prayer/step03_qiyam_girl.png',
      girlNote: 'Kızlar ellerini göğüs hizasında bağlar; sağ el sol elin üstündedir.',
      kind: PrayerKind.sunnah,
      jsonStepId: 'qiyam',
      duaId: 'euzu_besmele',
    ),
    PrayerVisualStep(
      id: 'fatiha',
      number: 5,
      title: 'Fâtiha',
      prompt: 'Birinci rekatta Fâtiha’yı okuruz.',
      image: 'assets/images/prayer/step04_euzu.png',
      imageGirl: 'assets/images/prayer/step03_qiyam_girl.png',
      girlNote: 'Kızlar ellerini göğüs hizasında bağlar; sağ el sol elin üstündedir.',
      kind: PrayerKind.farz,
      jsonStepId: 'qiyam',
      duaId: 'surah_1',
      rakat: 1,
    ),
    PrayerVisualStep(
      id: 'sure',
      number: 6,
      title: 'Bir Sure',
      prompt: 'Fâtiha’dan sonra bir sure okuruz.',
      image: 'assets/images/prayer/step05_sure.png',
      imageGirl: 'assets/images/prayer/step03_qiyam_girl.png',
      girlNote: 'Kızlar ellerini göğüs hizasında bağlar; sağ el sol elin üstündedir.',
      kind: PrayerKind.sunnah,
      jsonStepId: 'qiyam',
      duaId: 'surah_112',
    ),
    PrayerVisualStep(
      id: 'ruku',
      number: 7,
      title: 'Rükû',
      prompt: 'Rükûya Allahu ekber diyerek varırız. Sonra 3 kere Sübhâne Rabbiye’l-Azîm deriz.',
      image: 'assets/images/prayer/step06_ruku.png',
      imageGirl: 'assets/images/prayer/step06_ruku_girl.png',
      girlNote:
          'Kızlar rükûda biraz daha az eğilir; parmaklar bitişik dizlerin üzerindedir.',
      kind: PrayerKind.farz,
      jsonStepId: 'ruku',
      duaId: 'ruku',
      caption: 'Sübhâne Rabbiye’l-Azîm',
      motionFrames: [
        'assets/images/prayer/step08_kiyam.png',
        'assets/images/prayer/step06_ruku.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step08_kiyam_girl.png',
        'assets/images/prayer/step06_ruku_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'ruku_rise',
      number: 8,
      title: 'Rükûdan Kalkış',
      prompt: 'Rükûdan doğruluruz ve Semi‘allâhü limen hamideh deriz.',
      image: 'assets/images/prayer/step08_kiyam.png',
      imageGirl: 'assets/images/prayer/step08_kiyam_girl.png',
      kind: PrayerKind.farz,
      jsonStepId: 'ruku_rise',
      duaId: 'qiyam_after_ruku',
      caption: 'Semi‘allâhü limen hamideh',
      motionFrames: [
        'assets/images/prayer/step06_ruku.png',
        'assets/images/prayer/step07_ruku_rise.png',
        'assets/images/prayer/step08_kiyam.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step06_ruku_girl.png',
        'assets/images/prayer/step08_kiyam_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'kiyam',
      number: 9,
      title: 'Kıyam',
      prompt: 'Kıyamda dururuz ve Rabbenâ lekel-hamd deriz.',
      image: 'assets/images/prayer/step08_kiyam.png',
      imageGirl: 'assets/images/prayer/step08_kiyam_girl.png',
      kind: PrayerKind.farz,
      jsonStepId: 'qiyam',
      caption: 'Rabbenâ lekel-hamd',
      duaId: 'rabbena_lekel_hamd',
    ),
    PrayerVisualStep(
      id: 'secde1',
      number: 10,
      title: 'Secde (1)',
      prompt: 'Secdeye Allahu ekber diyerek gideriz. 3 kere Sübhâne Rabbiye’l-A‘lâ deriz. Secdeden kalkarken Allahu ekber deriz.',
      image: 'assets/images/prayer/step09_secde1.png',
      imageGirl: 'assets/images/prayer/step09_secde_girl.png',
      girlNote:
          'Kızlar secdede kollarını vücuda yakın tutar, daha derli toplu durur.',
      kind: PrayerKind.farz,
      jsonStepId: 'sujud',
      duaId: 'sujud',
      caption: 'Sübhâne Rabbiye’l-A‘lâ',
      motionFrames: [
        'assets/images/prayer/step08_kiyam.png',
        'assets/images/prayer/step09_secde1.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step08_kiyam_girl.png',
        'assets/images/prayer/step09_secde_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'secde2',
      number: 11,
      title: 'Secde (2)',
      prompt: 'İkinci secdeye Allahu ekber diyerek gideriz. 3 kere Sübhâne Rabbiye’l-A‘lâ deriz.',
      image: 'assets/images/prayer/step10_secde2.png',
      imageGirl: 'assets/images/prayer/step09_secde_girl.png',
      girlNote:
          'Kızlar secdede kollarını vücuda yakın tutar, daha derli toplu durur.',
      kind: PrayerKind.farz,
      jsonStepId: 'sujud',
      duaId: 'sujud',
      caption: 'Sübhâne Rabbiye’l-A‘lâ',
      rakat: 1,
      motionFrames: [
        'assets/images/prayer/step11_oturus.png',
        'assets/images/prayer/step10_secde2.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step11_oturus_girl.png',
        'assets/images/prayer/step09_secde_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'ikinci_rekata_kalkis',
      number: 12,
      title: 'İkinci Rekata Kalkış',
      prompt:
          'Birinci rekat bitti. Secdeden Allahu ekber diyerek ayağa kalkarız ve ikinci rekata başlarız.',
      image: 'assets/images/prayer/step08_kiyam.png',
      imageGirl: 'assets/images/prayer/step08_kiyam_girl.png',
      girlNote: 'Kızlar ellerini göğüs hizasında bağlar; sağ el sol elin üstündedir.',
      kind: PrayerKind.farz,
      jsonStepId: 'qiyam',
      duaId: 'iftitah_tekbir',
      caption: 'Allahu ekber',
      rakat: 1,
      motionFrames: [
        'assets/images/prayer/step10_secde2.png',
        'assets/images/prayer/step08_kiyam.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step09_secde_girl.png',
        'assets/images/prayer/step08_kiyam_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'fatiha_r2',
      number: 13,
      title: 'Fâtiha',
      prompt: 'İkinci rekatta Fâtiha’yı okuruz.',
      image: 'assets/images/prayer/step04_euzu.png',
      imageGirl: 'assets/images/prayer/step03_qiyam_girl.png',
      girlNote: 'Kızlar ellerini göğüs hizasında bağlar; sağ el sol elin üstündedir.',
      kind: PrayerKind.farz,
      jsonStepId: 'qiyam',
      duaId: 'surah_1',
      rakat: 2,
    ),
    PrayerVisualStep(
      id: 'sure_r2',
      number: 14,
      title: 'Bir Sure',
      prompt: 'İkinci rekatta Fâtiha’dan sonra bir sure okuruz.',
      image: 'assets/images/prayer/step05_sure.png',
      imageGirl: 'assets/images/prayer/step03_qiyam_girl.png',
      girlNote: 'Kızlar ellerini göğüs hizasında bağlar; sağ el sol elin üstündedir.',
      kind: PrayerKind.sunnah,
      jsonStepId: 'qiyam',
      duaId: 'surah_112',
      rakat: 2,
    ),
    PrayerVisualStep(
      id: 'ruku_r2',
      number: 15,
      title: 'Rükû',
      prompt: 'Rükûya Allahu ekber diyerek varırız. Sonra 3 kere Sübhâne Rabbiye’l-Azîm deriz.',
      image: 'assets/images/prayer/step06_ruku.png',
      imageGirl: 'assets/images/prayer/step06_ruku_girl.png',
      girlNote:
          'Kızlar rükûda biraz daha az eğilir; parmaklar bitişik dizlerin üzerindedir.',
      kind: PrayerKind.farz,
      jsonStepId: 'ruku',
      duaId: 'ruku',
      caption: 'Sübhâne Rabbiye’l-Azîm',
      rakat: 2,
      motionFrames: [
        'assets/images/prayer/step08_kiyam.png',
        'assets/images/prayer/step06_ruku.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step08_kiyam_girl.png',
        'assets/images/prayer/step06_ruku_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'ruku_rise_r2',
      number: 16,
      title: 'Rükûdan Kalkış',
      prompt: 'Rükûdan doğruluruz ve Semi‘allâhü limen hamideh deriz.',
      image: 'assets/images/prayer/step08_kiyam.png',
      imageGirl: 'assets/images/prayer/step08_kiyam_girl.png',
      kind: PrayerKind.farz,
      jsonStepId: 'ruku_rise',
      duaId: 'qiyam_after_ruku',
      caption: 'Semi‘allâhü limen hamideh',
      rakat: 2,
      motionFrames: [
        'assets/images/prayer/step06_ruku.png',
        'assets/images/prayer/step08_kiyam.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step06_ruku_girl.png',
        'assets/images/prayer/step08_kiyam_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'kiyam_r2',
      number: 17,
      title: 'Kıyam',
      prompt: 'Kıyamda dururuz ve Rabbenâ lekel-hamd deriz.',
      image: 'assets/images/prayer/step08_kiyam.png',
      imageGirl: 'assets/images/prayer/step08_kiyam_girl.png',
      kind: PrayerKind.farz,
      jsonStepId: 'qiyam',
      caption: 'Rabbenâ lekel-hamd',
      duaId: 'rabbena_lekel_hamd',
      rakat: 2,
    ),
    PrayerVisualStep(
      id: 'secde1_r2',
      number: 18,
      title: 'Secde (1)',
      prompt: 'Secdeye Allahu ekber diyerek gideriz. 3 kere Sübhâne Rabbiye’l-A‘lâ deriz. Secdeden kalkarken Allahu ekber deriz.',
      image: 'assets/images/prayer/step09_secde1.png',
      imageGirl: 'assets/images/prayer/step09_secde_girl.png',
      girlNote:
          'Kızlar secdede kollarını vücuda yakın tutar, daha derli toplu durur.',
      kind: PrayerKind.farz,
      jsonStepId: 'sujud',
      duaId: 'sujud',
      caption: 'Sübhâne Rabbiye’l-A‘lâ',
      rakat: 2,
      motionFrames: [
        'assets/images/prayer/step08_kiyam.png',
        'assets/images/prayer/step09_secde1.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step08_kiyam_girl.png',
        'assets/images/prayer/step09_secde_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'secde2_r2',
      number: 19,
      title: 'Secde (2)',
      prompt:
          'İkinci secdeye Allahu ekber diyerek gideriz. 3 kere Sübhâne Rabbiye’l-A‘lâ deriz. Secdeden Allahu ekber diyerek kalkar ve otururuz.',
      image: 'assets/images/prayer/step10_secde2.png',
      imageGirl: 'assets/images/prayer/step09_secde_girl.png',
      girlNote:
          'Kızlar secdede kollarını vücuda yakın tutar, daha derli toplu durur.',
      kind: PrayerKind.farz,
      jsonStepId: 'sujud',
      duaId: 'sujud',
      caption: 'Sübhâne Rabbiye’l-A‘lâ',
      rakat: 2,
      motionFrames: [
        'assets/images/prayer/step11_oturus.png',
        'assets/images/prayer/step10_secde2.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step11_oturus_girl.png',
        'assets/images/prayer/step09_secde_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'oturus',
      number: 20,
      title: 'Son Oturuş',
      prompt:
          'İkinci rekatın sonunda otururuz. Oturuşta Tahiyyat duası okuruz.',
      image: 'assets/images/prayer/step11_oturus.png',
      imageGirl: 'assets/images/prayer/step11_oturus_girl.png',
      girlNote: 'Kızlar oturuşta ayaklarını sağ tarafa yatırır.',
      kind: PrayerKind.farz,
      jsonStepId: 'sitting',
      duaId: 'tahiyyat',
      rakat: 2,
    ),
    PrayerVisualStep(
      id: 'salli',
      number: 21,
      title: 'Salli - Barik',
      prompt: 'Salli ve Barik dualarını okuruz.',
      image: 'assets/images/prayer/step12_salli.png',
      imageGirl: 'assets/images/prayer/step11_oturus_girl.png',
      girlNote: 'Kızlar oturuşta ayaklarını sağ tarafa yatırır.',
      kind: PrayerKind.sunnah,
      jsonStepId: 'sitting',
      duaId: 'allahumme_salli',
      extraDuaIds: const ['allahumme_barik'],
      rakat: 2,
    ),
    PrayerVisualStep(
      id: 'rabbena',
      number: 22,
      title: 'Rabbenâ Duaları',
      prompt: 'Rabbenâ dualarını okuruz.',
      image: 'assets/images/prayer/step13_rabbena.png',
      imageGirl: 'assets/images/prayer/step11_oturus_girl.png',
      girlNote: 'Kızlar oturuşta ayaklarını sağ tarafa yatırır.',
      kind: PrayerKind.sunnah,
      jsonStepId: 'sitting',
      duaId: 'rabbena_atina',
      extraDuaIds: const ['rabbena_gfirli'],
      rakat: 2,
    ),
    PrayerVisualStep(
      id: 'selam_sag',
      number: 23,
      title: 'Selam (Sağa)',
      prompt: 'Sağa selam veririz.',
      image: 'assets/images/prayer/step14_selam_sag.png',
      imageGirl: 'assets/images/prayer/step15_selam_sol_girl.png',
      girlNote: 'Kızlar oturuşta ayaklarını sağ tarafa yatırır.',
      kind: PrayerKind.farz,
      jsonStepId: 'salam',
      rakat: 2,
      motionFrames: [
        'assets/images/prayer/step11_oturus.png',
        'assets/images/prayer/step14_selam_sag.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step11_oturus_girl.png',
        'assets/images/prayer/step15_selam_sol_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'selam_sol',
      number: 24,
      title: 'Selam (Sola)',
      prompt: 'Sola selam veririz.',
      image: 'assets/images/prayer/step15_selam_sol.png',
      imageGirl: 'assets/images/prayer/step14_selam_sag_girl.png',
      girlNote: 'Kızlar oturuşta ayaklarını sağ tarafa yatırır.',
      kind: PrayerKind.sunnah,
      jsonStepId: 'salam',
      rakat: 2,
      motionFrames: [
        'assets/images/prayer/step14_selam_sag.png',
        'assets/images/prayer/step15_selam_sol.png',
      ],
      motionFramesGirl: [
        'assets/images/prayer/step15_selam_sol_girl.png',
        'assets/images/prayer/step14_selam_sag_girl.png',
      ],
    ),
    PrayerVisualStep(
      id: 'tamam',
      number: 25,
      title: 'Namaz Tamamlandı',
      prompt: 'Maşallah! İki rekatlık namazı tamamladık.',
      image: 'assets/images/prayer/step16_tamam.png',
      imageGirl: 'assets/images/prayer/step16_tamam_girl.png',
      kind: PrayerKind.done,
      rakat: 0,
    ),
  ];

  static List<PrayerVisualStep> get playableSteps => steps
      .where((step) => step.kind != PrayerKind.done)
      .toList(growable: false);

  static const teachingNote =
      'Bu bölümde iki rekatlık bir namaz öğreniyoruz. Birinci rekatın sonunda ayağa kalkarız; ikinci rekatın sonunda otururuz.';

  static const orderGameIds = [
    'niyet',
    'tekbir',
    'fatiha',
    'ruku',
    'secde1',
    'ikinci_rekata_kalkis',
    'sure_r2',
    'ruku_r2',
    'secde1_r2',
    'oturus',
    'selam_sag',
  ];

  static List<PrayerVisualStep> get orderGameSteps => [
        for (final id in orderGameIds)
          for (final step in playableSteps)
            if (step.id == id) step,
      ];

  static const farzLabels = [
    'Kıyam',
    'Kıraat',
    'Rükû',
    'Secde',
    'Oturuş',
  ];

  static const farzIds = ['kiyam', 'fatiha', 'ruku', 'secde1', 'oturus'];

  static const duaList = [
    (id: 'surah_1', title: 'Fâtiha'),
    (id: 'surah_112', title: 'İhlâs'),
    (id: 'subhaneke', title: 'Sübhaneke'),
    (id: 'tahiyyat', title: 'Tahiyyat'),
    (id: 'allahumme_salli', title: 'Salli'),
    (id: 'allahumme_barik', title: 'Barik'),
    (id: 'rabbena_atina', title: 'Rabbena Âtinâ'),
    (id: 'rabbena_gfirli', title: 'Rabbenağfir Lî'),
    (id: 'rabbena_lekel_hamd', title: 'Rabbenâ Lekel-Hamd'),
  ];

  static const tips = [
    PrayerTip(
      title: 'Temizlen',
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
      title: 'Niyet et',
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
    final fallbackById = {for (final step in steps) step.id: step};
    return [
      for (final row in rows)
        _withFallback(PrayerVisualStep.fromJson(row),
            fallbackById[JsonMap.str(row['id'])]),
    ];
  }

  static PrayerVisualStep _withFallback(
    PrayerVisualStep json,
    PrayerVisualStep? fallback,
  ) {
    if (fallback == null) return json;
    return PrayerVisualStep(
      id: json.id,
      number: json.number,
      title: json.title,
      prompt: json.prompt,
      image: json.image.isNotEmpty ? json.image : fallback.image,
      kind: json.kind,
      jsonStepId: json.jsonStepId ?? fallback.jsonStepId,
      duaId: json.duaId ?? fallback.duaId,
      extraDuaIds:
          json.extraDuaIds.isNotEmpty ? json.extraDuaIds : fallback.extraDuaIds,
      caption: json.caption.isNotEmpty ? json.caption : fallback.caption,
      imageGirl:
          json.imageGirl.isNotEmpty ? json.imageGirl : fallback.imageGirl,
      girlNote: json.girlNote.isNotEmpty ? json.girlNote : fallback.girlNote,
      motionFrames: json.motionFrames.isNotEmpty
          ? json.motionFrames
          : fallback.motionFrames,
      motionFramesGirl: json.motionFramesGirl.isNotEmpty
          ? json.motionFramesGirl
          : fallback.motionFramesGirl,
      rakat: json.rakat,
    );
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
