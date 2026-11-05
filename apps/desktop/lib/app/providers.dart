import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakeup_core/wakeup_core.dart';

/// Đồng hồ của app. Test ghi đè provider này để cố định thời điểm.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Cài đặt ngày làm việc của người dùng. Tạm dùng mặc định cho tới khi có G01.
final workdayCalendarProvider = Provider<WorkdayCalendar>((ref) {
  return WorkdayCalendar(
    const WorkdaySettings(
      timezone: 'Asia/Ho_Chi_Minh',
      dayStart: WorkdaySettings.defaultDayStart,
    ),
  );
});

/// "Hôm nay" theo ngày làm việc (QC-01), không theo ngày lịch.
final todayProvider = Provider<CalendarDate>((ref) {
  final now = ref.watch(clockProvider)();
  return ref.watch(workdayCalendarProvider).today(now);
});
