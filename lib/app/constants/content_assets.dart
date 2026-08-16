abstract final class ContentAssets {
  static const Map<String, String> audio = {
    'dua_rabbena_atina': 'assets/audio/duas/rabbena_atina.mp3',
    'subhaneke': 'assets/audio/prayer/subhaneke.mp3',
    'ruku': 'assets/audio/prayer/ruku_tesbihi.mp3',
    'qiyam_after_ruku': 'assets/audio/prayer/rukudan_dogrulurken.mp3',
    'sujud': 'assets/audio/prayer/sujud_tesbihi.mp3',
    'tahiyyat': 'assets/audio/prayer/tahiyyat.mp3',
    'salli': 'assets/audio/prayer/allahumme_salli.mp3',
    'barik': 'assets/audio/prayer/allahumme_barik.mp3',
    'kunut_1': 'assets/audio/prayer/kunut_1.mp3',
    'kunut_2': 'assets/audio/prayer/kunut_2.mp3',
    'fatiha': 'assets/audio/quran/fatiha_transliteration.mp3',
    'ihlas': 'assets/audio/quran/ihlas_transliteration.mp3',
    'felak': 'assets/audio/quran/felak_transliteration.mp3',
    'nas': 'assets/audio/quran/nas_transliteration.mp3',
    'ayet_el_kursi': 'assets/audio/quran/ayet_el_kursi_transliteration.mp3',
  };

  static const Map<String, String> prayerImages = {
    'intention': 'assets/images/prayer/01_niyet.png',
    'takbir': 'assets/images/prayer/02_tekbir.png',
    'qiyam': 'assets/images/prayer/03_kiyam.png',
    'ruku': 'assets/images/prayer/04_ruku.png',
    'ruku_rise': 'assets/images/prayer/05_dogrulma.png',
    'sujud': 'assets/images/prayer/06_secde.png',
    'sitting': 'assets/images/prayer/07_oturus.png',
    'salam': 'assets/images/prayer/08_selam.png',
  };

  static const Map<String, String> prophetImages = {
    'adem': 'assets/images/prophets/adem.png',
    'nuh': 'assets/images/prophets/nuh.png',
    'ibrahim': 'assets/images/prophets/ibrahim.png',
    'musa': 'assets/images/prophets/musa.png',
    'isa': 'assets/images/prophets/isa.png',
    'muhammed': 'assets/images/prophets/muhammed.png',
  };

  static String? audioFor(String id) => audio[id];

  static String prayerImage(String id) =>
      prayerImages[id] ?? 'assets/images/prayer/prayer.png';

  static String prophetImage(String name) =>
      prophetImages[name.toLowerCase()] ??
      'assets/images/prophets/prophets.png';

  static const Map<String, String> duaImages = {
    'dua_rabbena_atina': 'assets/images/duas/rabbena_atina.png',
    'subhaneke': 'assets/images/duas/subhaneke.png',
    'ruku': 'assets/images/duas/ruku_tesbihi.png',
    'qiyam_after_ruku': 'assets/images/duas/ruku_tesbihi.png',
    'sujud': 'assets/images/duas/sujud_tesbihi.png',
    'tahiyyat': 'assets/images/duas/tahiyyat.png',
    'salli': 'assets/images/duas/salli.png',
    'barik': 'assets/images/duas/barik.png',
    'kunut_1': 'assets/images/duas/kunut_1.png',
    'kunut_2': 'assets/images/duas/kunut_2.png',
    'fatiha': 'assets/images/duas/fatiha.png',
    'ihlas': 'assets/images/duas/ihlas.png',
    'felak': 'assets/images/duas/felak.png',
    'nas': 'assets/images/duas/nas.png',
    'ayet_el_kursi': 'assets/images/duas/ayet_el_kursi.png',
    'ayetul_kursi': 'assets/images/duas/ayet_el_kursi.png',
  };

  static String duaImage(String id) =>
      duaImages[id] ?? 'assets/images/duas/duas.png';
}
