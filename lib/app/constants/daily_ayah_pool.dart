/// Çocuklara uygun günün ayeti havuzu. Meal uydurulmaz; ayetler mevcut JSON'dan okunur.
abstract final class DailyAyahPool {
  static const pairs = <(int surahId, int ayahNo)>[
    (1, 1),
    (1, 2),
    (1, 5),
    (2, 152),
    (2, 153),
    (2, 195),
    (3, 159),
    (16, 90),
    (17, 23),
    (25, 63),
    (31, 14),
    (31, 17),
    (49, 10),
    (68, 4),
    (90, 17),
    (93, 5),
    (93, 8),
    (94, 5),
    (94, 6),
    (103, 3),
  ];

  static const childNotes = <String, String>{
    '1:1': 'Her güzel işe Allah’ın adıyla başlarız.',
    '1:2': 'Bütün güzellikler için Allah’a şükrederiz.',
    '1:5': 'Yalnız Allah’a kulluk eder, yalnız O’ndan yardım isteriz.',
    '2:152': 'Allah’ı an, O’na şükret. Nimetleri unutma.',
    '2:153': 'Zorlanınca sabret ve namaz kıl. Allah sabredenlerle beraberdir.',
    '2:195': 'İyilik yap. Allah iyilik edenleri sever.',
    '3:159': 'İnsanlara yumuşak ve merhametli ol.',
    '16:90': 'Adaletli ol, iyilik yap, akrabana yardım et.',
    '17:23': 'Anne ve babana iyilik et, onlara öf bile deme.',
    '25:63': 'Yeryüzünde ağır başlı ve nazik yürü.',
    '31:14': 'Anne-babana teşekkür et. Onlar senin için çok emek verdi.',
    '31:17': 'Namazını kıl, iyiliği öğütle, kötülükten uzak dur, sabret.',
    '49:10': 'Müminler kardeştir. Barış içinde olalım.',
    '68:4': 'Peygamberimizin ahlakı çok güzeldir. Biz de güzel ahlaklı olalım.',
    '90:17': 'İman edenler birbirine sabrı ve merhameti tavsiye eder.',
    '93:5': 'Allah sana ikram eder, üzülme.',
    '93:8': 'Muhtaçken Allah seni korudu. Sen de muhtaçlara iyi davran.',
    '94:5': 'Zorluğun yanında bir kolaylık vardır.',
    '94:6': 'Her zorluktan sonra Allah bir kolaylık verir.',
    '103:3': 'İman et, iyi işler yap, hakkı ve sabrı tavsiye et.',
  };

  static String? childNoteFor(int surahId, int ayahNo) =>
      childNotes['$surahId:$ayahNo'];
}
