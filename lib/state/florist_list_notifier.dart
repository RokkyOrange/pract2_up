import 'package:flutter/foundation.dart';

import '../models/florist.dart';
import '../models/florist_query.dart';
import '../models/page_result.dart';
import '../repositories/florist_repository.dart';
import 'load_status.dart';

class FloristListNotifier extends ChangeNotifier {
  final FloristRepository _repository;

  FloristListNotifier(this._repository);

  FloristQuery _query = const FloristQuery();
  PageResult<Florist> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;

  FloristQuery get query => _query;
  PageResult<Florist> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список флористов: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(FloristQuery next) async {
    _query = next;
    await load();
  }

  Future<void> search(String text) => applyQuery(_query.copyWith(search: text));

  Future<void> goToPage(int page) => applyQuery(_query.copyWith(page: page));

  Future<Florist?> findById(int id) => _repository.findById(id);

  Future<List<Florist>> findByIds(List<int> ids) => _repository.findByIds(ids);
}
