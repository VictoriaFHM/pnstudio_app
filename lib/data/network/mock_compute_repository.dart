import '../models/compute_request.dart';
import '../models/compute_response.dart';

/// Mock repository para TESTEAR sin backend
/// Genera respuestas ficticias pero realistas
class MockComputeRepository {
  /// Simula respuesta del backend
  Future<ComputeResponse> compute(ComputeRequest req) async {
    // Simula latencia de red
    await Future.delayed(const Duration(seconds: 2));

    // Validaciones básicas
    if (req.vth <= 0 || req.rth <= 0) {
      throw Exception('Vth y Rth deben ser mayores a 0');
    }

    // Calcula Pmax simple: P = V²/R
    final pmax = (req.vth * req.vth) / req.rth;

    // Usa k y c si están disponibles, si no usa valores por defecto
    final k = req.k ?? (req.kPercent != null ? req.kPercent! / 100 : 0.6);
    final c = req.c ?? (req.cPercent != null ? req.cPercent! / 100 : 0.85);

    // Calcula rangos
    final rlMin = req.rth * (1 - k);
    final rlMax = req.rth * (1 + k);
    final recommendedRl = req.rth; // Teorema de máxima potencia

    final etaMin = 0.5;
    final etaMax = 0.95;
    final etaAtRec = (c * (req.rth / (req.rth + recommendedRl))).clamp(0.0, 1.0);

    final pMin = req.pMinW ?? 0.1;
    final pMaxByK = pmax * c;
    final pAtRec = (req.vth * req.vth * recommendedRl) / ((req.rth + recommendedRl) * (req.rth + recommendedRl));

    return ComputeResponse(
      feasible: pMaxByK >= pMin,
      pmax: pmax,
      rlMin: rlMin,
      rlMax: rlMax,
      etaMin: etaMin,
      etaMax: etaMax,
      pMin: pMin,
      pMaxByK: pMaxByK,
      recommendedRl: recommendedRl,
      etaAtRec: etaAtRec,
      pAtRec: pAtRec,
    );
  }
}
