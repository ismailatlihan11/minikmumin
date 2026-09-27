import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/asset_catalog.dart';
import '../../core/storage/local_progress_store.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/interactive_lesson.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/lesson_motion_image.dart';
import '../../shared/widgets/minik_ui.dart';
import 'wudu_catalog_view.dart';
import 'wudu_controller.dart';
import 'wudu_presentation.dart';

class WuduFlowPage extends StatelessWidget {
  const WuduFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WuduController(
        repos: context.read<ContentRepositories>(),
        store: context.read<LocalProgressStore>(),
      )..load(),
      child: const _WuduFlowView(),
    );
  }
}

class _WuduFlowView extends StatelessWidget {
  const _WuduFlowView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WuduController>();
    final hideAppBar = !controller.loading &&
        controller.error == null &&
        controller.phase == WuduPhase.intro;
    return Scaffold(
      appBar: hideAppBar ? null : AppBar(
        title: Text(controller.lesson?.title ?? 'Abdest'),
      ),
      body: hideAppBar
          ? _buildBody(context, controller)
          : SafeArea(child: _buildBody(context, controller)),
    );
  }

  Widget _buildBody(BuildContext context, WuduController controller) {
    if (controller.loading) return const LoadingView();
    if (controller.error != null || controller.lesson == null) {
      return ErrorView(onRetry: controller.load);
    }
    switch (controller.phase) {
      case WuduPhase.intro:
        return const _IntroView();
      case WuduPhase.learn:
        return _LearnView(controller: controller);
      case WuduPhase.practice:
        return _PracticeView(controller: controller);
      case WuduPhase.result:
        return _ResultView(controller: controller);
    }
  }
}

class _IntroView extends StatelessWidget {
  const _IntroView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WuduCatalogView(
        onBack: () => Navigator.pop(context),
        onHome: () => Navigator.popUntil(context, (route) => route.isFirst),
        onOpenStep: (step) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WuduStepDetailPage(step: step)),
          );
        },
      ),
    );
  }
}

class _LearnView extends StatelessWidget {
  const _LearnView({required this.controller});

  final WuduController controller;

  @override
  Widget build(BuildContext context) {
    final lesson = controller.lesson!;
    final step = controller.currentStep!;
    return Padding(
      padding: AppSpacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LessonProgressBar(
            current: controller.stepIndex + 1,
            total: lesson.steps.length,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView(
              children: [
                _StepImage(path: WuduPresentation.imageFor(step)),
                const SizedBox(height: AppSpacing.md),
                Text(step.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  WuduPresentation.promptFor(step),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (step.sourceReference.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Kaynak: ${step.sourceReference}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (AssetCatalog.contains(step.audio)) ...[
            SecondaryButton(
              label: 'Dinle',
              onPressed: controller.playStepAudio,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          PrimaryButton(
            label: 'Uygula',
            onPressed: controller.goPractice,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _PracticeView extends StatelessWidget {
  const _PracticeView({required this.controller});

  final WuduController controller;

  @override
  Widget build(BuildContext context) {
    final step = controller.currentStep!;
    return Stack(
      children: [
        Padding(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LessonProgressBar(
                current: controller.stepIndex + 1,
                total: controller.lesson!.steps.length,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Hangisi ${step.title}?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Doğru resmi seç.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.separated(
                  itemCount: controller.choices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final choice = controller.choices[index];
                    return _ChoiceCard(
                      step: choice,
                      enabled: controller.lastCorrect == null,
                      onTap: () => controller.answer(choice),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (controller.feedback != null)
          _FeedbackOverlay(
            message: controller.feedback!,
            correct: controller.lastCorrect ?? false,
            onContinue: controller.lastCorrect == true
                ? controller.advance
                : controller.retryPractice,
            continueLabel:
                controller.lastCorrect == true ? 'Devam Et' : 'Tekrar Dene',
          ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.controller});

  final WuduController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.page,
      children: [
        Image.asset(
          'assets/images/home/success.png',
          height: 140,
          errorBuilder: (_, __, ___) => Icon(
            Icons.check_circle_rounded,
            size: 72,
            color: MinikColors.success,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Maşallah! Dersi tamamladın.',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Öğrendiğin konu: ${controller.lesson!.title}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (controller.earnedXp > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          MinikCard(
            color: MinikColors.butter,
            child: Text('+${controller.earnedXp} XP', style: Theme.of(context).textTheme.headlineMedium),
          ),
        ],
        if (controller.awardedNewBadge) ...[
          const SizedBox(height: AppSpacing.sm),
          MinikCard(
            color: MinikColors.mint,
            child: Text('Rozet: İlk Ders'),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (controller.lesson?.completionDua != null) ...[
          SecondaryButton(
            label: 'Abdest duasını oku',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WuduDuaPage(
                  dua: controller.lesson!.completionDua!,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        PrimaryButton(
          label: 'Tekrar Et',
          onPressed: controller.restart,
        ),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(
          label: 'Öğrenmeye Dön',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _StepImage extends StatelessWidget {
  const _StepImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return MinikCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: LessonMotionImage(
          image: path,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.step,
    required this.onTap,
    required this.enabled,
  });

  final LessonStep step;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: step.title,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            color: MinikColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.soft,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Image.asset(
                    WuduPresentation.imageFor(step),
                    width: 88,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 88,
                      height: 64,
                      child: Icon(Icons.image_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackOverlay extends StatelessWidget {
  const _FeedbackOverlay({
    required this.message,
    required this.correct,
    required this.onContinue,
    required this.continueLabel,
  });

  final String message;
  final bool correct;
  final VoidCallback onContinue;
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black38,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Material(
            color: MinikColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    correct ? Icons.favorite_rounded : Icons.refresh_rounded,
                    color: correct ? MinikColors.success : MinikColors.teal,
                    size: 40,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(label: continueLabel, onPressed: onContinue),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
