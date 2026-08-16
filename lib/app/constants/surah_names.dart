const List<String> kSurahNames = [
  'Fâtiha', 'Bakara', 'Âl-i İmrân', 'Nisâ', 'Mâide', 'En\'âm', 'A\'râf', 'Enfâl',
  'Tevbe', 'Yûnus', 'Hûd', 'Yûsuf', 'Ra\'d', 'İbrâhim', 'Hicr', 'Nahl', 'İsrâ',
  'Kehf', 'Meryem', 'Tâhâ', 'Enbiyâ', 'Hac', 'Mü\'minûn', 'Nûr', 'Furkân',
  'Şuarâ', 'Neml', 'Kasas', 'Ankebût', 'Rûm', 'Lokmân', 'Secde', 'Ahzâb', 'Sebe',
  'Fâtır', 'Yâsîn', 'Sâffât', 'Sâd', 'Zümer', 'Mü\'min', 'Fussilet', 'Şûrâ',
  'Zuhruf', 'Duhân', 'Câsiye', 'Ahkâf', 'Muhammed', 'Fetih', 'Hucurât', 'Kâf',
  'Zâriyât', 'Tûr', 'Necm', 'Kamer', 'Rahmân', 'Vâkıa', 'Hadîd', 'Mücâdele',
  'Haşr', 'Mümtehine', 'Saff', 'Cum\'a', 'Münâfikûn', 'Teğâbun', 'Talâk',
  'Tahrîm', 'Mülk', 'Kalem', 'Hâkka', 'Meâric', 'Nûh', 'Cin', 'Müzzemmil',
  'Müddessir', 'Kıyâme', 'İnsân', 'Mürselât', 'Nebe', 'Nâziât', 'Abese',
  'Tekvîr', 'İnfitâr', 'Mutaffifîn', 'İnşikâk', 'Bürûc', 'Târık', 'A\'lâ',
  'Ğâşiye', 'Fecr', 'Beled', 'Şems', 'Leyl', 'Duhâ', 'İnşirâh', 'Tîn', 'Alak',
  'Kadr', 'Beyyine', 'Zilzâl', 'Âdiyât', 'Kâria', 'Tekâsür', 'Asr', 'Hümeze',
  'Fîl', 'Kureyş', 'Mâûn', 'Kevser', 'Kâfirûn', 'Nasr', 'Tebbet', 'İhlâs',
  'Felak', 'Nâs',
];

String surahName(int id) {
  if (id < 1 || id > kSurahNames.length) return 'Sure $id';
  return kSurahNames[id - 1];
}
