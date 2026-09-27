import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_image.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.message = 'İçerik yüklenirken bir sorun oluştu.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MinikImage.asset(
              'assets/images/home/error.png',
              height: 96,
              errorBuilder: (_, __, ___) => const Icon(Icons.cloud_off_rounded, size: 56),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              PrimaryButton(label: 'Tekrar dene', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
