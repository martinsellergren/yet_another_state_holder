import 'dart:convert';
import 'dart:developer';

import 'store/store.dart';
import 'yet_another_state_holder.dart';

class HydratedStateHolder<T> extends StateHolder<T> {
  final StateStore _store;
  final Map<String, dynamic> Function(T state) _stateToJson;
  final String _storageKey;

  HydratedStateHolder({
    required T initialState,
    required StateStore store,
    required Map<String, dynamic> Function(T state) stateToJson,
    required T Function(Map<String, dynamic> json) stateFromJson,
    required String storageKey,
  }) : _store = store,
       _stateToJson = stateToJson,
       _storageKey = storageKey,
       super(
         store.restore(key: storageKey, stateFromJson: stateFromJson) ??
             initialState,
       );

  @override
  set state(T value) {
    if (!mounted) return;
    super.state = value;
    _store.store(key: _storageKey, state: value, stateToJson: _stateToJson);
  }
}

extension on StateStore {
  void store<T>({
    required String key,
    required T state,
    required Map<String, dynamic> Function(T) stateToJson,
  }) {
    put(key, jsonEncode(stateToJson(state)));
  }

  T? restore<T>({
    required String key,
    required T Function(Map<String, dynamic>) stateFromJson,
  }) {
    final json = get(key);
    return json == null
        ? null
        : () {
            try {
              return stateFromJson(jsonDecode(json));
            } catch (e) {
              log(
                '<yet_another_state_holder> Failed to restoring state from persistent storage, e=$e, json=$json',
              );
              return null;
            }
          }();
  }
}
