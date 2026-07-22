import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/di/providers.dart' show currentSessionProvider;
import '../domain/models/sse_event.dart';
import '../services/sse_service.dart';

final authTokenProvider = Provider<String?>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session?.token;
});

class SseServiceController extends Notifier<SseService?> {
  @override
  SseService? build() => null;

  void setService(SseService? service) {
    state = service;
  }
}

final sseServiceProvider =
    NotifierProvider<SseServiceController, SseService?>(
        SseServiceController.new);

final sseEventStreamProvider = StreamProvider<SseEvent>((ref) {
  final service = ref.watch(sseServiceProvider);
  if (service == null) return const Stream.empty();
  return service.eventStream;
});

final siniestroSseProvider =
    StreamProvider.family<SseEvent, String>((ref, siniestroId) {
  final token = ref.watch(authTokenProvider);
  if (token == null) return const Stream.empty();

  final url =
      '${ApiConstants.baseUrl}${ApiConstants.eventsStreamSiniestro(siniestroId)}';
  final service = SseService(url: url, token: token);
  ref.onDispose(() => service.disconnect());

  return service.eventStream;
});
