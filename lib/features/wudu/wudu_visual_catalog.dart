import '../../core/utils/json_map.dart';

enum WuduKind { farz, sunnah, adab, done }

class WuduVisualStep {
  const WuduVisualStep({
    required this.id,
    required this.number,
    required this.title,
    required this.prompt,
    required this.image,
    required this.kind,
    this.jsonStepId,
    this.motionFrames = const [],
  });

  final String id;
  final int number;
  final String title;
  final String prompt;
  final String image;
  final WuduKind kind;
  final String? jsonStepId;
  final List<String> motionFrames;

  factory WuduVisualStep.fromJson(Map<String, dynamic> json) {
    final jsonStepId = JsonMap.str(json['jsonStepId']);
    return WuduVisualStep(
      id: JsonMap.str(json['id']),
      number: JsonMap.integer(json['number']),
      title: JsonMap.str(json['title']),
      prompt: JsonMap.str(json['prompt']),
      image: JsonMap.str(json['image']),
      kind: kindFrom(json['kind']),
      jsonStepId: jsonStepId.isEmpty ? null : jsonStepId,
      motionFrames: JsonMap.strings(json['motion_frames']),
    );
  }

  static WuduKind kindFrom(dynamic value) {
    switch (JsonMap.str(value)) {
      case 'farz':
        return WuduKind.farz;
      case 'sunnah':
        return WuduKind.sunnah;
      case 'adab':
        return WuduKind.adab;
      case 'done':
        return WuduKind.done;
      default:
        return WuduKind.adab;
    }
  }
}

class WuduTip {
  const WuduTip({
    required this.title,
    required this.image,
  });

  final String title;
  final String image;

  factory WuduTip.fromJson(Map<String, dynamic> json) {
    return WuduTip(
      title: JsonMap.str(json['title']),
      image: JsonMap.str(json['image']),
    );
  }
}

abstract final class WuduVisualCatalog {
  static const steps = [
    WuduVisualStep(
      id: 'niyet',
      number: 1,
      title: 'Niyet Edelim',
      prompt: 'Allah rızası için abdest almaya niyet ederiz. “Niyet ettim Allah rızası için abdest almaya.”',
      image: 'assets/images/wudu/wudu_01_niyet.png',
      kind: WuduKind.adab,
    ),
    WuduVisualStep(
      id: 'besmele',
      number: 2,
      title: 'Besmele ile Başlayalım',
      prompt: 'Besmele ile başlarız. Eûzü billâhi mine\'ş-şeytânirracîm. Bismillâhirrahmânirrahîm.',
      image: 'assets/images/wudu/wudu_02_besmele.png',
      kind: WuduKind.sunnah,
    ),
    WuduVisualStep(
      id: 'eller',
      number: 3,
      title: 'Ellerimizi Yıkayalım',
      prompt: 'Ellerimizi bileklere kadar yıkarız. Parmak aralarını unutmayız.',
      image: 'assets/images/wudu/wudu_03_eller.png',
      kind: WuduKind.sunnah,
      jsonStepId: 'hands',
    ),
    WuduVisualStep(
      id: 'agiz',
      number: 4,
      title: 'Ağzımızı Temizleyelim',
      prompt: 'Sağ elimizle ağzımıza suyu üç kere verir ve çalkalarız.',
      image: 'assets/images/wudu/wudu_04_agiz.png',
      kind: WuduKind.sunnah,
      jsonStepId: 'mouth',
    ),
    WuduVisualStep(
      id: 'burun',
      number: 5,
      title: 'Burnumuzu Temizleyelim',
      prompt: 'Burnumuza suyu üç kere verir ve temizleriz.',
      image: 'assets/images/wudu/wudu_05_burun.png',
      kind: WuduKind.sunnah,
      jsonStepId: 'nose',
    ),
    WuduVisualStep(
      id: 'yuz',
      number: 6,
      title: 'Yüzümüzü Yıkayalım',
      prompt: 'Yüzümüzü üç kere yıkarız. Alından çeneye, bir kulaktan diğerine.',
      image: 'assets/images/wudu/wudu_06_yuz.png',
      kind: WuduKind.farz,
      jsonStepId: 'face',
    ),
    WuduVisualStep(
      id: 'sag_kol',
      number: 7,
      title: 'Sağ Kolumuzu Yıkayalım',
      prompt: 'Sağ kolumuzu dirsekle birlikte üç kere yıkarız.',
      image: 'assets/images/wudu/wudu_07_sag_kol.png',
      kind: WuduKind.farz,
      jsonStepId: 'arms',
    ),
    WuduVisualStep(
      id: 'sol_kol',
      number: 8,
      title: 'Sol Kolumuzu Yıkayalım',
      prompt: 'Sol kolumuzu dirsekle birlikte üç kere yıkarız.',
      image: 'assets/images/wudu/wudu_08_sol_kol.png',
      kind: WuduKind.farz,
      jsonStepId: 'arms',
    ),
    WuduVisualStep(
      id: 'bas',
      number: 9,
      title: 'Başımızı Mesh Edelim',
      prompt: 'Islak elimizle başımızı mesh ederiz.',
      image: 'assets/images/wudu/wudu_09_bas.png',
      kind: WuduKind.farz,
      jsonStepId: 'head',
    ),
    WuduVisualStep(
      id: 'kulaklar',
      number: 10,
      title: 'Kulaklarımızı Mesh Edelim',
      prompt: 'Islak elimizle kulaklarımızın içini ve dışını mesh ederiz.',
      image: 'assets/images/wudu/wudu_10_kulaklar.png',
      kind: WuduKind.sunnah,
      jsonStepId: 'ears',
    ),
    WuduVisualStep(
      id: 'sag_ayak',
      number: 11,
      title: 'Sağ Ayağımızı Yıkayalım',
      prompt: 'Sağ ayağımızı topuk ve parmak araları dahil yıkarız.',
      image: 'assets/images/wudu/wudu_11_sag_ayak.png',
      kind: WuduKind.farz,
      jsonStepId: 'feet',
    ),
    WuduVisualStep(
      id: 'sol_ayak',
      number: 12,
      title: 'Sol Ayağımızı Yıkayalım',
      prompt: 'Sol ayağımızı topuk ve parmak araları dahil yıkarız.',
      image: 'assets/images/wudu/wudu_12_sol_ayak.png',
      kind: WuduKind.farz,
      jsonStepId: 'feet',
    ),
    WuduVisualStep(
      id: 'tamam',
      number: 13,
      title: 'Abdestimiz Tamamlandı!',
      prompt: 'Maşallah! Abdestimizi öğrendik.',
      image: 'assets/images/wudu/wudu_13_tamam.png',
      kind: WuduKind.done,
    ),
  ];

  static const tips = [
    WuduTip(
      title: 'Suyu israf etmemek',
      image: 'assets/images/wudu/wudu_tip_water.png',
    ),
    WuduTip(
      title: 'Parmak aralarını yıkamak',
      image: 'assets/images/wudu/wudu_tip_fingers.png',
    ),
    WuduTip(
      title: 'Yüzüklerin altına su ulaştırmak',
      image: 'assets/images/wudu/wudu_tip_ring.png',
    ),
    WuduTip(
      title: 'Acele etmemek',
      image: 'assets/images/wudu/wudu_tip_time.png',
    ),
  ];

  static const farzIds = ['yuz', 'sag_kol', 'bas', 'sag_ayak'];

  static List<WuduVisualStep> get playableSteps =>
      steps.where((step) => step.kind != WuduKind.done).toList(growable: false);

  static List<WuduVisualStep> resolveSteps(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return steps;
    return [for (final row in rows) WuduVisualStep.fromJson(row)];
  }

  static List<WuduTip> resolveTips(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return tips;
    return [for (final row in rows) WuduTip.fromJson(row)];
  }

  static String imageForJsonStep(String id) {
    switch (id) {
      case 'hands':
        return 'assets/images/wudu/wudu_03_eller.png';
      case 'mouth':
        return 'assets/images/wudu/wudu_04_agiz.png';
      case 'nose':
        return 'assets/images/wudu/wudu_05_burun.png';
      case 'face':
        return 'assets/images/wudu/wudu_06_yuz.png';
      case 'arms':
        return 'assets/images/wudu/wudu_07_sag_kol.png';
      case 'head':
        return 'assets/images/wudu/wudu_09_bas.png';
      case 'ears':
        return 'assets/images/wudu/wudu_10_kulaklar.png';
      case 'feet':
        return 'assets/images/wudu/wudu_11_sag_ayak.png';
      default:
        return 'assets/images/wudu/wudu.png';
    }
  }
}
