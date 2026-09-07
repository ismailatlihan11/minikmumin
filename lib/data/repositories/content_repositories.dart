import '../datasources/json_content_datasource.dart';
import 'app_config_repository.dart';
import 'asma_repository.dart';
import 'dhikr_repository.dart';
import 'dua_repository.dart';
import 'hadith_repository.dart';
import 'learn_repositories.dart';
import 'quran_learning_repository.dart';
import 'quran_repository.dart';
import '../../features/elifba_adventure/elifba_repository.dart';

/// Shared repository graph. UI reads through this facade, never from JSON.
class ContentRepositories {
  ContentRepositories({JsonContentDatasource? datasource})
      : datasource = datasource ?? JsonContentDatasource() {
    final source = this.datasource;
    config = AppConfigRepository(datasource: source);
    quran = QuranRepository(datasource: source);
    hadith = HadithRepository(datasource: source);
    duas = DuaRepository(datasource: source);
    asma = AsmaRepository(datasource: source);
    prophets = ProphetRepository(datasource: source);
    stories = StoryRepository(datasource: source);
    morality = MoralityRepository(datasource: source);
    ilmihal = IlmihalRepository(datasource: source);
    quiz = QuizRepository(datasource: source);
    wudu = WuduRepository(datasource: source);
    prayer = PrayerRepository(datasource: source);
    achievements = AchievementRepository(datasource: source);
    dhikr = DhikrRepository(datasource: source);
    basics = BasicsRepository(datasource: source);
    quranLearning = QuranLearningRepository(datasource: source);
    elifba = ElifbaRepository(datasource: source);
  }

  final JsonContentDatasource datasource;
  late final AppConfigRepository config;
  late final QuranRepository quran;
  late final HadithRepository hadith;
  late final DuaRepository duas;
  late final AsmaRepository asma;
  late final ProphetRepository prophets;
  late final StoryRepository stories;
  late final MoralityRepository morality;
  late final IlmihalRepository ilmihal;
  late final QuizRepository quiz;
  late final WuduRepository wudu;
  late final PrayerRepository prayer;
  late final AchievementRepository achievements;
  late final DhikrRepository dhikr;
  late final BasicsRepository basics;
  late final QuranLearningRepository quranLearning;
  late final ElifbaRepository elifba;
}
