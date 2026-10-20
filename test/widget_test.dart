import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/models/author_query.dart';
import 'package:library_app/models/book_query.dart';
import 'package:library_app/repositories/fake_network.dart';
import 'package:library_app/repositories/in_memory_author_repository.dart';
import 'package:library_app/repositories/in_memory_book_repository.dart';
import 'package:library_app/repositories/seed_data.dart';
import 'package:library_app/state/book_list_notifier.dart';
import 'package:library_app/state/load_status.dart';

void main() {
  test('начальный набор: не меньше 20 книг и 8 авторов', () {
    expect(seedBooks.length, greaterThanOrEqualTo(20));
    expect(seedAuthors.length, greaterThanOrEqualTo(8));
  });

  test('первая страница книг содержит 10 записей из 24', () async {
    final repo = InMemoryBookRepository(FakeNetwork());
    final page = await repo.find(const BookQuery());
    expect(page.items.length, 10);
    expect(page.total, seedBooks.length);
    expect(page.totalPages, 3);
  });

  test('поиск книг по названию и пустой результат', () async {
    final repo = InMemoryBookRepository(FakeNetwork());
    final found = await repo.find(const BookQuery(search: 'мастер'));
    expect(found.items.single.title, 'Мастер и Маргарита');
    final empty = await repo.find(const BookQuery(search: 'гарри поттер'));
    expect(empty.items, isEmpty);
  });

  test('поиск авторов по стране', () async {
    final repo = InMemoryAuthorRepository(FakeNetwork());
    final page = await repo.find(const AuthorQuery(search: 'сша'));
    expect(page.total, 2);
  });

  test('copyWith не меняет исходный объект и умеет сбросить deletedAt', () {
    final book = seedBooks.first;
    final deleted = book.copyWith(deletedAt: DateTime(2026));
    expect(book.isDeleted, isFalse);
    expect(deleted.isDeleted, isTrue);
    expect(deleted.copyWith(clearDeletedAt: true).isDeleted, isFalse);
  });

  test('ошибка сервера переводит список в состояние error', () async {
    final network = FakeNetwork()..offline = true;
    final notifier = BookListNotifier(InMemoryBookRepository(network));
    await notifier.load();
    expect(notifier.status, LoadStatus.error);
    expect(notifier.error, isNotNull);
  });
}
