import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../domain/models/sse_event.dart';

class SseService {
  final String url;
  final String token;
  final Duration _maxBackoff = const Duration(seconds: 30);
  final Duration _initialBackoff = const Duration(seconds: 1);

  HttpClient? _client;
  StreamController<SseEvent>? _controller;
  bool _disposed = false;
  int _reconnectAttempts = 0;
  bool _connected = false;

  SseService({required this.url, required this.token});

  Stream<SseEvent> get eventStream {
    _controller ??= StreamController<SseEvent>.broadcast(
      onCancel: () {
        if (!_disposed) disconnect();
      },
    );
    _connect();
    return _controller!.stream;
  }

  bool get isConnected => _connected;

  Future<void> _connect() async {
    if (_disposed || _controller == null) return;
    if (_connected) return;

    _client?.close(force: true);
    _client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final request = await _client!.getUrl(Uri.parse(url));
      request.headers.set('Accept', 'text/event-stream');
      request.headers.set('Cache-Control', 'no-cache');
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();

      if (response.statusCode == 401) {
        _controller?.addError(Exception('Sesión expirada'));
        return;
      }

      if (response.statusCode != 200) {
        _scheduleReconnect();
        return;
      }

      _connected = true;
      _reconnectAttempts = 0;

      _parseStream(response);
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _parseStream(HttpClientResponse response) {
    String buffer = '';

    response.transform(utf8.decoder).listen(
      (data) {
        buffer += data;
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

      String? eventData;

      for (final line in lines) {
        if (line.startsWith('data:')) {
            eventData = line.substring(5).trim();
          } else if (line.isEmpty && eventData != null) {
            _emitEvent(eventData);
            eventData = null;
          }
        }
      },
      onError: (_) {
        _connected = false;
        if (!_disposed) _scheduleReconnect();
      },
      onDone: () {
        _connected = false;
        if (!_disposed) _scheduleReconnect();
      },
      cancelOnError: false,
    );
  }

  void _emitEvent(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final event = SseEvent.fromJson(json);
      _controller?.add(event);
    } catch (_) {}
  }

  void _scheduleReconnect() {
    if (_disposed || _controller == null) return;

    _reconnectAttempts++;
    final backoff = _initialBackoff * (1 << (_reconnectAttempts - 1));
    final delay = backoff > _maxBackoff ? _maxBackoff : backoff;

    Future.delayed(delay, () {
      if (!_disposed) _connect();
    });
  }

  void disconnect() {
    _disposed = true;
    _connected = false;
    _client?.close(force: true);
    _client = null;
    _controller?.close();
    _controller = null;
  }
}
