import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import 'minik_ui.dart';

class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.future,
    required this.builder,
    required this.onRetry,
    this.emptyTitle,
  });

  final Future<T> future;
  final Widget Function(T data) builder;
  final VoidCallback onRetry;
  final String? emptyTitle;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return ErrorView(onRetry: onRetry);
        }
        final data = snapshot.data;
        if (data == null || (data is List && data.isEmpty)) {
          return EmptyState(title: emptyTitle ?? 'İçerik bulunamadı.');
        }
        return builder(data as T);
      },
    );
  }
}

class DetailScaffold extends StatelessWidget {
  const DetailScaffold({
    super.key,
    required this.title,
    required this.children,
    this.actions,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          MinikCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
