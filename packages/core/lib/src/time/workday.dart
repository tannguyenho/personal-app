import 'package:meta/meta.dart';
import 'package:timezone/timezone.dart' as tz;

import 'calendar_date.dart';

/// Cài đặt quyết định ngày làm việc của một người dùng (QC-01, G01 BR-14).
///
/// Trước khi dùng phải nạp dữ liệu múi giờ một lần, ví dụ
/// `import 'package:timezone/data/latest_all.dart'; initializeTimeZones();`.
/// App và server phải dùng cùng một phiên bản package `timezone`.
@immutable
class WorkdaySettings {
  const WorkdaySettings({required this.timezone, required this.dayStart});

  /// Mặc định: mốc 04:00 (QC-01 mục 1).
  static const defaultDayStart = Duration(hours: 4);

  static const _maxDayStart = Duration(hours: 6);

  /// Tên múi giờ IANA, ví dụ `Asia/Ho_Chi_Minh`.
  final String timezone;

  /// Mốc đầu ngày tính từ nửa đêm, trong khoảng 00:00–06:00.
  final Duration dayStart;

  /// Ném [ArgumentError] nếu cài đặt không hợp lệ.
  void validate() {
    if (dayStart.isNegative || dayStart > _maxDayStart) {
      throw ArgumentError.value(
        dayStart,
        'dayStart',
        'Mốc đầu ngày phải nằm trong 00:00–06:00',
      );
    }
    tz.getLocation(timezone);
  }

  tz.Location get location => tz.getLocation(timezone);

  @override
  bool operator ==(Object other) =>
      other is WorkdaySettings &&
      other.timezone == timezone &&
      other.dayStart == dayStart;

  @override
  int get hashCode => Object.hash(timezone, dayStart);
}

/// `workday(t)` của QC-01 mục 2: ngày lịch của (t − mốc đầu ngày) theo
/// timezone của người dùng.
///
/// Phép trừ làm trên giờ tường (wall clock), nên đổi giờ mùa hè không làm
/// lệch mốc đầu ngày.
CalendarDate workdayOf(DateTime instant, WorkdaySettings settings) {
  final local = tz.TZDateTime.from(instant, settings.location);
  final wall = DateTime.utc(
    local.year,
    local.month,
    local.day,
    local.hour,
    local.minute,
    local.second,
    local.millisecond,
    local.microsecond,
  ).subtract(settings.dayStart);
  return CalendarDate(wall.year, wall.month, wall.day);
}

/// Thời điểm bắt đầu của ngày làm việc [date] theo [settings].
DateTime startOfWorkday(CalendarDate date, WorkdaySettings settings) {
  final minutes = settings.dayStart.inMinutes;
  return tz.TZDateTime(
    settings.location,
    date.year,
    date.month,
    date.day,
    minutes ~/ 60,
    minutes % 60,
  ).toUtc();
}

/// Lịch sử cài đặt ngày làm việc của một người dùng.
///
/// Đổi mốc đầu ngày hoặc timezone có hiệu lực từ ngày làm việc kế tiếp; ngày
/// hiện tại kết thúc theo cài đặt cũ (QC-01 mục 3).
class WorkdayCalendar {
  WorkdayCalendar(WorkdaySettings initial)
    : _entries = [_Entry(null, null, initial)] {
    initial.validate();
  }

  final List<_Entry> _entries;

  /// Cài đặt đang áp dụng tại [instant].
  WorkdaySettings settingsAt(DateTime instant) => _entryAt(instant).settings;

  /// "Hôm nay" (ngày làm việc) tại [instant].
  CalendarDate today(DateTime instant) {
    final entry = _entryAt(instant);
    final computed = workdayOf(instant, entry.settings);
    // Đổi timezone về phía tây có thể làm ngày tính ra lùi lại; ngày làm việc
    // không bao giờ lùi về trước ngày mà cài đặt mới bắt đầu có hiệu lực.
    final floor = entry.effectiveDate;
    return floor != null && computed.isBefore(floor) ? floor : computed;
  }

  /// Hẹn đổi cài đặt lúc [now]. Trả về thời điểm cài đặt mới có hiệu lực, là
  /// lúc ngày làm việc hiện tại kết thúc theo cài đặt cũ. Lần hẹn sau thay cho
  /// lần hẹn trước chưa có hiệu lực.
  DateTime scheduleChange({
    required DateTime now,
    required WorkdaySettings settings,
  }) {
    settings.validate();
    final current = _entryAt(now);
    final nextDay = today(now).next();
    final effectiveAt = startOfWorkday(nextDay, current.settings);
    _entries.removeWhere(
      (e) => e.effectiveAt != null && !e.effectiveAt!.isBefore(effectiveAt),
    );
    _entries.add(_Entry(effectiveAt, nextDay, settings));
    return effectiveAt;
  }

  _Entry _entryAt(DateTime instant) => _entries.lastWhere(
    (e) => e.effectiveAt == null || !instant.isBefore(e.effectiveAt!),
  );
}

class _Entry {
  _Entry(this.effectiveAt, this.effectiveDate, this.settings);

  /// `null` với cài đặt ban đầu.
  final DateTime? effectiveAt;

  /// Ngày làm việc đầu tiên dùng cài đặt này.
  final CalendarDate? effectiveDate;

  final WorkdaySettings settings;
}
