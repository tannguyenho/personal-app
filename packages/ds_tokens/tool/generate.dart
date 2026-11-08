// Đọc tokens.json, components.json, snowflakes.json; ghi
// lib/src/ds_colors.g.dart, lib/src/ds_components.g.dart,
// lib/src/snowflake_components.g.dart.
// Chạy trong packages/ds_tokens: `dart run tool/generate.dart`.
import 'dart:convert';
import 'dart:io';

import 'components_generator.dart';
import 'generator.dart';
import 'naming.dart';

Map<String, Object?> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

void main() {
  final colors = File('lib/src/ds_colors.g.dart')
    ..writeAsStringSync(generateColors(_readJson('tokens.json')));
  stdout.writeln('Đã ghi ${colors.path}');

  final components = File('lib/src/ds_components.g.dart')
    ..writeAsStringSync(generateComponents(_readJson('components.json')));
  stdout.writeln('Đã ghi ${components.path}');

  final snowflakes = File('lib/src/snowflake_components.g.dart')
    ..writeAsStringSync(
      generateComponents(
        _readJson('snowflakes.json'),
        tier: ComponentTier.snowflake,
      ),
    );
  stdout.writeln('Đã ghi ${snowflakes.path}');
}
