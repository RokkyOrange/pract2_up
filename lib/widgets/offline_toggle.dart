import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/network_notifier.dart';

/// Кнопка в шапке: включает и выключает имитацию недоступного сервера,
/// после чего вызывает [onChanged], чтобы экран перезапросил данные.
class OfflineToggle extends StatelessWidget {
  final VoidCallback onChanged;

  const OfflineToggle({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final offline = context.watch<NetworkNotifier>().offline;
    return IconButton(
      tooltip: offline
          ? 'Сервер «отключён». Нажмите, чтобы включить'
          : 'Имитировать ошибку сервера',
      icon: Icon(offline ? Icons.cloud_off : Icons.cloud_done_outlined),
      color: offline ? Theme.of(context).colorScheme.error : null,
      onPressed: () {
        context.read<NetworkNotifier>().setOffline(!offline);
        onChanged();
      },
    );
  }
}
