import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/florist.dart';
import '../state/florist_list_notifier.dart';
import '../state/load_status.dart';
import '../widgets/load_state_view.dart';
import '../widgets/format.dart';
import '../widgets/offline_toggle.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/search_field.dart';

class FloristListScreen extends StatefulWidget {
  const FloristListScreen({super.key});

  @override
  State<FloristListScreen> createState() => _FloristListScreenState();
}

class _FloristListScreenState extends State<FloristListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<FloristListNotifier>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<FloristListNotifier>();
    final search = notifier.query.search;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Флористы'),
        leading: IconButton(
          tooltip: 'На главную',
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
        actions: [
          OfflineToggle(onChanged: notifier.load),
          IconButton(
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
            onPressed: notifier.load,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              SearchField(
                initialText: search,
                hint: 'Фамилия или город, затем Enter',
                onSearch: notifier.search,
              ),
              Expanded(
                child: LoadStateView(
                  status: notifier.status,
                  isEmpty: notifier.result.items.isEmpty,
                  error: notifier.error,
                  onRetry: notifier.load,
                  emptyTitle: 'Ничего не найдено',
                  emptyMessage: search.isEmpty
                      ? 'В магазине пока нет флористов'
                      : 'По запросу «$search» флористов не найдено',
                  onResetSearch:
                      search.isEmpty ? null : () => notifier.search(''),
                  builder: (context) => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifier.result.items.length,
                    itemBuilder: (context, i) =>
                        _FloristTile(florist: notifier.result.items[i]),
                  ),
                ),
              ),
              if (notifier.status == LoadStatus.success &&
                  notifier.result.items.isNotEmpty)
                PaginationBar(
                  result: notifier.result,
                  onPage: notifier.goToPage,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloristTile extends StatelessWidget {
  final Florist florist;

  const _FloristTile({required this.florist});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(florist.lastName[0])),
        title: Text(florist.fullName),
        subtitle: Text(
          '${florist.city} · стаж ${formatYears(florist.experienceYears)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/florists/${florist.id}'),
      ),
    );
  }
}
