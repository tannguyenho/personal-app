// Ca chuẩn QC-01 (docs/01-quy-tac-dung-chung.md): dùng chung cho app, server và
// bộ đánh giá AI của G10. Mốc 04:00, timezone Asia/Ho_Chi_Minh.
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:wakeup_core/wakeup_core.dart';

/// Giờ Việt Nam (UTC+7, không có giờ mùa hè) đổi sang UTC.
DateTime vn(int month, int day, int hour, [int minute = 0]) =>
    DateTime.utc(2026, month, day, hour - 7, minute);

void main() {
  setUpAll(tzdata.initializeTimeZones);

  const vnDefault = WorkdaySettings(
    timezone: 'Asia/Ho_Chi_Minh',
    dayStart: Duration(hours: 4),
  );

  group('QC-01 ca chuẩn', () {
    late WorkdayCalendar calendar;
    setUp(() => calendar = WorkdayCalendar(vnDefault));

    test('03/11 23:30 → hôm nay 03/11, ngày mai 04/11', () {
      final t = vn(11, 3, 23, 30);
      expect(calendar.today(t), CalendarDate(2026, 11, 3));
      expect(calendar.today(t).next(), CalendarDate(2026, 11, 4));
    });

    test('04/11 02:10 → vẫn là ngày làm việc 03/11', () {
      expect(calendar.today(vn(11, 4, 2, 10)), CalendarDate(2026, 11, 3));
    });

    test('04/11 04:00 → sang ngày làm việc 04/11', () {
      expect(calendar.today(vn(11, 4, 4)), CalendarDate(2026, 11, 4));
    });

    test('04/11 03:59 → còn ngày làm việc 03/11', () {
      expect(calendar.today(vn(11, 4, 3, 59)), CalendarDate(2026, 11, 3));
    });

    test('bay sang Paris lúc 04/11 20:00 giờ VN → hôm nay vẫn 04/11', () {
      final cal = WorkdayCalendar(vnDefault);
      final t = vn(11, 4, 20);
      cal.scheduleChange(
        now: t,
        settings: const WorkdaySettings(
          timezone: 'Europe/Paris',
          dayStart: Duration(hours: 4),
        ),
      );
      expect(cal.today(t), CalendarDate(2026, 11, 4));
      // Cài đặt Paris áp từ 05/11 04:00 giờ VN (= 04/11 22:00 giờ Paris).
      // Ngày làm việc không lùi về 04/11.
      expect(cal.today(vn(11, 5, 4)), CalendarDate(2026, 11, 5));
      expect(cal.settingsAt(vn(11, 5, 4)).timezone, 'Europe/Paris');
    });
  });

  group('QC-01 mục 3: đổi cài đặt có hiệu lực từ ngày làm việc kế tiếp', () {
    test('04/11 02:00 đổi mốc sang 00:00 → hôm nay vẫn 03/11', () {
      final cal = WorkdayCalendar(vnDefault);
      final now = vn(11, 4, 2);
      final effectiveAt = cal.scheduleChange(
        now: now,
        settings: const WorkdaySettings(
          timezone: 'Asia/Ho_Chi_Minh',
          dayStart: Duration.zero,
        ),
      );

      expect(cal.today(now), CalendarDate(2026, 11, 3));
      // Ngày hiện tại kết thúc theo cài đặt cũ (04:00), mốc mới áp từ đó.
      expect(effectiveAt, vn(11, 4, 4));
      expect(cal.today(vn(11, 4, 4)), CalendarDate(2026, 11, 4));
      expect(cal.today(vn(11, 4, 23, 59)), CalendarDate(2026, 11, 4));
      // Từ 05/11, ngày làm việc bắt đầu lúc 00:00.
      expect(cal.today(vn(11, 5, 0, 30)), CalendarDate(2026, 11, 5));
    });
  });

  group('WorkdaySettings', () {
    test('mốc đầu ngày ngoài khoảng 00:00–06:00 bị từ chối (G01 BR-14)', () {
      expect(
        () => WorkdaySettings(
          timezone: 'Asia/Ho_Chi_Minh',
          dayStart: const Duration(hours: 7),
        ).validate(),
        throwsArgumentError,
      );
    });
  });

  group('CalendarDate', () {
    test('định dạng ISO và so sánh', () {
      expect(CalendarDate(2026, 11, 5).toIso(), '2026-11-05');
      expect(CalendarDate.parse('2026-11-05'), CalendarDate(2026, 11, 5));
      expect(CalendarDate(2026, 12, 31).next(), CalendarDate(2027, 1, 1));
      expect(
        CalendarDate(2026, 11, 4).compareTo(CalendarDate(2026, 11, 5)),
        lessThan(0),
      );
    });
  });
}
