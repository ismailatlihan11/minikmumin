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
    this.title,
    this.subtitle,
  });

  /// Leave null when the AppBar already shows the page title.
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: MinikColors.darkGreen,
                  ),
            ),
          if (title != null && subtitle != null) const SizedBox(height: 6),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: MinikColors.text,
                  ),
            ),
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
    final inked = MinikTheme.themed(
      DefaultTextStyle.merge(
        style: TextStyle(color: MinikColors.text),
        child: IconTheme.merge(
          data: IconThemeData(color: MinikColors.green),
          child: child,
        ),
      ),
    );
    final padded = Padding(padding: padding, child: inked);
    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: color ?? MinikColors.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? padded : InkWell(onTap: onTap, child: padded),
      ),
    );
    if (onTap == null) return card;
    return MergeSemantics(child: Semantics(button: true, child: card));
  }
}

class SoftBadge extends StatelessWidget {
  const SoftBadge({
    super.key,
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? MinikColors.mint,
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
              Icon(
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

class NumberBadge extends StatelessWidget {
  const NumberBadge(this.value, {super.key, this.color});

  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? MinikColors.mint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: MinikColors.darkGreen,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
