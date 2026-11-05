import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:wakeup_core/wakeup_core.dart';

const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

Response jsonResponse(Object? body, {int status = 200}) =>
    Response(status, body: jsonEncode(body), headers: _jsonHeaders);

/// Trả lỗi theo dạng chuẩn `{error: {code, message, details}}`.
Response errorResponse(
  int status,
  ErrorCode code, {
  String message = '',
  Map<String, Object?> details = const {},
}) => jsonResponse(
  ApiError(code, message: message, details: details).toJson(),
  status: status,
);
