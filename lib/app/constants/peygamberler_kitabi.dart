abstract final class PeygamberlerKitabi {
  static const String id = 'peygamberler_kitabi';
  static const String title = 'En Güzel Örnek Peygamberler';
  static const String author = 'Pervin Ayşe Yaşa';
  static const String illustrator = 'Osman Turhan';
  static const String publisher = 'Diyanet İşleri Başkanlığı Yayınları';
  static const int year = 2016;
  static const int pageCount = 49;
  static const int firstContentPage = 9;
  static const String cover = 'assets/images/books/peygamberler/page_05.jpg';

  static const chapters = [
    (title: 'İnsan Olmak', page: 9),
    (title: 'İlk İnsan İlk Peygamber', page: 19),
    (title: 'Rabbini Arayan Çocuk', page: 28),
    (title: 'Onun Adı Sabır', page: 34),
    (title: 'En Sevgili', page: 42),
  ];

  static String pageImage(int page) {
    final n = page.clamp(1, pageCount);
    return 'assets/images/books/peygamberler/page_${n.toString().padLeft(2, '0')}.jpg';
  }
}
