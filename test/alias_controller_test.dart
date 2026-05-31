import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iss/core/providers.dart';
import 'package:iss/core/storage/session_storage.dart';
import 'package:iss/features/session/alias_controller.dart';

class _FakeStorage extends SessionStorage {
  String? alias;
  @override
  Future<String?> readAlias() async => alias;
  @override
  Future<void> writeAlias(String a) async => alias = a;
}

void main() {
  test('arranca con el alias inyectado (bootstrap)', () {
    final container = ProviderContainer(
      overrides: [aliasBootstrapProvider.overrideWithValue('neo')],
    );
    addTearDown(container.dispose);
    expect(container.read(aliasProvider), 'neo');
  });

  test('arranca en null si no hay alias', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(aliasProvider), isNull);
  });

  test('setAlias recorta, persiste y actualiza el estado', () async {
    final fake = _FakeStorage();
    final container = ProviderContainer(
      overrides: [sessionStorageProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    await container.read(aliasProvider.notifier).setAlias('  Trinity  ');
    expect(container.read(aliasProvider), 'Trinity');
    expect(fake.alias, 'Trinity');
  });

  test('setAlias ignora un alias vacío', () async {
    final container = ProviderContainer(
      overrides: [sessionStorageProvider.overrideWithValue(_FakeStorage())],
    );
    addTearDown(container.dispose);
    await container.read(aliasProvider.notifier).setAlias('   ');
    expect(container.read(aliasProvider), isNull);
  });
}
