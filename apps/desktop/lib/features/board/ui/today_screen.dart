import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// Khung tạm của board ngày (G04). Chỉ hiện ngày làm việc hiện tại.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    return Scaffold(
      body: Center(
        child: Text(
          'Hôm nay ${today.toIso()}',
          key: const Key('today-label'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
