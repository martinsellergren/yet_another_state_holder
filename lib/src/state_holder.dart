import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:state_notifier/state_notifier.dart';

class StateHolder<T> extends StateNotifier<T> {
  StateHolder(super.state);

  // visible to anyone, unlike super's
  @override
  T get state => super.state;

  @internal
  @override
  set state(T value) => super.state = value;

  void setState(T Function(T state) fn) {
    if (!mounted) return;
    state = fn(state);
  }

  Stream<T> get startedStream => stream.startWith(state);
}
