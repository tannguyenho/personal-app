import 'package:shelf/shelf.dart';
import 'package:wakeup_core/wakeup_core.dart';

import 'config.dart';
import 'http.dart';

/// Header client gửi kèm mọi request tới `/v1` (docs/tech/01 mục 6).
const appVersionHeader = 'x-app-version';

/// Chặn app cũ hơn `minClientVersion` bằng `CLIENT_TOO_OLD`. Request không
/// kèm header (trình duyệt, webhook lịch) đi qua bình thường.
Middleware requireClientVersion(AppVersion minVersion) {
  return (inner) => (request) {
    final raw = request.headers[appVersionHeader];
    if (raw == null) return inner(request);
    final AppVersion version;
    try {
      version = AppVersion.parse(raw);
    } on FormatException {
      return errorResponse(
        400,
        ErrorCode.validationFailed,
        message: 'X-App-Version không hợp lệ',
      );
    }
    if (version.compareTo(minVersion) < 0) {
      return errorResponse(
        426,
        ErrorCode.clientTooOld,
        message: 'Cần cập nhật app',
        details: {'minClientVersion': minVersion.toString()},
      );
    }
    return inner(request);
  };
}

/// Bắt lỗi chưa xử lý, trả `INTERNAL` thay vì lộ stack trace.
Middleware catchErrors() {
  return (inner) => (request) async {
    try {
      return await inner(request);
    } on Object catch (error, stack) {
      // TODO(observability): gửi Sentry (docs/tech/01 mục 9).
      print('Lỗi chưa xử lý: $error\n$stack');
      return errorResponse(500, ErrorCode.internal);
    }
  };
}
