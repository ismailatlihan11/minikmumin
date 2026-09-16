abstract final class ContentAssets {
  static const Map<String, String> audio = {
    'besmele': 'assets/audio/prayer/besmele.mp3',
    'euzu': 'assets/audio/prayer/euzu_besmele.mp3',
    'euzu_besmele': 'assets/audio/prayer/euzu_besmele.mp3',
    'hamdele': 'assets/audio/prayer/hamdele.mp3',
    'kelime_i_tevhid': 'assets/audio/prayer/kelime_i_tevhid.mp3',
    'kelime_i_sehadet': 'assets/audio/prayer/kelime_i_sehadet.mp3',
    'subhaneke': 'assets/audio/prayer/subhaneke.mp3',
    'surah_1': 'assets/audio/quran_learn/surahs/surah_001.mp3',
    'surah_001': 'assets/audio/quran_learn/surahs/surah_001.mp3',
    'surah_108': 'assets/audio/quran_learn/surahs/surah_108.mp3',
    'surah_112': 'assets/audio/quran_learn/surahs/surah_112.mp3',
    'surah_103': 'assets/audio/quran_learn/surahs/surah_103.mp3',
    'surah_114': 'assets/audio/quran_learn/surahs/surah_114.mp3',
    'surah_113': 'assets/audio/quran_learn/surahs/surah_113.mp3',
    'surah_109': 'assets/audio/quran_learn/surahs/surah_109.mp3',
    'surah_110': 'assets/audio/quran_learn/surahs/surah_110.mp3',
    'surah_111': 'assets/audio/quran_learn/surahs/surah_111.mp3',
    'surah_107': 'assets/audio/quran_learn/surahs/surah_107.mp3',
    'surah_105': 'assets/audio/quran_learn/surahs/surah_105.mp3',
    'surah_106': 'assets/audio/quran_learn/surahs/surah_106.mp3',
    'tahiyyat': 'assets/audio/prayer/tahiyyat.mp3',
    'allahumme_salli': 'assets/audio/prayer/allahumme_salli.mp3',
    'allahumme_barik': 'assets/audio/prayer/allahumme_barik.mp3',
    'rabbena_atina': 'assets/audio/duas/quran_002_201.mp3',
    'rabbena_gfirli': 'assets/audio/duas/quran_014_041.mp3',
    'dua_rabbena_atina': 'assets/audio/duas/quran_002_201.mp3',
    'ruku': 'assets/audio/prayer/ruku_tesbihi.mp3',
    'qiyam_after_ruku': 'assets/audio/prayer/rukudan_dogrulurken.mp3',
    'sujud': 'assets/audio/prayer/sujud_tesbihi.mp3',
    'salli': 'assets/audio/prayer/allahumme_salli.mp3',
    'barik': 'assets/audio/prayer/allahumme_barik.mp3',
    'iftitah_tekbir': 'assets/audio/prayer/iftitah_tekbir.mp3',
    'rabbena_lekel_hamd': 'assets/audio/prayer/rabbena_lekel_hamd.mp3',
    'fatiha': 'assets/audio/quran_learn/surahs/surah_001.mp3',
    'ihlas': 'assets/audio/quran_learn/surahs/surah_112.mp3',
    'felak': 'assets/audio/quran_learn/surahs/surah_113.mp3',
    'nas': 'assets/audio/quran_learn/surahs/surah_114.mp3',
  };

  static String quranRecitation(int surahId) =>
      'assets/audio/quran/surah_${surahId.toString().padLeft(3, '0')}.mp3';

  /// Per-ayah Dosari clip for ezber (Everyayah SSS_AAA naming).
  static String ayahAudio(int surahNumber, int ayahNo) =>
      'assets/audio/quran/ayahs/'
      '${surahNumber.toString().padLeft(3, '0')}_'
      '${ayahNo.toString().padLeft(3, '0')}.mp3';

  static const Map<String, String> prayerImages = {
    'intention': 'assets/images/prayer/step01_niyet.png',
    'takbir': 'assets/images/prayer/step02_tekbir.png',
    'qiyam': 'assets/images/prayer/step08_kiyam.png',
    'ruku': 'assets/images/prayer/step06_ruku.png',
    'ruku_rise': 'assets/images/prayer/step07_ruku_rise.png',
    'sujud': 'assets/images/prayer/step09_secde1.png',
    'sitting': 'assets/images/prayer/step11_oturus.png',
    'salam': 'assets/images/prayer/step14_selam_sag.png',
  };

  static const Map<String, String> prophetImages = {
    'adem': 'assets/images/prophets/adem.png',
    'idris': 'assets/images/prophets/idris.png',
    'nuh': 'assets/images/prophets/nuh.png',
    'hud': 'assets/images/prophets/hud.png',
    'salih': 'assets/images/prophets/salih.png',
    'ibrahim': 'assets/images/prophets/ibrahim.png',
    'lut': 'assets/images/prophets/lut.png',
    'lût': 'assets/images/prophets/lut.png',
    'ismail': 'assets/images/prophets/ismail.png',
    'ishak': 'assets/images/prophets/ishak.png',
    'yakup': 'assets/images/prophets/yakup.png',
    'yusuf': 'assets/images/prophets/yusuf.png',
    'eyyub': 'assets/images/prophets/eyyub.png',
    'şuayb': 'assets/images/prophets/shuayb.png',
    'shuayb': 'assets/images/prophets/shuayb.png',
    'suayb': 'assets/images/prophets/shuayb.png',
    'musa': 'assets/images/prophets/musa.png',
    'harun': 'assets/images/prophets/harun.png',
    'davud': 'assets/images/prophets/davud.png',
    'süleyman': 'assets/images/prophets/suleyman.png',
    'suleyman': 'assets/images/prophets/suleyman.png',
    'ilyas': 'assets/images/prophets/ilyas.png',
    'elyesa': 'assets/images/prophets/elyesa.png',
    'zülkifl': 'assets/images/prophets/zulkifl.png',
    'zulkifl': 'assets/images/prophets/zulkifl.png',
    'yunus': 'assets/images/prophets/yunus.png',
    'zekeriya': 'assets/images/prophets/zekeriya.png',
    'zekeriyya': 'assets/images/prophets/zekeriya.png',
    'yahya': 'assets/images/prophets/yahya.png',
    'isa': 'assets/images/prophets/isa.png',
    'muhammed': 'assets/images/prophets/muhammed.png',
  };

  static const Map<String, String> _idAliases = {
    'surah_1': 'fatiha',
    'surah_112': 'ihlas',
    'surah_113': 'felak',
    'surah_114': 'nas',
    'allahumme_salli': 'salli',
    'allahumme_barik': 'barik',
    'rabbena_atina': 'dua_rabbena_atina',
    'rabbena_gfirli': 'rabbena_ghfirli',
  };

  static String audioFor(String id) {
    final mapped = audio[id] ?? audio[_idAliases[id] ?? ''];
    if (mapped != null && mapped.isNotEmpty) return mapped;
    if (id.startsWith('surah_')) {
      final number = int.tryParse(id.substring(6));
      if (number != null) {
        return 'assets/audio/quran_learn/surahs/surah_${number.toString().padLeft(3, '0')}.mp3';
      }
      return 'assets/audio/quran_learn/surahs/$id.mp3';
    }
    if (id.startsWith('dua_') || id.startsWith('quran_dua_')) {
      return 'assets/audio/duas/$id.mp3';
    }
    return 'assets/audio/prayer/$id.mp3';
  }

  static String prayerImage(String id) =>
      prayerImages[id] ?? 'assets/images/prayer/prayer.png';

  static String prophetImage(String name, {String id = '', String jsonPath = ''}) {
    if (jsonPath.isNotEmpty) return jsonPath;
    if (id.isNotEmpty && prophetImages.containsKey(id)) return prophetImages[id]!;
    return prophetImages[name.toLowerCase()] ??
        'assets/images/prophets/prophets.png';
  }

  static const Map<String, String> duaImages = {
    'dua_rabbena_atina': 'assets/images/duas/rabbena_atina.png',
    'rabbena_atina': 'assets/images/duas/rabbena_atina.png',
    'dua_rabbena_la_tuzig': 'assets/images/duas/rabbena_la_tuzig.png',
    'dua_rabbirhamhuma': 'assets/images/duas/anne_baba.png',
    'dua_rabbi_zidni_ilma': 'assets/images/duas/zidni_ilma.png',
    'dua_rabbighfirli': 'assets/images/duas/rabbighfirli.png',
    'subhaneke': 'assets/images/duas/subhaneke.png',
    'ruku': 'assets/images/duas/ruku_tesbihi.png',
    'qiyam_after_ruku': 'assets/images/duas/qiyam_after_ruku.png',
    'sujud': 'assets/images/duas/sujud_tesbihi.png',
    'tahiyyat': 'assets/images/duas/tahiyyat.png',
    'salli': 'assets/images/duas/salli.png',
    'barik': 'assets/images/duas/barik.png',
    'rabbena_ghfirli': 'assets/images/duas/rabbena_ghfirli.png',
    'kunut_1': 'assets/images/duas/kunut_1.png',
    'kunut_2': 'assets/images/duas/kunut_2.png',
    'fatiha': 'assets/images/duas/fatiha.png',
    'ihlas': 'assets/images/duas/ihlas.png',
    'felak': 'assets/images/duas/felak.png',
    'nas': 'assets/images/duas/nas.png',
    'ayet_el_kursi': 'assets/images/duas/ayet_el_kursi.png',
    'ayetul_kursi': 'assets/images/duas/ayet_el_kursi.png',
  };

  static const Map<String, String> moralityImages = {
    'truthfulness': 'assets/images/morality/truthfulness.png',
    'dogruluk': 'assets/images/morality/truthfulness.png',
    'mercy': 'assets/images/morality/mercy.png',
    'merhamet': 'assets/images/morality/mercy.png',
    'parents': 'assets/images/morality/parents.png',
    'anne_babaya_iyilik': 'assets/images/morality/parents.png',
    'sharing': 'assets/images/morality/sharing.png',
    'yardimlasma': 'assets/images/morality/sharing.png',
    'paylasma': 'assets/images/morality/sharing.png',
  };

  static const Map<String, String> ilmihalImages = {
    'temizlik': 'assets/images/ilmihal/temizlik.png',
    'abdest': 'assets/images/ilmihal/abdest.png',
    'namaz': 'assets/images/ilmihal/namaz.png',
    'oruç': 'assets/images/ilmihal/oruc.png',
    'oruc': 'assets/images/ilmihal/oruc.png',
    'cami_adabi': 'assets/images/ilmihal/cami_adabi.png',
    'camii': 'assets/images/ilmihal/cami_adabi.png',
    'iman': 'assets/images/ilmihal/iman.png',
    'zekat_sadaka': 'assets/images/ilmihal/zekat.png',
    'hac_kurban': 'assets/images/ilmihal/hac.png',
    'dua_tövbe': 'assets/images/ilmihal/dua.png',
    'gunluk_hayat': 'assets/images/ilmihal/gunluk.png',
  };

  static String duaImage(String id) =>
      duaImages[id] ??
      duaImages[_idAliases[id] ?? ''] ??
      'assets/images/duas/duas.png';

  static String moralityImage(String id, [String jsonPath = '']) {
    if (jsonPath.isNotEmpty) return jsonPath;
    return moralityImages[id] ?? 'assets/images/morality/morality.png';
  }

  static String ilmihalImage(String id, [String jsonPath = '']) {
    if (jsonPath.isNotEmpty) return jsonPath;
    return ilmihalImages[id] ??
        'assets/images/home/ilmihal.png';
  }
}
