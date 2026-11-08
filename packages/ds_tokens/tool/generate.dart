// Đọc tokens.json và components.json, ghi lib/src/ds_colors.g.dart và
// lib/src/ds_components.g.dart.
// Chạy trong packages/ds_tokens: `dart run tool/generate.dart`.
import 'dart:convert';
import 'dart:io';

import 'components_generator.dart';
import 'generator.dart';

Map<String, Object?> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

void main() {
  final colors = File('lib/src/ds_colors.g.dart')
    ..writeAsStringSync(generateColors(_readJson('tokens.json')));
  stdout.writeln('Đã ghi ${colors.path}');

  final components = File('lib/src/ds_components.g.dart')
    ..writeAsStringSync(generateComponents(_readJson('components.json')));
  stdout.writeln('Đã ghi ${components.path}');
}
