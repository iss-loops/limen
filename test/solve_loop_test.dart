import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iss/app/l10n/app_localizations.dart';
import 'package:iss/app/theme/theme.dart';
import 'package:iss/core/network/api_client.dart';
import 'package:iss/core/providers.dart';
import 'package:iss/core/storage/session_storage.dart';
import 'package:iss/features/puzzle/presentation/puzzle_screen.dart';
import 'package:limen_domain/limen_domain.dart';

/// Storage en memoria: evita los canales de plataforma en tests.
class _FakeStorage extends SessionStorage {
  String? _token;
  @override
  Future<String?> readToken() async => _token;
  @override
  Future<void> writeToken(String token) async => _token = token;
  @override
  Future<void> clear() async => _token = null;
}

/// API falsa: simula la autoridad server-side para el loop de resolución.
class _FakeApi extends LimenApiClient {
  _FakeApi() : super(Dio());

  @override
  Future<Result<String>> createSession() async => const Ok('test-token');

  @override
  Future<Result<NodeContent>> getNode(String token, String id) async =>
      const Ok(
        NodeContent(
          id: 'node0',
          arco: 0,
          schemaVersion: 1,
          presentation: TextPresentation(body: 'Observa otra vez.'),
          entry: TextEntry(),
        ),
      );

  @override
  Future<Result<SubmitResult>> submit(String token, SubmitRequest req) async {
    if (normalizeAnswer(req.answer) == 'visto') {
      return const Ok(SubmitResult(
        correct: true,
        nextNodeId: 'node1',
        narrative: 'lo viste.',
      ));
    }
    return const Ok(SubmitResult(correct: false));
  }
}

void main() {
  testWidgets('resolver el nodo dispara el decode reveal de la narrativa',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(_FakeApi()),
          sessionStorageProvider.overrideWithValue(_FakeStorage()),
        ],
        child: MaterialApp(
          theme: buildLimenTheme(),
          localizationsDelegates: const [
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppL10n.supportedLocales,
          home: const PuzzleScreen(nodeId: 'node0', bare: true),
        ),
      ),
    );

    // Resuelve sesión + carga del nodo.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(TextField), findsOneWidget);

    // Respuesta incorrecta primero: feedback de la voz del sistema.
    await tester.enterText(find.byType(TextField), 'nada');
    await tester.tap(find.text('enviar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('la señal no reconoce eso.'), findsOneWidget);

    // Respuesta correcta: reveal de la narrativa.
    await tester.enterText(find.byType(TextField), '  VISTO ');
    await tester.tap(find.text('enviar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2)); // decode reveal completa
    expect(find.text('lo viste.'), findsOneWidget);
  });
}
