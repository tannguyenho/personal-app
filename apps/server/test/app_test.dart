import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:wakeup_core/wakeup_core.dart';
import 'package:wakeup_server/wakeup_server.dart';

void main() {
  final config = ServerConfig.fromEnvironment({
    'MIN_CLIENT_VERSION': '0.2.0',
    'LATEST_CLIENT_VERSION': '0.3.0',
  });
  final app = buildApp(config);

  Future<Response> send(
    String method,
    String path, {
    Map<String, String>? headers,
    String? body,
  }) async => app(
    Request(
      method,
      Uri.parse('http://localhost$path'),
      headers: headers,
      body: body,
    ),
  );

  Future<Map<String, Object?>> json(Response r) async =>
      jsonDecode(await r.readAsString()) as Map<String, Object?>;

  test('/healthz trả ok khi không cấu hình DB', () async {
    final r = await send('GET', '/healthz');
    expect(r.statusCode, 200);
    expect((await json(r))['status'], 'ok');
  });

  test('/healthz trả 503 khi DB không phản hồi', () async {
    final r = await buildApp(config, isDatabaseUp: () async => false)(
      Request('GET', Uri.parse('http://localhost/healthz')),
    );
    expect(r.statusCode, 503);
  });

  test('app cũ hơn minClientVersion nhận CLIENT_TOO_OLD', () async {
    final r = await send(
      'GET',
      '/v1/app/latest',
      headers: {'x-app-version': '0.1.9+5'},
    );
    expect(r.statusCode, 426);
    expect(ApiError.fromJson(await json(r)).code, ErrorCode.clientTooOld);
  });

  test('/v1/app/latest trả phiên bản mới nhất', () async {
    final r = await send(
      'GET',
      '/v1/app/latest',
      headers: {'x-app-version': '0.2.0'},
    );
    expect(r.statusCode, 200);
    expect((await json(r))['version'], '0.3.0');
  });

  test('POST /v1/commands kiểm tra hình dạng lô lệnh', () async {
    final bad = await send('POST', '/v1/commands', body: '{"x": 1}');
    expect(bad.statusCode, 400);
    expect(ApiError.fromJson(await json(bad)).code, ErrorCode.validationFailed);

    final ok = await send(
      'POST',
      '/v1/commands',
      body: jsonEncode({
        'commands': [
          Command(type: 'task.create', payload: {'title': 'A'}).toJson(),
        ],
      }),
    );
    expect(ok.statusCode, 501);
    expect(ApiError.fromJson(await json(ok)).code, ErrorCode.notImplemented);
  });

  test('đường dẫn lạ trả NOT_FOUND theo dạng lỗi chuẩn', () async {
    final r = await send('GET', '/khong-co');
    expect(r.statusCode, 404);
    expect(ApiError.fromJson(await json(r)).code, ErrorCode.notFound);
  });
}
