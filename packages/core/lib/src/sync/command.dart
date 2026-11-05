import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// Phiên bản schema của lệnh trong hàng đợi offline (docs/tech/01 mục 6).
/// Tăng khi đổi cấu trúc payload theo cách không tương thích ngược.
const commandSchemaVersion = 1;

/// Ai phát lệnh. Lệnh của AI hiện chip AI và Hoàn tác theo lượt (QC-12).
enum Actor {
  user,
  ai,
  system;

  static Actor fromWire(String value) =>
      Actor.values.firstWhere((a) => a.name == value);
}

/// Một lệnh nghiệp vụ trong hàng đợi đồng bộ (QC-08, ADR-0006).
///
/// `commandId` (UUIDv7) là khoá idempotency: gửi lại cùng lệnh nhận lại đúng
/// kết quả cũ.
@immutable
class Command {
  Command({
    String? commandId,
    required this.type,
    required this.payload,
    this.baseVersion,
    this.actor = Actor.user,
    this.aiTurnId,
    this.schemaVersion = commandSchemaVersion,
  }) : commandId = commandId ?? const Uuid().v7() {
    if (actor == Actor.ai && aiTurnId == null) {
      throw ArgumentError('Lệnh của AI phải có aiTurnId');
    }
  }

  factory Command.fromJson(Map<String, Object?> json) => Command(
    commandId: json['commandId']! as String,
    type: json['type']! as String,
    payload: (json['payload'] as Map<String, Object?>?) ?? const {},
    baseVersion: json['baseVersion'] as int?,
    actor: Actor.fromWire(json['actor'] as String? ?? 'user'),
    aiTurnId: json['aiTurnId'] as String?,
    schemaVersion: json['schemaVersion'] as int? ?? commandSchemaVersion,
  );

  final String commandId;

  /// Tên lệnh, ví dụ `task.create`, `task.move`.
  final String type;

  final Map<String, Object?> payload;

  /// Phiên bản của đối tượng mà client đã thấy khi tạo lệnh. `null` với lệnh
  /// tạo mới.
  final int? baseVersion;

  final Actor actor;

  final String? aiTurnId;

  final int schemaVersion;

  Map<String, Object?> toJson() => {
    'commandId': commandId,
    'type': type,
    'payload': payload,
    if (baseVersion != null) 'baseVersion': baseVersion,
    'actor': actor.name,
    if (aiTurnId != null) 'aiTurnId': aiTurnId,
    'schemaVersion': schemaVersion,
  };
}
