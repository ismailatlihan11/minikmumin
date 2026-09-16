import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import 'arabic_text.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.image,
  });

  final String title;
  final String? subtitle;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: MinikColors.darkGreen,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: MinikColors.text,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (image != null) ...[
            const SizedBox(width: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.asset(
                image!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: MinikColors.darkGreen,
            ),
      ),
    );
  }
}

class MinikCard extends StatelessWidget {
  const MinikCard({
    super.key,
    required this.child,
    this.color,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);
    // Cards stay light pastel/cream even in dark mode — force light theme
    // ink/buttons/list tiles so cream text does not wash out on those surfaces.
    final inked = MinikTheme.lightSurfaces(
      DefaultTextStyle.merge(
        style: const TextStyle(color: MinikColors.text),
        child: IconTheme.merge(
          data: const IconThemeData(color: MinikColors.green),
          child: child,
        ),
      ),
    );
    final body = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? MinikColors.surface,
        borderRadius: radius,
        boxShadow: AppShadows.soft,
      ),
      child: inked,
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: body,
      ),
    );
  }
}

class SoftBadge extends StatelessWidget {
  const SoftBadge({
    super.key,
    required this.label,
    this.color = MinikColors.mint,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: MinikColors.darkGreen,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class ContentTile extends StatelessWidget {
  const ContentTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.color,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MinikCard(
        color: color ?? MinikColors.surface,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: MinikColors.darkGreen,
                        ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: MinikColors.textMuted,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: MinikColors.greenSoft,
              ),
          ],
        ),
      ),
    );
  }
}

class ArabicPanel extends StatelessWidget {
  const ArabicPanel(this.text, {super.key, this.fontSize = 24});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: MinikColors.mint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ArabicText(text, fontSize: fontSize),
    );
  }
}

class RoundedAsset extends StatelessWidget {
  const RoundedAsset({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fallback,
  });

  final String path;
  final double? width;
  final double? height;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.asset(
        path,
        width: width ?? double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            fallback ??
            Container(
              width: width,
              height: height,
              color: MinikColors.pastelBlue,
              alignment: Alignment.center,
              child: const Icon(Icons.menu_book_rounded, color: MinikColors.green),
            ),
      ),
    );
  }
}

class CatalogTile extends StatelessWidget {
  const CatalogTile({
    super.key,
    required this.image,
    required this.onTap,
    this.semanticLabel,
  });

  final String image;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Image.asset(
            image,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MinikColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: MinikColors.green, width: 2),
              ),
              child: Text(
                semanticLabel ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CatalogGrid extends StatelessWidget {
  const CatalogGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 3,
    this.childAspectRatio = 1,
    this.spacing = 8,
  });

  final List<Widget> children;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }
}

class CompactCatalogRow extends StatelessWidget {
  const CompactCatalogRow({
    super.key,
    required this.children,
    this.tileSize = 72,
    this.spacing = 8,
  });

  final List<Widget> children;
  final double tileSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final child in children)
          SizedBox(width: tileSize, height: tileSize, child: child),
      ],
    );
  }
}

class NumberBadge extends StatelessWidget {
  const NumberBadge(this.value, {super.key, this.color = MinikColors.mint});

  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: MinikColors.darkGreen,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
