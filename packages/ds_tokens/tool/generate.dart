// Đọc tokens.json, ghi lib/src/ds_colors.g.dart.
// Chạy trong packages/ds_tokens: `dart run tool/generate.dart`.
import 'dart:convert';
import 'dart:io';

import 'generator.dart';

void main() {
  final tokens = jsonDecode(
    File('tokens.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final out = File('lib/src/ds_colors.g.dart');
  out.writeAsStringSync(generateColors(tokens));
  stdout.writeln('Đã ghi ${out.path}');
}
