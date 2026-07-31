import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

class RealtimeEvent {
  const RealtimeEvent(this.type, this.data);
  final String type;
  final Map<String, dynamic> data;
}

/// Một kết nối SSE dùng chung cho chuông thông báo và trò chuyện.
class RealtimeService {
  RealtimeService(this._dio);

  final Dio _dio;
  final _events = StreamController<RealtimeEvent>.broadcast();
  CancelToken? _cancelToken;
  bool _connecting = false;
  bool _stopped = false;
  int _retrySeconds = 1;

  Stream<RealtimeEvent> get events => _events.stream;

  void connect() {
    _stopped = false;
    if (_connecting || _cancelToken != null) return;
    unawaited(_open());
  }

  Future<void> _open() async {
    _connecting = true;
    final token = CancelToken();
    _cancelToken = token;
    try {
      final response = await _dio.get<ResponseBody>(
        '/realtime/events',
        options: Options(
          responseType: ResponseType.stream,
          headers: const {'Accept': 'text/event-stream'},
          receiveTimeout: Duration.zero,
        ),
        cancelToken: token,
      );
      _retrySeconds = 1;
      var buffer = '';
      await for (final bytes
          in utf8.decoder.bind(response.data!.stream.cast<List<int>>())) {
        buffer += bytes;
        var boundary = buffer.indexOf('\n\n');
        while (boundary >= 0) {
          _parseFrame(buffer.substring(0, boundary));
          buffer = buffer.substring(boundary + 2);
          boundary = buffer.indexOf('\n\n');
        }
      }
    } on DioException catch (error) {
      if (!CancelToken.isCancel(error)) {
        _events.add(RealtimeEvent('DISCONNECTED', {
          'message': error.message ?? 'Mất kết nối thời gian thực',
        }));
      }
    } finally {
      if (identical(_cancelToken, token)) _cancelToken = null;
      _connecting = false;
      if (!_stopped) {
        final delay = _retrySeconds;
        _retrySeconds = (_retrySeconds * 2).clamp(1, 15);
        await Future<void>.delayed(Duration(seconds: delay));
        if (!_stopped) unawaited(_open());
      }
    }
  }

  void _parseFrame(String frame) {
    var type = 'MESSAGE';
    final dataLines = <String>[];
    for (final raw in frame.split('\n')) {
      final line = raw.trimRight();
      if (line.startsWith('event:')) type = line.substring(6).trim();
      if (line.startsWith('data:')) dataLines.add(line.substring(5).trim());
    }
    if (dataLines.isEmpty) return;
    try {
      final decoded = jsonDecode(dataLines.join('\n'));
      _events.add(RealtimeEvent(
        type,
        decoded is Map
            ? decoded.cast<String, dynamic>()
            : <String, dynamic>{'value': decoded},
      ));
    } catch (_) {
      _events.add(RealtimeEvent(type, {'value': dataLines.join('\n')}));
    }
  }

  void disconnect() {
    _stopped = true;
    _cancelToken?.cancel('Người dùng đã đăng xuất');
    _cancelToken = null;
  }

  Future<void> dispose() async {
    disconnect();
    await _events.close();
  }
}
