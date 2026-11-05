import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'app/app.dart';

void main() {
  tzdata.initializeTimeZones();
  runApp(const ProviderScope(child: WakeupApp()));
}
