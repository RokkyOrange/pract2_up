import '../models/author.dart';
import '../models/author_query.dart';
import '../models/page_result.dart';
import 'author_repository.dart';
import 'fake_network.dart';
import 'seed_data.dart';

class InMemoryAuthorRepository implements AuthorRepository {
  final FakeNetwork _network;
  final List<Author> _authors = [...seedAuthors];
  int _nextId = seedAuthors.length + 1;

  InMemoryAuthorRepository(this._network);

  @override
  Future<PageResult<Author>> find(AuthorQuery q) async {
    await _network.request();

    var rows = _authors.where((a) => q.includeDeleted || !a.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((a) =>
              a.lastName.toLowerCase().contains(needle) ||
              a.country.toLowerCase().contains(needle))
          .toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'birthYear' => a.birthYear.compareTo(b.birthYear),
        'country' => a.country.compareTo(b.country),
        _ => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Author>[] : rows.sublist(from, to);

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Author?> findById(int id) async {
    await _network.request();
    for (final a in _authors) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<List<Author>> findByIds(List<int> ids) async {
    await _network.request();
    return _authors.where((a) => ids.contains(a.id)).toList();
  }

  @override
  Future<Author> create(Author author) async {
    await _network.request();
    final created = author.copyWith(id: _nextId++);
    _authors.add(created);
    return created;
  }

  @override
  Future<Author> update(Author author) async {
    await _network.request();
    final i = _authors.indexWhere((a) => a.id == author.id);
    if (i == -1) throw StateError('Автор ${author.id} не найден');
    _authors[i] = author;
    return author;
  }

  @override
  Future<void> softDelete(int id) async {
    await _network.request();
    final i = _authors.indexWhere((a) => a.id == id);
    if (i == -1) throw StateError('Автор $id не найден');
    _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    await _network.request();
    _authors.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> restore(int id) async {
    await _network.request();
    final i = _authors.indexWhere((a) => a.id == id);
    if (i == -1) throw StateError('Автор $id не найден');
    _authors[i] = _authors[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    await _network.request();
    var count = 0;
    for (final id in ids) {
      final i = _authors.indexWhere((a) => a.id == id && !a.isDeleted);
      if (i != -1) {
        _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
