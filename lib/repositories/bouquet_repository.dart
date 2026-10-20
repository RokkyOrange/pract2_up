import '../models/bouquet.dart';
import '../models/bouquet_query.dart';
import '../models/page_result.dart';

abstract interface class BouquetRepository {
  Future<PageResult<Bouquet>> find(BouquetQuery query);
  Future<Bouquet?> findById(int id);
  Future<List<Bouquet>> findByFlorist(int floristId);
  Future<Bouquet> create(Bouquet bouquet);
  Future<Bouquet> update(Bouquet bouquet);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}
