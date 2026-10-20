import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/bouquet.dart';
import '../models/dictionaries.dart';
import '../models/florist.dart';
import '../state/bouquet_list_notifier.dart';
import '../state/florist_list_notifier.dart';
import '../widgets/format.dart';
import '../widgets/info_row.dart';
import '../widgets/load_state_view.dart';

class BouquetDetailsScreen extends StatefulWidget {
  final int? id;

  const BouquetDetailsScreen({super.key, required this.id});

  @override
  State<BouquetDetailsScreen> createState() => _BouquetDetailsScreenState();
}

class _BouquetDetailsScreenState extends State<BouquetDetailsScreen> {
  late Future<(Bouquet, List<Florist>)?> _future = _load();

  Future<(Bouquet, List<Florist>)?> _load() async {
    final id = widget.id;
    if (id == null) return null;
    final bouquets = context.read<BouquetListNotifier>();
    final florists = context.read<FloristListNotifier>();
    final bouquet = await bouquets.findById(id);
    if (bouquet == null || bouquet.isDeleted) return null;
    return (bouquet, await florists.findByIds(bouquet.floristIds));
  }

  @override
  void didUpdateWidget(BouquetDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка букета'),
        leading: IconButton(
          tooltip: 'К списку букетов',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/bouquets'),
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorMessage(
              message:
                  'Не удалось загрузить карточку букета: ${snapshot.error}',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return EmptyMessage(
              title: 'Букет не найден',
              message: 'Букета с номером ${widget.id ?? '?'} нет в каталоге',
            );
          }
          return _BouquetDetails(bouquet: data.$1, florists: data.$2);
        },
      ),
    );
  }
}

class _BouquetDetails extends StatelessWidget {
  final Bouquet bouquet;
  final List<Florist> florists;

  const _BouquetDetails({required this.bouquet, required this.florists});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bouquet.name, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    InfoRow(label: 'Артикул', value: bouquet.sku),
                    InfoRow(label: 'Цена', value: formatPrice(bouquet.price)),
                    InfoRow(
                      label: 'Количество цветов',
                      value: '${bouquet.flowersCount}',
                    ),
                    InfoRow(
                      label: 'Поставщик',
                      value: supplierNames[bouquet.supplierId] ?? '—',
                    ),
                    InfoRow(
                      label: 'Категории',
                      value: bouquet.categoryIds
                          .map((id) => categoryNames[id] ?? '?')
                          .join(', '),
                    ),
                    InfoRow(
                      label: 'Наличие',
                      value: 'в наличии ${bouquet.stockAvailable} '
                          'из ${bouquet.stockTotal}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Собрали флористы', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            for (final f in florists)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(f.fullName),
                  subtitle: Text(f.city),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/florists/${f.id}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
