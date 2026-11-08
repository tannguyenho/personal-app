import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup_ds_tokens/wakeup_ds_tokens.dart';

import '../tool/generator.dart';

void main() {
  test(
    'code sinh ra khớp tokens.json (chạy `dart run tool/generate.dart`)',
    () {
      final tokens = jsonDecode(
        File('tokens.json').readAsStringSync(),
      ) as Map<String, Object?>;
      final expected = generateColors(tokens);
      final actual = File('lib/src/ds_colors.g.dart').readAsStringSync();
      expect(
        actual,
        expected,
        reason: 'tokens.json đã đổi mà chưa sinh lại code',
      );
    },
  );

  test('tên token map 1-1 sang tên trường (ca chung với plugin Codegen)', () {
    final cases =
        ((jsonDecode(File('test/naming_cases.json').readAsStringSync())
                    as Map<String, Object?>)['tokenFieldName']!
                as List<Object?>)
            .cast<Map<String, Object?>>();
    expect(cases, isNotEmpty);
    for (final c in cases) {
      expect(fieldName(c['in']! as String), c['out'], reason: '$c');
    }
  });

  test('alias giữ đúng giá trị của token gốc ở từng mode', () {
    expect(DsColors.light.bgPrimary, DsColors.light.brand500);
    expect(DsColors.dark.bgPrimary, DsColors.dark.brand500);
    expect(DsColors.light.brand500, const Color(0xFF4F46E5));
  });
}
