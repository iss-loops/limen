import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iss/core/widgets/decode_text.dart';

void main() {
  testWidgets('al asentarse muestra el texto final', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DecodeText('UMBRAL'))),
    );
    await tester.pumpAndSettle();
    expect(find.text('UMBRAL'), findsOneWidget);
  });

  testWidgets('expone el texto final a accesibilidad', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DecodeText('LIMEN'))),
    );
    await tester.pump();
    expect(find.bySemanticsLabel('LIMEN'), findsOneWidget);
    await tester.pumpAndSettle();
    handle.dispose();
  });

  testWidgets('reduce motion degrada a fade y muestra el texto', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: DecodeText('UMBRAL')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('UMBRAL'), findsOneWidget);
  });
}
