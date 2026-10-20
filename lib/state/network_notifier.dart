import 'package:flutter/foundation.dart';

import '../repositories/fake_network.dart';

/// Переключатель «сервер недоступен» для демонстрации экрана ошибки.
class NetworkNotifier extends ChangeNotifier {
  final FakeNetwork _network;

  NetworkNotifier(this._network);

  bool get offline => _network.offline;

  void setOffline(bool value) {
    _network.offline = value;
    notifyListeners();
  }
}
