import 'package:flutter/material.dart';

import '../state/load_status.dart';

/// Выбирает, что показать по состоянию загрузки: индикатор,
/// сообщение об ошибке, сообщение о пустом результате или сами данные.
class LoadStateView extends StatelessWidget {
  final LoadStatus status;
  final bool isEmpty;
  final String? error;
  final VoidCallback onRetry;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback? onResetSearch;
  final WidgetBuilder builder;

  const LoadStateView({
    super.key,
    required this.status,
    required this.isEmpty,
    required this.error,
    required this.onRetry,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.builder,
    this.onResetSearch,
  });

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      LoadStatus.idle || LoadStatus.loading => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Загрузка...'),
            ],
          ),
        ),
      LoadStatus.error => ErrorMessage(
          message: error ?? 'Неизвестная ошибка',
          onRetry: onRetry,
        ),
      LoadStatus.success when isEmpty => EmptyMessage(
          title: emptyTitle,
          message: emptyMessage,
          onReset: onResetSearch,
        ),
      LoadStatus.success => builder(context),
    };
  }
}

class EmptyMessage extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onReset;

  const EmptyMessage({
    super.key,
    required this.title,
    required this.message,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (onReset != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.clear),
                label: const Text('Сбросить поиск'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorMessage({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          color: colors.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 72, color: colors.error),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: colors.onErrorContainer),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onErrorContainer),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
