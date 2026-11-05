import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:wakeup_core/wakeup_core.dart';

import 'config.dart';
import 'http.dart';
import 'middleware.dart';

/// Dựng handler HTTP. [isDatabaseUp] để `/healthz` báo trạng thái DB.
Handler buildApp(ServerConfig config, {Future<bool> Function()? isDatabaseUp}) {
  final v1 = Router()
    ..get('/app/latest', (Request request) {
      return jsonResponse({
        'version': config.latestClientVersion.toString(),
        'minVersion': config.minClientVersion.toString(),
        'url': config.latestClientUrl,
      });
    })
    // Đồng bộ theo hàng đợi lệnh (ADR-0006). Chưa hiện thực: chỉ kiểm tra
    // hình dạng lô lệnh.
    ..post('/commands', (Request request) async {
      final Object? body;
      try {
        body = jsonDecode(await request.readAsString());
      } on FormatException {
        return errorResponse(
          400,
          ErrorCode.validationFailed,
          message: 'Body không phải JSON',
        );
      }
      if (body is! Map<String, Object?> || body['commands'] is! List) {
        return errorResponse(
          400,
          ErrorCode.validationFailed,
          message: 'Cần {"commands": [...]}',
        );
      }
      try {
        for (final c in body['commands']! as List<Object?>) {
          Command.fromJson(c! as Map<String, Object?>);
        }
      } on Object {
        return errorResponse(
          400,
          ErrorCode.validationFailed,
          message: 'Lệnh không hợp lệ',
        );
      }
      return errorResponse(
        501,
        ErrorCode.notImplemented,
        message: 'Chưa hiện thực xử lý lệnh',
      );
    })
    ..get('/changes', (Request request) {
      return errorResponse(
        501,
        ErrorCode.notImplemented,
        message: 'Chưa hiện thực nguồn thay đổi',
      );
    });

  final root = Router()
    ..get('/healthz', (Request request) async {
      final dbUp = isDatabaseUp == null ? null : await isDatabaseUp();
      return jsonResponse({
        'status': dbUp == false ? 'degraded' : 'ok',
        'database': dbUp,
      }, status: dbUp == false ? 503 : 200);
    })
    ..mount(
      '/v1/',
      const Pipeline()
          .addMiddleware(requireClientVersion(config.minClientVersion))
          .addHandler(v1.call),
    );

  return const Pipeline().addMiddleware(catchErrors()).addHandler((
    request,
  ) async {
    final response = await root.call(request);
    if (response.statusCode == 404 &&
        response.headers['content-type'] == null) {
      return errorResponse(404, ErrorCode.notFound);
    }
    return response;
  });
}
