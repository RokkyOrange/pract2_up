import '../models/bouquet.dart';
import '../models/bouquet_query.dart';
import '../models/page_result.dart';
import 'bouquet_repository.dart';
import 'fake_network.dart';
import 'seed_data.dart';

class InMemoryBouquetRepository implements BouquetRepository {
  final FakeNetwork _network;
  final List<Bouquet> _bouquets = [...seedBouquets];
  int _nextId = seedBouquets.length + 1;

  InMemoryBouquetRepository(this._network);

  @override
  Future<PageResult<Bouquet>> find(BouquetQuery q) async {
    await _network.request();

    var rows =
        _bouquets.where((b) => q.includeDeleted || !b.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((b) =>
              b.name.toLowerCase().contains(needle) ||
              b.sku.toLowerCase().contains(needle))
          .toList();
    }
    if (q.categoryId != null) {
      rows = rows.where((b) => b.categoryIds.contains(q.categoryId)).toList();
    }
    if (q.supplierId != null) {
      rows = rows.where((b) => b.supplierId == q.supplierId).toList();
    }
    if (q.priceFrom != null) {
      rows = rows.where((b) => b.price >= q.priceFrom!).toList();
    }
    if (q.priceTo != null) {
      rows = rows.where((b) => b.price <= q.priceTo!).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'price' => a.price.compareTo(b.price),
        'flowersCount' => a.flowersCount.compareTo(b.flowersCount),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    // num.clamp возвращает num, а не int, и в sublist его передать нельзя
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Bouquet>[] : rows.sublist(from, to);

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Bouquet?> findById(int id) async {
    await _network.request();
    for (final b in _bouquets) {
      if (b.id == id) return b;
    }
    return null;
  }

  @override
  Future<List<Bouquet>> findByFlorist(int floristId) async {
    await _network.request();
    return _bouquets
        .where((b) => !b.isDeleted && b.floristIds.contains(floristId))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<Bouquet> create(Bouquet bouquet) async {
    await _network.request();
    final created = bouquet.copyWith(id: _nextId++);
    _bouquets.add(created);
    return created;
  }

  @override
  Future<Bouquet> update(Bouquet bouquet) async {
    await _network.request();
    final i = _bouquets.indexWhere((b) => b.id == bouquet.id);
    if (i == -1) throw StateError('Букет ${bouquet.id} не найден');
    _bouquets[i] = bouquet;
    return bouquet;
  }

  @override
  Future<void> softDelete(int id) async {
    await _network.request();
    final i = _bouquets.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Букет $id не найден');
    _bouquets[i] = _bouquets[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    await _network.request();
    _bouquets.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> restore(int id) async {
    await _network.request();
    final i = _bouquets.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Букет $id не найден');
    _bouquets[i] = _bouquets[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    await _network.request();
    var count = 0;
    for (final id in ids) {
      final i = _bouquets.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        _bouquets[i] = _bouquets[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
