import 'package:meta/meta.dart';

/// Ngày lịch không kèm giờ: ngày dự định của task, ngày làm việc (QC-01).
///
/// Lưu trong Postgres kiểu `date`, truyền qua API dạng `YYYY-MM-DD`.
@immutable
class CalendarDate implements Comparable<CalendarDate> {
  CalendarDate(int year, int month, int day)
    : this._(DateTime.utc(year, month, day));

  CalendarDate._(DateTime utcMidnight)
    : year = utcMidnight.year,
      month = utcMidnight.month,
      day = utcMidnight.day;

  /// Đọc chuỗi `YYYY-MM-DD`.
  factory CalendarDate.parse(String iso) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
    if (match == null) {
      throw FormatException('Ngày không đúng dạng YYYY-MM-DD', iso);
    }
    final date = CalendarDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
    if (date.toIso() != iso) {
      throw FormatException('Ngày không tồn tại', iso);
    }
    return date;
  }

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  CalendarDate addDays(int days) => CalendarDate(year, month, day + days);

  CalendarDate next() => addDays(1);

  CalendarDate previous() => addDays(-1);

  /// 1 = Thứ Hai … 7 = Chủ Nhật (như [DateTime.weekday]).
  int get weekday => _utc.weekday;

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(CalendarDate other) => _utc.compareTo(other._utc);

  bool isBefore(CalendarDate other) => compareTo(other) < 0;

  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
