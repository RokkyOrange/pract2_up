import '../models/florist.dart';
import '../models/florist_query.dart';
import '../models/page_result.dart';
import 'fake_network.dart';
import 'florist_repository.dart';
import 'seed_data.dart';

class InMemoryFloristRepository implements FloristRepository {
  final FakeNetwork _network;
  final List<Florist> _florists = [...seedFlorists];
  int _nextId = seedFlorists.length + 1;

  InMemoryFloristRepository(this._network);

  @override
  Future<PageResult<Florist>> find(FloristQuery q) async {
    await _network.request();

    var rows =
        _florists.where((f) => q.includeDeleted || !f.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((f) =>
              f.lastName.toLowerCase().contains(needle) ||
              f.city.toLowerCase().contains(needle))
          .toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'experienceYears' => a.experienceYears.compareTo(b.experienceYears),
        'city' => a.city.compareTo(b.city),
        _ => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Florist>[] : rows.sublist(from, to);

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Florist?> findById(int id) async {
    await _network.request();
    for (final f in _florists) {
      if (f.id == id) return f;
    }
    return null;
  }

  @override
  Future<List<Florist>> findByIds(List<int> ids) async {
    await _network.request();
    return _florists.where((f) => ids.contains(f.id)).toList();
  }

  @override
  Future<Florist> create(Florist florist) async {
    await _network.request();
    final created = florist.copyWith(id: _nextId++);
    _florists.add(created);
    return created;
  }

  @override
  Future<Florist> update(Florist florist) async {
    await _network.request();
    final i = _florists.indexWhere((f) => f.id == florist.id);
    if (i == -1) throw StateError('Флорист ${florist.id} не найден');
    _florists[i] = florist;
    return florist;
  }

  @override
  Future<void> softDelete(int id) async {
    await _network.request();
    final i = _florists.indexWhere((f) => f.id == id);
    if (i == -1) throw StateError('Флорист $id не найден');
    _florists[i] = _florists[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    await _network.request();
    _florists.removeWhere((f) => f.id == id);
  }

  @override
  Future<void> restore(int id) async {
    await _network.request();
    final i = _florists.indexWhere((f) => f.id == id);
    if (i == -1) throw StateError('Флорист $id не найден');
    _florists[i] = _florists[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    await _network.request();
    var count = 0;
    for (final id in ids) {
      final i = _florists.indexWhere((f) => f.id == id && !f.isDeleted);
      if (i != -1) {
        _florists[i] = _florists[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
