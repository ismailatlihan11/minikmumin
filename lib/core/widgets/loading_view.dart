import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../shared/widgets/minik_image.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Yükleniyor...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MinikImage.asset(
              'assets/images/home/loading.png',
              height: 96,
              errorBuilder: (_, __, ___) => const CircularProgressIndicator(),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(color: MinikColors.green),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
