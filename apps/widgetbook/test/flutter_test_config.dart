import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup_ds_tokens/wakeup_ds_tokens.dart';

/// flutter_test không nạp font thật; nạp Inter để golden giống app.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader('packages/${DsFont.package}/${DsFont.family}');
  for (final weight in ['Regular', 'Medium', 'SemiBold']) {
    loader.addFont(
      rootBundle.load(
        'packages/${DsFont.package}/fonts/inter/Inter-$weight.ttf',
      ),
    );
  }
  await loader.load();
  await testMain();
}
