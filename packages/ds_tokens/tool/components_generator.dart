// Sinh lớp hợp đồng component từ components.json (ADR-0008).
// Không import Flutter để chạy được bằng `dart run tool/generate.dart`.
//
// Mỗi component Figma sinh ra:
// - một enum cho mỗi variant property (`DsButtonType`);
// - lớp `DsButtonBase extends StatelessWidget` chứa tên tham số, kiểu và giá
//   trị mặc định. Widget thật `extends` lớp này, nên đổi tên / xoá property
//   trong Figma làm code biên dịch lỗi.

import 'naming.dart';

/// Một tham số widget sinh từ một property Figma.
class _Param {
  _Param({
    required this.figmaName,
    required this.figmaType,
    required this.name,
    required this.type,
    required this.defaultExpr,
  });

  final String figmaName;
  final String figmaType;
  final String name;

  /// Kiểu Dart, ví dụ `String`, `bool`, `Widget?`, `DsButtonType`.
  final String type;

  /// Giá trị mặc định; `null` nghĩa là tham số `required` (hoặc nullable).
  final String? defaultExpr;

  bool get isRequired => defaultExpr == null && !type.endsWith('?');
}

class _Enum {
  _Enum(this.name, this.figmaProperty, this.values);

  final String name;
  final String figmaProperty;

  /// Giá trị Figma → tên giá trị enum, giữ thứ tự trong Figma.
  final Map<String, String> values;
}

String _dartString(String s) {
  final escaped = s
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$')
      .replaceAll('\n', r'\n');
  return "'$escaped'";
}

String _docLines(String text, String indent) => text
    .trim()
    .split('\n')
    .map(
      (l) =>
          l.trimRight().isEmpty ? '$indent///' : '$indent/// ${l.trimRight()}',
    )
    .join('\n');

/// Sinh `ds_components.g.dart` từ nội dung components.json.
String generateComponents(Map<String, Object?> json) {
  final components =
      (json['components']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .where((c) => isExportedComponent(c['name']! as String))
          .toList()
        ..sort(
          (a, b) =>
              componentClassName(a['name']! as String)
                  .compareTo(componentClassName(b['name']! as String)),
        );

  final classNames = <String, String>{};
  for (final c in components) {
    final figmaName = c['name']! as String;
    final cls = componentClassName(figmaName);
    final other = classNames[cls];
    if (other != null) {
      throw FormatException(
        'Hai component cùng ra tên widget $cls: "$other" và "$figmaName"',
      );
    }
    classNames[cls] = figmaName;
  }

  final out = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Sinh từ components.json bằng `dart run tool/generate.dart`.')
    ..writeln()
    ..writeln("import 'package:flutter/widgets.dart';");

  for (final c in components) {
    _writeComponent(out, c);
  }
  return out.toString();
}

void _writeComponent(StringBuffer out, Map<String, Object?> c) {
  final figmaName = c['name']! as String;
  final cls = componentClassName(figmaName);
  final description = (c['description'] as String?) ?? '';
  final properties = ((c['properties'] as List<Object?>?) ?? const [])
      .cast<Map<String, Object?>>();

  final enums = <_Enum>[];
  final params = <_Param>[];
  final seen = <String, String>{};

  for (final p in properties) {
    final pFigma = p['name']! as String;
    final pType = p['type']! as String;
    final name = propertyName(pFigma);
    final previous = seen[name];
    if (previous != null) {
      throw FormatException(
        '$figmaName: "$previous" và "$pFigma" cùng ra tham số $name',
      );
    }
    seen[name] = pFigma;
    final defaultValue = p['default'];

    switch (pType) {
      case 'VARIANT':
        final options = (p['options']! as List<Object?>).cast<String>();
        if (isBooleanVariant(options)) {
          params.add(
            _Param(
              figmaName: pFigma,
              figmaType: pType,
              name: name,
              type: 'bool',
              defaultExpr: '${'$defaultValue'.toLowerCase() == 'true'}',
            ),
          );
          continue;
        }
        final enumName = enumTypeName(figmaName, pFigma);
        final values = <String, String>{};
        final valueNames = <String>{};
        for (final o in options) {
          final v = enumValueName(o);
          if (!valueNames.add(v)) {
            throw FormatException(
              '$figmaName.$name: hai giá trị cùng ra $v',
              o,
            );
          }
          values[o] = v;
        }
        final defaultName = values[defaultValue];
        if (defaultName == null) {
          throw FormatException(
            '$figmaName.$name: giá trị mặc định không có trong danh sách',
            '$defaultValue',
          );
        }
        enums.add(_Enum(enumName, pFigma, values));
        if (isInteractionState(pFigma)) continue;
        params.add(
          _Param(
            figmaName: pFigma,
            figmaType: pType,
            name: name,
            type: enumName,
            defaultExpr: '$enumName.$defaultName',
          ),
        );
      case 'BOOLEAN':
        params.add(
          _Param(
            figmaName: pFigma,
            figmaType: pType,
            name: name,
            type: 'bool',
            defaultExpr: '${defaultValue == true}',
          ),
        );
      case 'TEXT':
        // Nội dung mặc định trong Figma là chữ mẫu, không đưa vào code.
        params.add(
          _Param(
            figmaName: pFigma,
            figmaType: pType,
            name: name,
            type: 'String',
            defaultExpr: null,
          ),
        );
      case 'INSTANCE_SWAP' || 'SLOT':
        params.add(
          _Param(
            figmaName: pFigma,
            figmaType: pType,
            name: name,
            type: 'Widget?',
            defaultExpr: null,
          ),
        );
      default:
        throw FormatException(
          '$figmaName: kiểu property chưa hỗ trợ',
          '$pFigma: $pType',
        );
    }
  }

  params.sort((a, b) {
    if (a.isRequired != b.isRequired) return a.isRequired ? -1 : 1;
    return a.name.compareTo(b.name);
  });

  for (final e in enums) {
    final interaction = isInteractionState(e.figmaProperty);
    out
      ..writeln()
      ..writeln('/// `$figmaName` · `${stripPropertyId(e.figmaProperty)}`.');
    if (interaction) {
      out.writeln(
        '/// Trạng thái tương tác, widget tự quản lý; dùng cho Widgetbook và '
        'golden test.',
      );
    }
    out.writeln('enum ${e.name} {');
    final entries = e.values.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final end = i == entries.length - 1 ? ';' : ',';
      out.writeln('  ${entries[i].value}(${_dartString(entries[i].key)})$end');
    }
    out
      ..writeln()
      ..writeln('  const ${e.name}(this.figmaValue);')
      ..writeln()
      ..writeln('  /// Giá trị variant trong Figma.')
      ..writeln('  final String figmaValue;')
      ..writeln('}');
  }

  out
    ..writeln()
    ..writeln('/// Hợp đồng tham số của component Figma `$figmaName`.');
  if (description.trim().isNotEmpty) {
    out
      ..writeln('///')
      ..writeln(_docLines(description, ''));
  }
  out
    ..writeln('///')
    ..writeln('/// Widget `$cls` phải `extends` lớp này.')
    ..writeln('abstract class ${cls}Base extends StatelessWidget {');
  if (params.isEmpty) {
    out.writeln('  const ${cls}Base({super.key});');
  } else {
    out
      ..writeln('  const ${cls}Base({')
      ..writeln('    super.key,');
    for (final p in params) {
      if (p.isRequired) {
        out.writeln('    required this.${p.name},');
      } else if (p.defaultExpr != null) {
        out.writeln('    this.${p.name} = ${p.defaultExpr},');
      } else {
        out.writeln('    this.${p.name},');
      }
    }
    out.writeln('  });');
  }
  for (final p in params) {
    out
      ..writeln()
      ..writeln('  /// `${stripPropertyId(p.figmaName)}` (${p.figmaType}).')
      ..writeln('  final ${p.type} ${p.name};');
  }
  out.writeln('}');
}
