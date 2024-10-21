import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'state_holder.dart';

class HydratedStateHolder<T> extends StateHolder<T> {
  final SharedPreferences _sharedPreferences;
  final Map<String, dynamic> Function(T state) _stateToJson;
  final String _storageKey;

  HydratedStateHolder({
    required T initialState,
    required SharedPreferences sharedPreferences,
    required Map<String, dynamic> Function(T state) stateToJson,
    required T Function(Map<String, dynamic> json) stateFromJson,
    required String storageKey,
  })  : _sharedPreferences = sharedPreferences,
        _stateToJson = stateToJson,
        _storageKey = storageKey,
        super(sharedPreferences.restore(
              key: storageKey,
              stateFromJson: stateFromJson,
            ) ??
            initialState);

  @override
  set state(T value) {
    if (!mounted) return;
    super.state = value;
    _sharedPreferences.store(
      key: _storageKey,
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
    return json == null
        ? null
        : () {
            try {
              return stateFromJson(jsonDecode(json));
            } catch (e) {
              debugPrint(
                  'yet_another_state_holder: Failed to restoring state from persistent storage, e=$e, json=$json');
              return null;
            }
          }();
  }
}
