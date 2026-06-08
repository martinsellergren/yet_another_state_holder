import 'store.dart';

class InMemoryStore implements StateStore {
  final Map<String, String> _map = {};

  @override
  String? get(String key) => _map[key];

  @override
  void put(String key, String value) {
    _map[key] = value;
  }
}
