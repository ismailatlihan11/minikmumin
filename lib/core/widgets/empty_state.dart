import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../shared/widgets/minik_image.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MinikImage.asset(
              'assets/images/home/empty_favorites.png',
              height: 96,
              errorBuilder: (_, __, ___) => const Icon(Icons.inbox_rounded, size: 56),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
