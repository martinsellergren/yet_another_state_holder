import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'state_holder.dart';

class HydratedStateHolder<T> extends StateHolder<T> {
  final SharedPreferences _sharedPreferences;
  final Map<String, dynamic> Function(T state) _stateToJson;
  final String storageKey;

  HydratedStateHolder(
    T state, {
    required SharedPreferences sharedPreferences,
    required Map<String, dynamic> Function(T state) stateToJson,
    required T Function(Map<String, dynamic> json) stateFromJson,
    required this.storageKey,
  })  : _sharedPreferences = sharedPreferences,
        _stateToJson = stateToJson,
        super(sharedPreferences.restore(
              key: storageKey,
              stateFromJson: stateFromJson,
            ) ??
            state);

  @override
  set state(T value) {
    if (!mounted) return;
    super.state = value;
    _sharedPreferences.store(
      key: storageKey,
      state: value,
      stateToJson: _stateToJson,
    );
  }
}

extension on SharedPreferences {
  void store<T>({
    required String key,
    required T state,
    required Map<String, dynamic> Function(T) stateToJson,
  }) {
    setString(key, jsonEncode(stateToJson(state)));
  }

  T? restore<T>({
    required String key,
    required T Function(Map<String, dynamic>) stateFromJson,
  }) {
    final json = getString(key);
    return json == null ? null : stateFromJson(jsonDecode(json));
  }
}
