// lib/features/calculator/controller/calculator_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/compute_request.dart';
import '../../../data/models/compute_response.dart';
import '../../../data/repositories/compute_repository.dart';
import '../../mode_select/models/input_mode.dart';

class CalculatorState {
  final InputMode mode;
  final bool loading;
  final String? error;
  final ComputeResponse? result;

  const CalculatorState({
    required this.mode,
    this.loading = false,
    this.error,
    this.result,
  });

  CalculatorState copyWith({
    InputMode? mode,
    bool? loading,
    String? error,
    ComputeResponse? result,
    bool clearResult = false,
  }) {
    return CalculatorState(
      mode: mode ?? this.mode,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

// ✅ Usamos Notifier (Riverpod v3) — más simple que StateNotifier
class CalculatorController extends Notifier<CalculatorState> {
  late final ComputeRepository _repo;

  @override
  CalculatorState build() {
    _repo = ComputeRepository();
    // estado inicial
    return const CalculatorState(mode: InputMode.basico);
  }

  Future<void> compute(ComputeRequest req) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final res = await _repo.compute(req);
      state = state.copyWith(loading: false, result: res, error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);

  void setMode(InputMode m) =>
      state = state.copyWith(mode: m, clearResult: true, error: null);
}

// ✅ Provider simple con Notifier
final calculatorControllerProvider =
    NotifierProvider<CalculatorController, CalculatorState>(
      CalculatorController.new,
    );
