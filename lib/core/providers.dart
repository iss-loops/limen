import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/puzzle/data/local_gateway.dart';
import 'network/api_client.dart';
import 'network/limen_gateway.dart';
import 'storage/session_storage.dart';

/// Modo offline (seeds embebidos, sin server). Por defecto ON para que el
/// demo abra solo. Usa el servidor real con:
///   flutter run --dart-define=LIMEN_OFFLINE=false
const bool kOfflineMode = bool.fromEnvironment(
  'LIMEN_OFFLINE',
  defaultValue: true,
);

final dioProvider = Provider<Dio>((ref) => buildDio());

/// La puerta al backend: local (offline) o HTTP real, según [kOfflineMode].
final gatewayProvider = Provider<LimenGateway>((ref) =>
    kOfflineMode ? LocalGateway() : LimenApiClient(ref.watch(dioProvider)));

final sessionStorageProvider =
    Provider<SessionStorage>((ref) => SessionStorage());
