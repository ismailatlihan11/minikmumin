import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';

Future<void> copyToClipboard(
  BuildContext context,
  String text, {
  String message = 'Kopyalandı.',
}) async {
  final value = text.trim();
  if (value.isEmpty) return;
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

String joinCopyParts(Iterable<String> parts) {
  return parts
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join('\n');
}

class CopyIconButton extends StatelessWidget {
  const CopyIconButton({
    super.key,
    required this.text,
    this.tooltip = 'Kopyala',
  });

  final String text;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: text.trim().isEmpty ? null : () => copyToClipboard(context, text),
      icon: const Icon(Icons.copy_rounded),
    );
  }
}

class CopyTextButton extends StatelessWidget {
  const CopyTextButton({super.key, required this.text, this.label = 'Kopyala'});

  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: text.trim().isEmpty ? null : () => copyToClipboard(context, text),
      icon: const Icon(Icons.copy_rounded, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: MinikColors.green,
      ),
    );
  }
}
