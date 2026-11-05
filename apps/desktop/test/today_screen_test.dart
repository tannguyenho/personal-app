import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:wakeup_desktop/app/app.dart';
import 'package:wakeup_desktop/app/providers.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  testWidgets('trước 04:00 vẫn hiện ngày làm việc hôm trước (QC-01)', (
    tester,
  ) async {
    // 04/11/2026 02:10 giờ Việt Nam.
    final now = DateTime.utc(2026, 11, 3, 19, 10);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [clockProvider.overrideWithValue(() => now)],
        child: const WakeupApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today-label')), findsOneWidget);
    expect(find.text('Hôm nay 2026-11-03'), findsOneWidget);
  });
}
