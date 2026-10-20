import 'package:flutter/foundation.dart';

import '../models/author.dart';
import '../models/author_query.dart';
import '../models/page_result.dart';
import '../repositories/author_repository.dart';
import 'load_status.dart';

class AuthorListNotifier extends ChangeNotifier {
  final AuthorRepository _repository;

  AuthorListNotifier(this._repository);

  AuthorQuery _query = const AuthorQuery();
  PageResult<Author> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;

  AuthorQuery get query => _query;
  PageResult<Author> get result => _result;
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
      _error = 'Не удалось загрузить список авторов: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(AuthorQuery next) async {
    _query = next;
    await load();
  }

  Future<void> search(String text) => applyQuery(_query.copyWith(search: text));

  Future<void> goToPage(int page) => applyQuery(_query.copyWith(page: page));

  Future<Author?> findById(int id) => _repository.findById(id);

  Future<List<Author>> findByIds(List<int> ids) => _repository.findByIds(ids);
}
