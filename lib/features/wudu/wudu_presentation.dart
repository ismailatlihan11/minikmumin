import 'dart:math';

import '../../data/models/interactive_lesson.dart';
import 'wudu_visual_catalog.dart';

abstract final class WuduPresentation {
  static String imageFor(LessonStep step) {
    if (step.image.trim().isNotEmpty) return step.image;
    return WuduVisualCatalog.imageForJsonStep(step.id);
  }

  static String promptFor(LessonStep step) {
    final description = step.description.trim();
    if (description.isNotEmpty &&
        description != 'Abdestin bu aşamasını öğren.') {
      return description;
    }
    return 'Haydi birlikte ${step.title} adımını öğrenelim.';
  }

  static String successFor(LessonStep step) {
    if (step.successMessage.trim().isNotEmpty) return step.successMessage;
    return 'Harika! ${step.title} adımını öğrendik.';
  }

  static String retryFor(LessonStep step) {
    if (step.retryMessage.trim().isNotEmpty) return step.retryMessage;
    return 'Tekrar deneyelim.';
  }

  static List<LessonStep> practiceChoices({
    required List<LessonStep> steps,
    required int currentIndex,
    Random? random,
  }) {
    if (steps.isEmpty) return const [];
    final current = steps[currentIndex];
    final others = <LessonStep>[
      for (var i = 0; i < steps.length; i++)
        if (i != currentIndex) steps[i],
    ]..shuffle(random);
    final choices = <LessonStep>[current, ...others.take(2)];
    choices.shuffle(random);
    return choices;
  }
}
