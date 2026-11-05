import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ds/ds_theme.dart';
import 'router.dart';

class WakeupApp extends ConsumerWidget {
  const WakeupApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Wakeup',
      theme: DsTheme.light(),
      darkTheme: DsTheme.dark(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
