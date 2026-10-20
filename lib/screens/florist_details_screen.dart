import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/bouquet.dart';
import '../models/florist.dart';
import '../state/bouquet_list_notifier.dart';
import '../state/florist_list_notifier.dart';
import '../widgets/format.dart';
import '../widgets/info_row.dart';
import '../widgets/load_state_view.dart';

class FloristDetailsScreen extends StatefulWidget {
  final int? id;

  const FloristDetailsScreen({super.key, required this.id});

  @override
  State<FloristDetailsScreen> createState() => _FloristDetailsScreenState();
}

class _FloristDetailsScreenState extends State<FloristDetailsScreen> {
  late Future<(Florist, List<Bouquet>)?> _future = _load();

  Future<(Florist, List<Bouquet>)?> _load() async {
    final id = widget.id;
    if (id == null) return null;
    final florists = context.read<FloristListNotifier>();
    final bouquets = context.read<BouquetListNotifier>();
    final florist = await florists.findById(id);
    if (florist == null || florist.isDeleted) return null;
    return (florist, await bouquets.findByFlorist(id));
  }

  @override
  void didUpdateWidget(FloristDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка флориста'),
        leading: IconButton(
          tooltip: 'К списку флористов',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/florists'),
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
                  'Не удалось загрузить карточку флориста: ${snapshot.error}',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return EmptyMessage(
              title: 'Флорист не найден',
              message: 'Флориста с номером ${widget.id ?? '?'} нет в магазине',
            );
          }
          return _FloristDetails(florist: data.$1, bouquets: data.$2);
        },
      ),
    );
  }
}

class _FloristDetails extends StatelessWidget {
  final Florist florist;
  final List<Bouquet> bouquets;

  const _FloristDetails({required this.florist, required this.bouquets});

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
                    Text(florist.fullName,
                        style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    InfoRow(label: 'Фамилия', value: florist.lastName),
                    InfoRow(label: 'Имя', value: florist.firstName),
                    InfoRow(
                        label: 'Отчество', value: florist.middleName ?? '—'),
                    InfoRow(label: 'Город', value: florist.city),
                    InfoRow(
                      label: 'Стаж',
                      value: formatYears(florist.experienceYears),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Букеты флориста (${bouquets.length})',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            if (bouquets.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('У этого флориста пока нет букетов в каталоге'),
              ),
            for (final b in bouquets)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.local_florist),
                  title: Text(b.name),
                  subtitle: Text(
                    '${formatPrice(b.price)} · ${b.flowersCount} цв.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/bouquets/${b.id}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
