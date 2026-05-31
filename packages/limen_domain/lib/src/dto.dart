// DTOs del contrato de API (forma estable). Compartidos por app y servidor.
//
// Envoltura de éxito: { "data": {...}, "meta": { "v": 1 } }
// Envoltura de error: { "error": { "code": "...", "message": "..." } }

/// Respuesta de `POST /api/v1/session`.
class SessionResponse {
  final String token;
  const SessionResponse(this.token);

  Map<String, dynamic> toJson() => {'token': token};
  static SessionResponse fromJson(Map<String, dynamic> json) =>
      SessionResponse(json['token'] as String);
}

/// Cuerpo de `POST /api/v1/submit`.
class SubmitRequest {
  final String nodeId;
  final String answer;
  const SubmitRequest({required this.nodeId, required this.answer});

  Map<String, dynamic> toJson() => {'nodeId': nodeId, 'answer': answer};
  static SubmitRequest fromJson(Map<String, dynamic> json) => SubmitRequest(
        nodeId: json['nodeId'] as String,
        answer: json['answer'] as String,
      );
}

/// Resultado de `POST /api/v1/submit`.
class SubmitResult {
  final bool correct;
  final String? nextNodeId;
  final String? narrative;
  const SubmitResult({required this.correct, this.nextNodeId, this.narrative});

  Map<String, dynamic> toJson() => {
        'correct': correct,
        'nextNodeId': nextNodeId,
        'narrative': narrative,
      };
  static SubmitResult fromJson(Map<String, dynamic> json) => SubmitResult(
        correct: json['correct'] as bool,
        nextNodeId: json['nextNodeId'] as String?,
        narrative: json['narrative'] as String?,
      );
}

/// Códigos de error del contrato (enum compartido, no strings ad hoc).
class ApiErrorCode {
  static const nodeLocked = 'NODE_LOCKED';
  static const notFound = 'NOT_FOUND';
  static const badRequest = 'BAD_REQUEST';
  static const unauthorized = 'UNAUTHORIZED';
}
