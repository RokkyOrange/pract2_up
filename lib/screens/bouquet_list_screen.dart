import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/bouquet.dart';
import '../models/dictionaries.dart';
import '../state/bouquet_list_notifier.dart';
import '../state/load_status.dart';
import '../widgets/load_state_view.dart';
import '../widgets/offline_toggle.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/format.dart';
import '../widgets/search_field.dart';

class BouquetListScreen extends StatefulWidget {
  const BouquetListScreen({super.key});

  @override
  State<BouquetListScreen> createState() => _BouquetListScreenState();
}

class _BouquetListScreenState extends State<BouquetListScreen> {
  @override
  void initState() {
    super.initState();
    // Данные перезапрашиваются при каждом открытии экрана
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<BouquetListNotifier>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BouquetListNotifier>();
    final search = notifier.query.search;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Букеты'),
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
                hint: 'Название или артикул, затем Enter',
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
                      ? 'В каталоге пока нет букетов'
                      : 'По запросу «$search» букетов не найдено',
                  onResetSearch:
                      search.isEmpty ? null : () => notifier.search(''),
                  builder: (context) => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifier.result.items.length,
                    itemBuilder: (context, i) =>
                        _BouquetTile(bouquet: notifier.result.items[i]),
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

class _BouquetTile extends StatelessWidget {
  final Bouquet bouquet;

  const _BouquetTile({required this.bouquet});

  @override
  Widget build(BuildContext context) {
    final categories =
        bouquet.categoryIds.map((id) => categoryNames[id] ?? '?').join(', ');
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.local_florist)),
        title: Text(bouquet.name),
        subtitle: Text(
          '${bouquet.flowersCount} цв. · $categories\n'
          'Артикул ${bouquet.sku}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatPrice(bouquet.price),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('в наличии: ${bouquet.stockAvailable}'),
          ],
        ),
        onTap: () => context.go('/bouquets/${bouquet.id}'),
      ),
    );
  }
}
