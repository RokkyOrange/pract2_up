import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import 'book_repository.dart';
import 'fake_network.dart';
import 'seed_data.dart';

class InMemoryBookRepository implements BookRepository {
  final FakeNetwork _network;
  final List<Book> _books = [...seedBooks];
  int _nextId = seedBooks.length + 1;

  InMemoryBookRepository(this._network);

  @override
  Future<PageResult<Book>> find(BookQuery q) async {
    await _network.request();

    var rows = _books.where((b) => q.includeDeleted || !b.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((b) =>
              b.title.toLowerCase().contains(needle) ||
              b.isbn.toLowerCase().contains(needle))
          .toList();
    }
    if (q.genreId != null) {
      rows = rows.where((b) => b.genreIds.contains(q.genreId)).toList();
    }
    if (q.publisherId != null) {
      rows = rows.where((b) => b.publisherId == q.publisherId).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((b) => b.year >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((b) => b.year <= q.yearTo!).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'pages' => a.pages.compareTo(b.pages),
        _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    // num.clamp возвращает num, а не int, и в sublist его передать нельзя
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Book>[] : rows.sublist(from, to);

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Book?> findById(int id) async {
    await _network.request();
    for (final b in _books) {
      if (b.id == id) return b;
    }
    return null;
  }

  @override
  Future<List<Book>> findByAuthor(int authorId) async {
    await _network.request();
    return _books
        .where((b) => !b.isDeleted && b.authorIds.contains(authorId))
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));
  }

  @override
  Future<Book> create(Book book) async {
    await _network.request();
    final created = book.copyWith(id: _nextId++);
    _books.add(created);
    return created;
  }

  @override
  Future<Book> update(Book book) async {
    await _network.request();
    final i = _books.indexWhere((b) => b.id == book.id);
    if (i == -1) throw StateError('Книга ${book.id} не найдена');
    _books[i] = book;
    return book;
  }

  @override
  Future<void> softDelete(int id) async {
    await _network.request();
    final i = _books.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Книга $id не найдена');
    _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    await _network.request();
    _books.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> restore(int id) async {
    await _network.request();
    final i = _books.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Книга $id не найдена');
    _books[i] = _books[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    await _network.request();
    var count = 0;
    for (final id in ids) {
      final i = _books.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
