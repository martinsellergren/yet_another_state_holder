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
  })  : _store = store,
        _stateToJson = stateToJson,
        _storageKey = storageKey,
        super(
          store.restoreHydrated(
                  storageKey: storageKey, stateFromJson: stateFromJson) ??
              initialState,
        );

  @override
  void dispose({bool clearStorage = false}) {
    if (clearStorage) _store.remove(_storageKey);
    super.dispose();
  }

  @override
  set state(T value) {
    if (!mounted) return;
    super.state = value;
    _store.storeForHydration(
        storageKey: _storageKey, state: value, stateToJson: _stateToJson);
  }
}

extension HydratedStateHolderStateStore on StateStore {
  void storeForHydration<T>({
    required String storageKey,
    required T state,
    required Map<String, dynamic> Function(T state) stateToJson,
  }) {
    put(storageKey, jsonEncode(stateToJson(state)));
  }

  T? restoreHydrated<T>({
    required String storageKey,
    required T Function(Map<String, dynamic> json) stateFromJson,
  }) {
    final json = get(storageKey);
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
