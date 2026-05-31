import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network/api_client.dart';
import 'storage/session_storage.dart';

final dioProvider = Provider<Dio>((ref) => buildDio());

final apiClientProvider =
    Provider<LimenApiClient>((ref) => LimenApiClient(ref.watch(dioProvider)));

final sessionStorageProvider =
    Provider<SessionStorage>((ref) => SessionStorage());
