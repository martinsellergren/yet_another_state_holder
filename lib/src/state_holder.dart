import 'dart:async';

class StateHolder<T> {
  final _streamController = StreamController<T>.broadcast();
  bool _mounted = true;

  T _state;

  StateHolder(this._state);

  void dispose() {
    _mounted = false;
    _streamController.close();
  }

  T get state => _state;

  set state(T nw) {
    if (state == nw || !mounted) return;
    _state = nw;
    _streamController.add(nw);
  }

  Stream<T> get stream => _streamController.stream;
  bool get mounted => _mounted;

  Stream<T> get startedStream async* {
    yield state;
    yield* stream;
  }
}
