import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup_ds_tokens/wakeup_ds_tokens.dart';

import '../tool/components_generator.dart';
import '../tool/naming.dart';

Map<String, Object?> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

List<Map<String, Object?>> _cases(String group) =>
    (_json('test/naming_cases.json')[group]! as List<Object?>)
        .cast<Map<String, Object?>>();

/// Widget mẫu: widget thật trong app cũng `extends` lớp Base như thế này.
class _SampleButton extends DsButtonBase {
  const _SampleButton({
    required super.label,
    super.disabled,
    super.size,
    super.variant,
  });

  @override
  Widget build(BuildContext context) =>
      Text(label, textDirection: TextDirection.ltr);
}

void main() {
  test(
    'code sinh ra khớp components.json (chạy `dart run tool/generate.dart`)',
    () {
      final expected = generateComponents(_json('components.json'));
      final actual = File('lib/src/ds_components.g.dart').readAsStringSync();
      expect(
        actual,
        expected,
        reason: 'components.json đã đổi mà chưa sinh lại code',
      );
    },
  );

  test(
    'code sinh ra khớp snowflakes.json (chạy `dart run tool/generate.dart`)',
    () {
      final expected = generateComponents(
        _json('snowflakes.json'),
        tier: ComponentTier.snowflake,
      );
      final actual = File('lib/src/snowflake_components.g.dart')
          .readAsStringSync();
      expect(
        actual,
        expected,
        reason: 'snowflakes.json đã đổi mà chưa sinh lại code',
      );
    },
  );

  group('ca tên chuẩn dùng chung với plugin Codegen', () {
    test('snowflakeClassName', () {
      for (final c in _cases('snowflakeClassName')) {
        expect(
          componentClassName(c['in']! as String, ComponentTier.snowflake),
          c['out'],
          reason: '$c',
        );
      }
    });
    test('isExportedSnowflake', () {
      for (final c in _cases('isExportedSnowflake')) {
        expect(
          isExportedComponent(c['in']! as String, ComponentTier.snowflake),
          c['out'],
          reason: '$c',
        );
      }
    });
    test('snowflakeEnumTypeName', () {
      for (final c in _cases('snowflakeEnumTypeName')) {
        expect(
          enumTypeName(
            c['component']! as String,
            c['property']! as String,
            ComponentTier.snowflake,
          ),
          c['out'],
          reason: '$c',
        );
      }
    });
    test('componentClassName', () {
      for (final c in _cases('componentClassName')) {
        expect(componentClassName(c['in']! as String), c['out'], reason: '$c');
      }
    });
    test('isExportedComponent', () {
      for (final c in _cases('isExportedComponent')) {
        expect(isExportedComponent(c['in']! as String), c['out'], reason: '$c');
      }
    });
    test('propertyName', () {
      for (final c in _cases('propertyName')) {
        expect(propertyName(c['in']! as String), c['out'], reason: '$c');
      }
      final invalid =
          (_json('test/naming_cases.json')['propertyNameInvalid']!
                  as List<Object?>)
              .cast<String>();
      for (final name in invalid) {
        expect(() => propertyName(name), throwsFormatException, reason: name);
      }
    });
    test('enumTypeName', () {
      for (final c in _cases('enumTypeName')) {
        expect(
          enumTypeName(c['component']! as String, c['property']! as String),
          c['out'],
          reason: '$c',
        );
      }
    });
    test('enumValueName', () {
      for (final c in _cases('enumValueName')) {
        expect(enumValueName(c['in']! as String), c['out'], reason: '$c');
      }
    });
    test('isBooleanVariant', () {
      for (final c in _cases('isBooleanVariant')) {
        expect(
          isBooleanVariant((c['in']! as List<Object?>).cast<String>()),
          c['out'],
          reason: '$c',
        );
      }
    });
    test('isInteractionState', () {
      for (final c in _cases('isInteractionState')) {
        expect(isInteractionState(c['in']! as String), c['out'], reason: '$c');
      }
    });
  });

  test('Button sinh đúng tham số, kiểu và giá trị mặc định của Figma', () {
    const button = _SampleButton(label: 'Lưu');
    expect(button.variant, DsButtonVariant.primary);
    expect(button.size, DsButtonSize.md);
    expect(button.disabled, isFalse);
    expect(DsButtonVariant.values.map((v) => v.figmaValue), [
      'primary',
      'secondary',
    ]);

    const custom = _SampleButton(
      label: 'Huỷ',
      disabled: true,
      size: DsButtonSize.sm,
      variant: DsButtonVariant.secondary,
    );
    expect(custom.variant, DsButtonVariant.secondary);
    expect(custom.size, DsButtonSize.sm);
    expect(custom.disabled, isTrue);
  });

  group('generateComponents', () {
    String gen(List<Map<String, Object?>> components) =>
        generateComponents({'components': components});

    test('bỏ element và component ẩn', () {
      final code = gen([
        {'name': '--card / Price Label', 'properties': <Object?>[]},
        {'name': '.Hidden', 'properties': <Object?>[]},
        {'name': 'Card', 'properties': <Object?>[]},
      ]);
      expect(code, contains('abstract class DsCardBase'));
      expect(code, isNot(contains('PriceLabel')));
      expect(code, isNot(contains('Hidden')));
    });

    test('state chỉ sinh enum, không thành tham số', () {
      final code = gen([
        {
          'name': 'Chip',
          'properties': [
            {
              'name': 'state',
              'type': 'VARIANT',
              'default': 'default',
              'options': ['default', 'hover', 'disabled'],
            },
          ],
        },
      ]);
      expect(code, contains('enum DsChipState'));
      expect(code, contains("defaultValue('default')"));
      expect(code, isNot(contains('this.state')));
    });

    test('variant true / false thành bool; instance swap thành Widget?', () {
      final code = gen([
        {
          'name': 'Input',
          'properties': [
            {
              'name': 'error',
              'type': 'VARIANT',
              'default': 'false',
              'options': ['false', 'true'],
            },
            {
              'name': 'iconLeading#2:1',
              'type': 'INSTANCE_SWAP',
              'default': 'Icon / Search',
            },
            {'name': 'placeholder#2:2', 'type': 'TEXT', 'default': 'Tìm'},
          ],
        },
      ]);
      expect(code, contains('this.error = false'));
      expect(code, contains('final bool error;'));
      expect(code, contains('final Widget? iconLeading;'));
      expect(code, contains('required this.placeholder'));
      expect(code, isNot(contains('enum DsInputError')));
    });

    test('snowflake giữ tên Figma, không tiền tố; bỏ Base / ...', () {
      final code = generateComponents({
        'components': [
          {
            'name': 'TaskCard',
            'properties': [
              {
                'name': 'state',
                'type': 'VARIANT',
                'default': 'default',
                'options': ['default', 'hover'],
              },
              {'name': 'title#3:1', 'type': 'TEXT', 'default': 'Viết báo cáo'},
            ],
          },
          {'name': 'Base / TaskRow', 'properties': <Object?>[]},
        ],
      }, tier: ComponentTier.snowflake);
      expect(code, contains('Sinh từ snowflakes.json'));
      expect(code, contains('enum TaskCardState'));
      expect(
        code,
        contains('abstract class TaskCardBase extends StatelessWidget'),
      );
      expect(code, contains('Widget `TaskCard` phải `extends` lớp này.'));
      expect(code, contains('required this.title'));
      expect(code, isNot(contains('DsTaskCard')));
      expect(code, isNot(contains('TaskRow')));
    });

    test('danh sách rỗng chỉ sinh phần đầu file', () {
      final code = generateComponents({
        'components': <Object?>[],
      }, tier: ComponentTier.snowflake);
      expect(code, isNot(contains('import')));
    });

    test('báo lỗi khi hai component ra cùng tên widget', () {
      expect(
        () => gen([
          {'name': 'List Item', 'properties': <Object?>[]},
          {'name': 'ListItem', 'properties': <Object?>[]},
        ]),
        throwsFormatException,
      );
    });

    test('báo lỗi khi giá trị mặc định không có trong danh sách', () {
      expect(
        () => gen([
          {
            'name': 'Tag',
            'properties': [
              {
                'name': 'tone',
                'type': 'VARIANT',
                'default': 'info',
                'options': ['neutral'],
              },
            ],
          },
        ]),
        throwsFormatException,
      );
    });
  });
}
