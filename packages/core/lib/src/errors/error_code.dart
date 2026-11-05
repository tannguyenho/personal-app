import 'package:meta/meta.dart';

/// Mã lỗi chung của API (docs/tech/01 mục 6). Client ánh xạ mã sang MSG của
/// SRS tương ứng; `message` chỉ để debug.
enum ErrorCode {
  // Đồng bộ (QC-08)
  versionConflict('VERSION_CONFLICT'),
  taskDeleted('TASK_DELETED'),
  alreadyRepeating('ALREADY_REPEATING'),

  // Nghiệp vụ
  pastDate('PAST_DATE'),
  validationFailed('VALIDATION_FAILED'),
  notFound('NOT_FOUND'),

  // AI (G10)
  aiOffline('AI_OFFLINE'),

  // Phiên, phiên bản, giới hạn
  unauthenticated('UNAUTHENTICATED'),
  sessionRevoked('SESSION_REVOKED'),
  clientTooOld('CLIENT_TOO_OLD'),
  rateLimited('RATE_LIMITED'),

  // Hệ thống
  notImplemented('NOT_IMPLEMENTED'),
  internal('INTERNAL'),

  /// Mã server trả về mà bản app này chưa biết.
  unknown('UNKNOWN');

  const ErrorCode(this.wire);

  /// Chuỗi truyền qua API.
  final String wire;

  static ErrorCode fromWire(String value) => ErrorCode.values.firstWhere(
    (c) => c.wire == value,
    orElse: () => ErrorCode.unknown,
  );
}

/// Thân lỗi chuẩn: `{"error": {"code", "message", "details"}}`.
@immutable
class ApiError {
  const ApiError(this.code, {this.message = '', this.details = const {}});

  factory ApiError.fromJson(Map<String, Object?> json) {
    final error = json['error'];
    if (error is! Map<String, Object?>) {
      throw const FormatException('Thiếu trường "error"');
    }
    return ApiError(
      ErrorCode.fromWire(error['code'] as String? ?? ''),
      message: error['message'] as String? ?? '',
      details: (error['details'] as Map<String, Object?>?) ?? const {},
    );
  }

  final ErrorCode code;
  final String message;
  final Map<String, Object?> details;

  Map<String, Object?> toJson() => {
    'error': {
      'code': code.wire,
      'message': message,
      if (details.isNotEmpty) 'details': details,
    },
  };

  @override
  String toString() => 'ApiError(${code.wire}: $message)';
}
