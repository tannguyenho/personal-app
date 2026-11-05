// Sinh code Dart từ tokens.json (ADR-0008). Không import Flutter để chạy được
// bằng `dart run tool/generate.dart`.

/// Quy ước tên: bỏ tên collection, nối các đoạn còn lại theo camelCase.
/// `color/bg/primary` → `bgPrimary`, `color/text/onPrimary` → `textOnPrimary`.
String fieldName(String variableName) {
  final parts = variableName.split('/');
  final segments = parts.skip(1).toList();
  if (segments.isEmpty) {
    throw FormatException('Tên token thiếu nhóm', variableName);
  }
  final buffer = StringBuffer();
  for (var i = 0; i < segments.length; i++) {
    final s = segments[i].replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (s.isEmpty) continue;
    buffer.write(
      i == 0
          ? s[0].toLowerCase() + s.substring(1)
          : s[0].toUpperCase() + s.substring(1),
    );
  }
  final name = buffer.toString();
  return RegExp(r'^[0-9]').hasMatch(name) ? 'v$name' : name;
}

/// Sinh `DsColors` (ThemeExtension) từ collection `color`. Mỗi mode là một
/// hằng số; alias trong Figma giữ là tham chiếu tới hằng của token gốc.
String generateColors(Map<String, Object?> tokens) {
  final collections = (tokens['collections']! as List<Object?>)
      .cast<Map<String, Object?>>();
  final color = collections.firstWhere(
    (c) => c['name'] == 'color',
    orElse: () => throw const FormatException('Không có collection "color"'),
  );
  final modes = (color['modes']! as List<Object?>).cast<String>();
  final variables =
      (color['variables']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .where((v) => v['type'] == 'COLOR')
          .toList()
        ..sort(
          (a, b) => (a['name']! as String).compareTo(b['name']! as String),
        );

  final names = {
    for (final v in variables)
      v['name']! as String: fieldName(v['name']! as String),
  };
  final seen = <String>{};
  for (final f in names.values) {
    if (!seen.add(f)) throw FormatException('Trùng tên trường sau khi đổi', f);
  }

  String constName(String mode, String field) =>
      '_$mode${field[0].toUpperCase()}${field.substring(1)}';

  String colorLiteral(String hex) {
    final h = hex.replaceFirst('#', '').toUpperCase();
    final argb = switch (h.length) {
      6 => 'FF$h',
      8 => '${h.substring(6)}${h.substring(0, 6)}',
      _ => throw FormatException('Mã màu không hợp lệ', hex),
    };
    return 'Color(0x$argb)';
  }

  final out = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Sinh từ tokens.json bằng `dart run tool/generate.dart`.')
    ..writeln()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln();

  for (final mode in modes) {
    for (final v in variables) {
      final field = names[v['name']]!;
      final value = (v['values']! as Map<String, Object?>)[mode];
      final String expr;
      if (value is String) {
        expr = colorLiteral(value);
      } else if (value is Map && value['alias'] is String) {
        final target = names[value['alias']];
        if (target == null) {
          throw FormatException(
            'Alias trỏ tới token không có',
            '${value['alias']}',
          );
        }
        expr = constName(mode, target);
      } else {
        throw FormatException(
          'Giá trị mode "$mode" không hợp lệ',
          '${v['name']}',
        );
      }
      out.writeln('const ${constName(mode, field)} = $expr;');
    }
    out.writeln();
  }

  final fields = variables.map((v) => names[v['name']]!).toList();
  out
    ..writeln(
      '/// Màu ngữ nghĩa của design system. Một trường = một Figma Variable.',
    )
    ..writeln('@immutable')
    ..writeln('class DsColors extends ThemeExtension<DsColors> {')
    ..writeln('  const DsColors({');
  for (final f in fields) {
    out.writeln('    required this.$f,');
  }
  out
    ..writeln('  });')
    ..writeln();
  for (final mode in modes) {
    out.writeln('  static const $mode = DsColors(');
    for (final f in fields) {
      out.writeln('    $f: ${constName(mode, f)},');
    }
    out
      ..writeln('  );')
      ..writeln();
  }
  for (final v in variables) {
    out
      ..writeln('  /// `${v['name']}`')
      ..writeln('  final Color ${names[v['name']]};');
  }
  out
    ..writeln()
    ..writeln('  @override')
    ..writeln('  DsColors copyWith({');
  for (final f in fields) {
    out.writeln('    Color? $f,');
  }
  out
    ..writeln('  }) {')
    ..writeln('    return DsColors(');
  for (final f in fields) {
    out.writeln('      $f: $f ?? this.$f,');
  }
  out
    ..writeln('    );')
    ..writeln('  }')
    ..writeln()
    ..writeln('  @override')
    ..writeln('  DsColors lerp(DsColors? other, double t) {')
    ..writeln('    if (other == null) return this;')
    ..writeln('    return DsColors(');
  for (final f in fields) {
    out.writeln('      $f: Color.lerp($f, other.$f, t)!,');
  }
  out
    ..writeln('    );')
    ..writeln('  }')
    ..writeln('}');
  return out.toString();
}
