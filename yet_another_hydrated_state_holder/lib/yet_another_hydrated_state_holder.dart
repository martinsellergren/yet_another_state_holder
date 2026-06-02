import 'dart:convert';
import 'dart:developer';

import 'package:hive_ce/hive.dart';
import 'package:yet_another_state_holder/yet_another_state_holder.dart';

class HydratedStateHolder<T> extends StateHolder<T> {
  final Box<String> _box;
  final Map<String, dynamic> Function(T state) _stateToJson;
  final String _storageKey;

  HydratedStateHolder({
    required T initialState,
    required Box<String> box,
    required Map<String, dynamic> Function(T state) stateToJson,
    required T Function(Map<String, dynamic> json) stateFromJson,
    required String storageKey,
  })  : _box = box,
        _stateToJson = stateToJson,
        _storageKey = storageKey,
        super(box.restore(
              key: storageKey,
              stateFromJson: stateFromJson,
            ) ??
            initialState);

  @override
  set state(T value) {
    if (!mounted) return;
    super.state = value;
    _box.store(
      key: _storageKey,
      state: value,
      stateToJson: _stateToJson,
    );
  }
}

extension on Box<String> {
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
              log('<yet_another_state_holder> Failed to restoring state from persistent storage, e=$e, json=$json');
              return null;
            }
          }();
  }
}
