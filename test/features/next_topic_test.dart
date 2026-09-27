import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/core/storage/local_progress_store.dart';
import 'package:minik_kalpler/data/models/lessons.dart';
import 'package:minik_kalpler/features/learn/morality_page.dart';
import 'package:minik_kalpler/shared/widgets/topic_footer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

MoralityLesson _lesson(String id) =>
    MoralityLesson(id: id, title: 'Konu $id', lesson: 'Metin $id', source: '');

Widget _app(Widget home) {
  return ChangeNotifierProvider(
    create: (_) => LocalProgressStore(),
    child: MaterialApp(home: home),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('TopicFooter', () {
    Widget footer({
      bool learned = true,
      bool hasNext = true,
      String? nextGroup = 'A',
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TopicFooter(
            learned: learned,
            onLearn: () {},
            hasNext: hasNext,
            onNext: () {},
            currentGroup: 'A',
            nextGroup: nextGroup,
          ),
        ),
      );
    }

    testWidgets('asks to learn first', (tester) async {
      await tester.pumpWidget(footer(learned: false));
      expect(find.text('Öğrendim'), findsOneWidget);
      expect(find.text('Sonraki konuya geç'), findsNothing);
    });

    testWidgets('same section offers the next topic', (tester) async {
      await tester.pumpWidget(footer());
      expect(find.text('Aferin, bu konuyu öğrendin!'), findsOneWidget);
      expect(find.text('Sonraki konuya geç'), findsOneWidget);
    });

    testWidgets('new section is announced', (tester) async {
      await tester.pumpWidget(footer(nextGroup: 'B'));
      expect(
        find.textContaining('“A” bölümündeki tüm konuları tamamladın'),
        findsOneWidget,
      );
      expect(find.text('B bölümüne geç'), findsOneWidget);
    });

    testWidgets('last topic goes back to the list', (tester) async {
      await tester.pumpWidget(footer(hasNext: false, nextGroup: null));
      expect(find.text('Konulara dön'), findsOneWidget);
    });
  });

  testWidgets('güzel ahlak: learn, then jump to the next category',
      (tester) async {
    await tester.pumpWidget(_app(MoralityLessonPage(
      lesson: _lesson('1'),
      categoryTitle: 'Temel Değerler',
      upcoming: [(item: _lesson('2'), group: 'Aile')],
    )));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Öğrendim'), 200);
    await tester.tap(find.text('Öğrendim'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('“Temel Değerler” bölümündeki'),
      findsOneWidget,
    );
    await tester.tap(find.text('Aile bölümüne geç'));
    await tester.pumpAndSettle();

    expect(find.text('Konu 2'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Öğrendim'), 200);
    await tester.tap(find.text('Öğrendim'));
    await tester.pumpAndSettle();
    expect(find.text('Konulara dön'), findsOneWidget);
  });
}
