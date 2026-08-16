import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/storage/local_progress_store.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.kind,
    required this.id,
    required this.title,
  });

  final String kind;
  final String id;
  final String title;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    return FutureBuilder<bool>(
      future: store.isFavorite(kind, id),
      builder: (context, snapshot) {
        final active = snapshot.data ?? false;
        return IconButton(
          tooltip: active ? 'Favorilerden çıkar' : 'Favorilere ekle',
          onPressed: () => store.toggleFavorite(
            FavoriteEntry(kind: kind, id: id, title: title),
          ),
          icon: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: active ? const Color(0xFFC45B7A) : MinikColors.darkGreen,
          ),
        );
      },
    );
  }
}
