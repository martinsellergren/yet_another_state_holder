import 'package:yet_another_state_holder/yet_another_state_holder.dart';

class UiState {
  final bool isLoaded;

  UiState({required this.isLoaded});

  UiState copyWith({bool? isLoaded}) =>
      UiState(isLoaded: isLoaded ?? this.isLoaded);
}

class Bloc extends StateHolder<UiState> {
  Bloc() : super(UiState(isLoaded: false)) {
    _init();
  }

  void _init() async {
    await Future.delayed(const Duration(seconds: 1));
    setState((old) => old.copyWith(isLoaded: true));
  }
}
