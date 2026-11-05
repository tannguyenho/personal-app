import 'package:test/test.dart';
import 'package:wakeup_core/wakeup_core.dart';

void main() {
  test('Command tự sinh commandId UUIDv7 và giữ nguyên qua JSON', () {
    final cmd = Command(type: 'task.create', payload: {'title': 'Viết SRS'});
    expect(cmd.commandId, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(cmd.commandId[14], '7', reason: 'UUID phiên bản 7');

    final back = Command.fromJson(cmd.toJson());
    expect(back.commandId, cmd.commandId);
    expect(back.type, 'task.create');
    expect(back.payload, {'title': 'Viết SRS'});
    expect(back.schemaVersion, commandSchemaVersion);
  });

  test('lệnh của AI bắt buộc có aiTurnId', () {
    expect(
      () => Command(type: 'task.move', payload: const {}, actor: Actor.ai),
      throwsArgumentError,
    );
  });

  test('ApiError đọc mã lạ thành unknown', () {
    final err = ApiError.fromJson({
      'error': {'code': 'SOMETHING_NEW', 'message': 'x'},
    });
    expect(err.code, ErrorCode.unknown);
    expect(ApiError(ErrorCode.versionConflict).toJson(), {
      'error': {'code': 'VERSION_CONFLICT', 'message': ''},
    });
  });
}
