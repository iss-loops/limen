import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:limen_domain/limen_domain.dart';

import '../../../core/providers.dart';
import '../../session/session_controller.dart';
import 'progress_controller.dart';

/// Estado de un envío de respuesta. Unión sellada: la UI hace pattern matching.
sealed class SubmissionState {
  const SubmissionState();
}

final class SubmissionIdle extends SubmissionState {
  const SubmissionIdle();
}

final class SubmissionSending extends SubmissionState {
  const SubmissionSending();
}

/// El servidor respondió: [result] dice si fue correcta (dato esperado).
final class SubmissionDone extends SubmissionState {
  final SubmitResult result;
  const SubmissionDone(this.result);
}

/// Fallo de transporte/autorización (no es "respuesta incorrecta").
final class SubmissionFailed extends SubmissionState {
  final String code;
  const SubmissionFailed(this.code);
}

/// Orquesta el envío de una respuesta de un nodo. La validación ocurre en el
/// servidor; aquí solo transportamos y reflejamos el resultado.
class SubmitController extends FamilyNotifier<SubmissionState, String> {
  @override
  SubmissionState build(String arg) => const SubmissionIdle();

  Future<void> submit(String rawAnswer) async {
    state = const SubmissionSending();

    final String token;
    try {
      token = await ref.read(sessionProvider.future);
    } catch (_) {
      state = const SubmissionFailed('NETWORK');
      return;
    }

    final api = ref.read(apiClientProvider);
    final res = await api.submit(token, SubmitRequest(nodeId: arg, answer: rawAnswer));

    switch (res) {
      case Ok(:final value):
        if (value.correct) {
          ref.read(progressProvider.notifier).onSolved(arg, value.nextNodeId);
        }
        state = SubmissionDone(value);
      case Err(:final code):
        state = SubmissionFailed(code);
    }
  }

  void reset() => state = const SubmissionIdle();
}

final submitProvider =
    NotifierProvider.family<SubmitController, SubmissionState, String>(
        SubmitController.new);
