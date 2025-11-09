// lib/features/calculator/controller/calculator_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart'; // AsyncValue, Ref
import 'package:flutter_riverpod/legacy.dart'; // StateNotifier, StateNotifierProvider

import 'package:pnstudio_app/data/models/compute_request.dart';
import 'package:pnstudio_app/data/models/compute_response.dart';
import 'package:pnstudio_app/data/repositories/compute_repository.dart';
import 'package:pnstudio_app/features/mode_select/models/input_mode.dart';

/// Repository provider (DISPONIBLE GLOBALMENTE)
final computeRepositoryProvider = Provider<ComputeRepository>((ref) {
  return ComputeRepository();
});

/// ---------- STATE ----------
class CalculatorState {
  final InputMode mode;
  final ComputeRequest? lastRequest;
  final AsyncValue<ComputeResponse?> result;

  const CalculatorState({
    required this.mode,
    this.lastRequest,
    // genérico explícito ayuda con Riverpod 3:
    this.result = const AsyncValue<ComputeResponse?>.data(null),
  });

  CalculatorState copyWith({
    InputMode? mode,
    ComputeRequest? lastRequest,
    AsyncValue<ComputeResponse?>? result,
  }) {
    return CalculatorState(
      mode: mode ?? this.mode,
      lastRequest: lastRequest ?? this.lastRequest,
      result: result ?? this.result,
    );
  }
}

/// ---------- CONTROLLER ----------
final calculatorControllerProvider =
    StateNotifierProvider.family<
      CalculatorController,
      CalculatorState,
      InputMode
    >((ref, mode) => CalculatorController(ref, mode));

class CalculatorController extends StateNotifier<CalculatorState> {
  final Ref ref;
  CalculatorController(this.ref, InputMode mode)
    : super(CalculatorState(mode: mode));

  /// Envía la petición y devuelve la respuesta (o null si falla)
  Future<ComputeResponse?> submit(ComputeRequest req) async {
    state = state.copyWith(
      result: const AsyncValue<ComputeResponse?>.loading(),
      lastRequest: req,
    );

    try {
      final repo = ref.read(computeRepositoryProvider);
      final resp = await repo.compute(req);
      state = state.copyWith(result: AsyncValue<ComputeResponse?>.data(resp));
      return resp;
    } catch (e, st) {
      state = state.copyWith(result: AsyncValue<ComputeResponse?>.error(e, st));
      return null;
    }
  }
}
