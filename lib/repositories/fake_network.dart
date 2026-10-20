class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => message;
}

/// Имитация сети для репозиториев в памяти: задержка ответа
/// и возможность «отключить сервер», чтобы проверить экран ошибки.
class FakeNetwork {
  bool offline = false;

  Future<void> request() async {
    // Без задержки индикатор загрузки невозможно увидеть,
    // а в ПР4 он понадобится по-настоящему.
    await Future.delayed(const Duration(milliseconds: 500));
    if (offline) {
      throw const NetworkException('сервер не отвечает');
    }
  }
}
