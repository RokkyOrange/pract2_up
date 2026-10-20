import 'package:flutter/foundation.dart';

import '../models/bouquet.dart';
import '../models/bouquet_query.dart';
import '../models/page_result.dart';
import '../repositories/bouquet_repository.dart';
import 'load_status.dart';

class BouquetListNotifier extends ChangeNotifier {
  final BouquetRepository _repository;

  BouquetListNotifier(this._repository);

  BouquetQuery _query = const BouquetQuery();
  PageResult<Bouquet> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  BouquetQuery get query => _query;
  PageResult<Bouquet> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список букетов: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(BouquetQuery next) async {
    _query = next;
    _selected.clear(); // выделение теряет смысл при смене условий отбора
    await load();
  }

  Future<void> search(String text) => applyQuery(_query.copyWith(search: text));

  Future<void> goToPage(int page) => applyQuery(_query.copyWith(page: page));

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  /// Для карточки букета: отдельная выборка, список при этом не меняется.
  Future<Bouquet?> findById(int id) => _repository.findById(id);

  Future<List<Bouquet>> findByFlorist(int floristId) =>
      _repository.findByFlorist(floristId);
}
