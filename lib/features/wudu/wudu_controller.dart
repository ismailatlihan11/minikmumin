import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/interactive_lesson.dart';
import '../../data/repositories/content_repositories.dart';
import 'wudu_presentation.dart';

enum WuduPhase { intro, learn, practice, result }

class WuduController extends ChangeNotifier {
  WuduController({
    required ContentRepositories repos,
    LocalProgressStore? store,
    AudioPlayerService? audio,
    Random? random,
  })  : _repos = repos,
        _store = store ?? LocalProgressStore(),
        _audio = audio ?? AudioPlayerService(),
        _random = random ?? Random();

  final ContentRepositories _repos;
  final LocalProgressStore _store;
  final AudioPlayerService _audio;
  final Random _random;

  static const int lessonXp = 10;

  WuduLesson? lesson;
  Object? error;
  bool loading = true;
  WuduPhase phase = WuduPhase.intro;
  int stepIndex = 0;
  List<LessonStep> choices = const [];
  String? feedback;
  bool? lastCorrect;
  WuduProgress progress = const WuduProgress(
    stepIndex: 0,
    completed: false,
    started: false,
  );
  int earnedXp = 0;
  bool awardedNewBadge = false;

  LessonStep? get currentStep {
    final items = lesson?.steps;
    if (items == null || stepIndex < 0 || stepIndex >= items.length) {
      return null;
    }
    return items[stepIndex];
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final loaded = await _repos.wudu.getLesson();
      final sorted = [...loaded.steps]
        ..sort((a, b) => a.order.compareTo(b.order));
      lesson = WuduLesson(
        id: loaded.id,
        title: loaded.title,
        sourceName: loaded.sourceName,
        verificationRequired: loaded.verificationRequired,
        steps: sorted,
      );
      progress = await _store.getWuduProgress();
      stepIndex = progress.stepIndex.clamp(0, max(0, sorted.length - 1));
      phase = WuduPhase.intro;
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> start({bool continueLesson = false}) async {
    final items = lesson?.steps ?? const [];
    if (items.isEmpty) return;
    if (continueLesson && progress.inProgress) {
      stepIndex = progress.stepIndex.clamp(0, items.length - 1);
    } else {
      stepIndex = 0;
      await _store.resetWudu();
    }
    phase = WuduPhase.learn;
    feedback = null;
    lastCorrect = null;
    await _store.saveWuduStep(stepIndex);
    progress = await _store.getWuduProgress();
    notifyListeners();
  }

  Future<void> playStepAudio() async {
    final step = currentStep;
    if (step == null) return;
    await _audio.playAsset(step.audio);
  }

  Future<void> goPractice() async {
    final items = lesson?.steps ?? const [];
    if (items.isEmpty) return;
    choices = WuduPresentation.practiceChoices(
      steps: items,
      currentIndex: stepIndex,
      random: _random,
    );
    phase = WuduPhase.practice;
    feedback = null;
    lastCorrect = null;
    notifyListeners();
  }

  Future<void> answer(LessonStep selected) async {
    final step = currentStep;
    if (step == null || phase != WuduPhase.practice) return;
    final correct = selected.id == step.id;
    lastCorrect = correct;
    feedback = correct
        ? WuduPresentation.successFor(step)
        : WuduPresentation.retryFor(step);
    HapticFeedback.lightImpact();
    await _audio.playAsset(correct ? EffectAudio.correct : EffectAudio.retry);
    notifyListeners();
  }

  Future<void> retryPractice() async {
    lastCorrect = null;
    feedback = null;
    await goPractice();
  }

  Future<void> advance() async {
    final items = lesson?.steps ?? const [];
    if (items.isEmpty) return;
    if (stepIndex >= items.length - 1) {
      await _complete();
      return;
    }
    stepIndex += 1;
    phase = WuduPhase.learn;
    feedback = null;
    lastCorrect = null;
    await _store.saveWuduStep(stepIndex);
    progress = await _store.getWuduProgress();
    notifyListeners();
  }

  Future<void> _complete() async {
    final alreadyDone = progress.completed;
    final badgesBefore = await _store.getBadges();
    await _store.markWuduCompleted();
    if (!alreadyDone) {
      await _store.addXp(lessonXp);
      earnedXp = lessonXp;
      awardedNewBadge = !badgesBefore.contains('first_lesson');
    }
    await _audio.playAsset(EffectAudio.complete);
    progress = await _store.getWuduProgress();
    phase = WuduPhase.result;
    notifyListeners();
  }

  Future<void> restart() async {
    await start(continueLesson: false);
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }
}
