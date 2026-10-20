import '../models/florist.dart';
import '../models/florist_query.dart';
import '../models/page_result.dart';

abstract interface class FloristRepository {
  Future<PageResult<Florist>> find(FloristQuery query);
  Future<Florist?> findById(int id);
  Future<List<Florist>> findByIds(List<int> ids);
  Future<Florist> create(Florist florist);
  Future<Florist> update(Florist florist);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}
