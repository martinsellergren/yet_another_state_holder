import 'package:rxdart/rxdart.dart';
import 'package:state_notifier/state_notifier.dart';

class StateHolder<T> extends StateNotifier<T> {
  StateHolder(super.state);

  // visible to anyone, unlike super's
  @override
  T get state => super.state;

  Stream<T> get startedStream => stream.startWith(state);
}
