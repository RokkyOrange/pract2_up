import 'package:flower_shop/models/bouquet_query.dart';
import 'package:flower_shop/models/florist_query.dart';
import 'package:flower_shop/repositories/fake_network.dart';
import 'package:flower_shop/repositories/in_memory_bouquet_repository.dart';
import 'package:flower_shop/repositories/in_memory_florist_repository.dart';
import 'package:flower_shop/repositories/seed_data.dart';
import 'package:flower_shop/state/bouquet_list_notifier.dart';
import 'package:flower_shop/state/load_status.dart';
import 'package:flower_shop/widgets/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('начальный набор: не меньше 20 букетов и 8 флористов', () {
    expect(seedBouquets.length, greaterThanOrEqualTo(20));
    expect(seedFlorists.length, greaterThanOrEqualTo(8));
  });

  test('первая страница букетов содержит 10 записей из 24', () async {
    final repo = InMemoryBouquetRepository(FakeNetwork());
    final page = await repo.find(const BouquetQuery());
    expect(page.items.length, 10);
    expect(page.total, seedBouquets.length);
    expect(page.totalPages, 3);
  });

  test('поиск букетов по названию и пустой результат', () async {
    final repo = InMemoryBouquetRepository(FakeNetwork());
    final found = await repo.find(const BouquetQuery(search: 'облако'));
    expect(found.items.single.name, 'Пионовое облако');
    final empty = await repo.find(const BouquetQuery(search: 'кактус'));
    expect(empty.items, isEmpty);
  });

  test('поиск флористов по городу', () async {
    final repo = InMemoryFloristRepository(FakeNetwork());
    final page = await repo.find(const FloristQuery(search: 'казань'));
    expect(page.total, 2);
  });

  test('copyWith не меняет исходный объект и умеет сбросить deletedAt', () {
    final bouquet = seedBouquets.first;
    final deleted = bouquet.copyWith(deletedAt: DateTime(2026));
    expect(bouquet.isDeleted, isFalse);
    expect(deleted.isDeleted, isTrue);
    expect(deleted.copyWith(clearDeletedAt: true).isDeleted, isFalse);
  });

  test('ошибка сервера переводит список в состояние error', () async {
    final network = FakeNetwork()..offline = true;
    final notifier = BouquetListNotifier(InMemoryBouquetRepository(network));
    await notifier.load();
    expect(notifier.status, LoadStatus.error);
    expect(notifier.error, isNotNull);
  });

  test('форматирование цены и стажа', () {
    expect(formatPrice(19990), '19 990 ₽');
    expect(formatYears(3), '3 года');
    expect(formatYears(12), '12 лет');
    expect(formatYears(21), '21 год');
  });
}
