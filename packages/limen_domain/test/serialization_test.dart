import 'package:limen_domain/limen_domain.dart';
import 'package:test/test.dart';

void main() {
  group('NodeContent round-trip', () {
    test('texto + entrada de texto sobrevive a JSON', () {
      const node = NodeContent(
        id: 'node1',
        arco: 0,
        schemaVersion: 1,
        presentation: TextPresentation(body: 'gsviv rh', glyph: false),
        entry: TextEntry(placeholder: 'descífralo'),
      );
      final restored = NodeContent.fromJson(node.toJson());
      expect(restored.id, 'node1');
      expect(restored.arco, 0);
      expect(restored.schemaVersion, 1);
      expect(restored.presentation, isA<TextPresentation>());
      expect((restored.presentation as TextPresentation).body, 'gsviv rh');
      expect(restored.entry, isA<TextEntry>());
      expect((restored.entry as TextEntry).placeholder, 'descífralo');
    });

    test('presentación glyph preserva intensity', () {
      const node = NodeContent(
        id: 'closing',
        arco: 0,
        schemaVersion: 1,
        presentation:
            TextPresentation(body: 'has sido visto', glyph: true, intensity: 1),
        entry: NumericEntry(),
      );
      final restored = NodeContent.fromJson(node.toJson());
      final p = restored.presentation as TextPresentation;
      expect(p.glyph, isTrue);
      expect(p.intensity, 1);
      expect(restored.entry, isA<NumericEntry>());
    });
  });

  group('DTOs round-trip', () {
    test('SubmitRequest', () {
      const req = SubmitRequest(nodeId: 'node1', answer: 'brutus');
      final r = SubmitRequest.fromJson(req.toJson());
      expect(r.nodeId, 'node1');
      expect(r.answer, 'brutus');
    });

    test('SubmitResult con desbloqueo', () {
      const res = SubmitResult(
          correct: true, nextNodeId: 'node2', narrative: 'sigue');
      final r = SubmitResult.fromJson(res.toJson());
      expect(r.correct, isTrue);
      expect(r.nextNodeId, 'node2');
      expect(r.narrative, 'sigue');
    });

    test('SubmitResult fallido sin desbloqueo', () {
      const res = SubmitResult(correct: false);
      final r = SubmitResult.fromJson(res.toJson());
      expect(r.correct, isFalse);
      expect(r.nextNodeId, isNull);
      expect(r.narrative, isNull);
    });

    test('SessionResponse', () {
      final r = SessionResponse.fromJson(const SessionResponse('tok').toJson());
      expect(r.token, 'tok');
    });
  });

  group('ValidationRule round-trip', () {
    test('cada variante sobrevive a JSON', () {
      for (final rule in <ValidationRule>[
        const ExactRule(),
        const NormalizedRule(),
        const RegexRule(r'^x$'),
        const NumericToleranceRule(0.5),
      ]) {
        final restored = ValidationRule.fromJson(rule.toJson());
        expect(restored.runtimeType, rule.runtimeType);
      }
    });

    test('RegexRule preserva el patrón', () {
      final r = ValidationRule.fromJson(const RegexRule(r'^ab$').toJson());
      expect((r as RegexRule).pattern, r'^ab$');
    });

    test('NumericToleranceRule preserva la tolerancia', () {
      final r =
          ValidationRule.fromJson(const NumericToleranceRule(2.5).toJson());
      expect((r as NumericToleranceRule).tolerance, 2.5);
    });
  });
}
