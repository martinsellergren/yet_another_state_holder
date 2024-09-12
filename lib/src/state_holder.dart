import 'package:rxdart/rxdart.dart';
import 'package:state_notifier/state_notifier.dart';

class StateHolder<T> extends StateNotifier<T> {
  StateHolder(super.state);

  @override
  T get state => super.state;

  @override
  set state(T value) {
    if (mounted) super.state = value;
  }

  Stream<T> get startedStream => stream.startWith(state);
}
