// Quy tắc đổi tên Figma → Dart cho lớp hợp đồng component (ADR-0008).
// Plugin Codegen (#31) phải cho cùng kết quả: ca chuẩn ở
// test/naming_cases.json, test Dart và test của plugin cùng đọc file đó.
// Không import Flutter để chạy được bằng `dart run`.

/// Từ khoá Dart không dùng được làm tên định danh.
const dartReservedWords = {
  'assert',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'default',
  'do',
  'else',
  'enum',
  'extends',
  'false',
  'final',
  'finally',
  'for',
  'if',
  'in',
  'is',
  'new',
  'null',
  'rethrow',
  'return',
  'super',
  'switch',
  'this',
  'throw',
  'true',
  'try',
  'var',
  'void',
  'while',
  'with',
};

/// Tên không dùng được làm giá trị enum: trùng thành viên sẵn có của enum
/// hoặc trường `figmaValue` mà bộ sinh thêm vào.
const enumMemberNames = {
  'values',
  'index',
  'name',
  'hashCode',
  'runtimeType',
  'toString',
  'noSuchMethod',
  'figmaValue',
};

/// Tên không dùng được làm tham số widget: trùng thành viên của Widget.
const widgetMemberNames = {
  'key',
  'build',
  'createElement',
  'hashCode',
  'runtimeType',
  'toString',
  'toStringShort',
  'noSuchMethod',
  'debugFillProperties',
};

/// Tách tên thành các từ theo ký tự không phải chữ / số.
/// Từ viết hoa toàn bộ (`URL`, `XL`) coi như một từ thường.
List<String> _words(String input) => input
    .split(RegExp('[^A-Za-z0-9]+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w.length > 1 && w == w.toUpperCase() ? w.toLowerCase() : w)
    .toList();

String _upperFirst(String s) => s[0].toUpperCase() + s.substring(1);
String _lowerFirst(String s) => s[0].toLowerCase() + s.substring(1);

String _lowerCamel(String input) {
  final words = _words(input);
  if (words.isEmpty) throw FormatException('Tên rỗng sau khi đổi', input);
  return _lowerFirst(words.first) + words.skip(1).map(_upperFirst).join();
}

/// Bỏ hậu tố id Figma gắn vào tên property không phải variant:
/// `label#12:3` → `label`.
String stripPropertyId(String figmaName) =>
    figmaName.replaceFirst(RegExp(r'#[^#]*$'), '');

/// Tầng của component (docs/design-system): DS component ở team
/// `0. [Design System] Multiverse`, Snowflake ở `[Library] Snowflake`.
enum ComponentTier {
  /// Widget có tiền tố `Ds`: `Button` → `DsButton`.
  ds('Ds'),

  /// Widget giữ đúng tên Figma, không tiền tố: `TaskCard` → `TaskCard`.
  snowflake('');

  const ComponentTier(this.prefix);

  /// Tiền tố tên widget.
  final String prefix;
}

/// Có sinh widget cho component này không.
/// - Element `--parent / Tên`: cấu phần nội bộ, không sinh.
/// - Tên bắt đầu bằng `.` hoặc `_`: Figma không publish, không sinh.
/// - Snowflake `Base / Tên`: component nền để dựng snowflake khác, không sinh.
bool isExportedComponent(
  String figmaName, [
  ComponentTier tier = ComponentTier.ds,
]) {
  final name = figmaName.trim();
  if (name.startsWith('--') || name.startsWith('.') || name.startsWith('_')) {
    return false;
  }
  if (tier == ComponentTier.snowflake && RegExp(r'^Base\s*/').hasMatch(name)) {
    return false;
  }
  return true;
}

/// Tên component → tên widget.
/// DS: `Button` → `DsButton`, `List Item` → `DsListItem`,
/// `Sheet / Bottom / Inset` → `DsSheetBottomInset`.
/// Snowflake: `TaskCard` → `TaskCard`, `Rollover Badge` → `RolloverBadge`.
String componentClassName(
  String figmaName, [
  ComponentTier tier = ComponentTier.ds,
]) {
  final words = _words(figmaName);
  if (words.isEmpty) throw FormatException('Tên component rỗng', figmaName);
  final pascal = words.map(_upperFirst).join();
  if (RegExp('^[0-9]').hasMatch(pascal)) {
    throw FormatException(
      'Tên component không được bắt đầu bằng số',
      figmaName,
    );
  }
  return '${tier.prefix}$pascal';
}

/// Tên property → tên tham số: `label#12:3` → `label`, `iconLeading` giữ
/// nguyên, `Show icon` → `showIcon`.
String propertyName(String figmaName) {
  final name = _lowerCamel(stripPropertyId(figmaName));
  if (RegExp('^[0-9]').hasMatch(name) ||
      dartReservedWords.contains(name) ||
      widgetMemberNames.contains(name)) {
    throw FormatException(
      'Tên property không dùng được làm tham số Dart, đổi tên trong Figma',
      figmaName,
    );
  }
  return name;
}

/// Tên enum của một variant property: `Button` + `type` → `DsButtonType`;
/// snowflake `TaskCard` + `state` → `TaskCardState`.
String enumTypeName(
  String componentFigmaName,
  String propertyFigmaName, [
  ComponentTier tier = ComponentTier.ds,
]) =>
    componentClassName(componentFigmaName, tier) +
    _upperFirst(propertyName(propertyFigmaName));

/// Giá trị variant (kebab-case) → giá trị enum: `primary-solid` →
/// `primarySolid`. Bắt đầu bằng số thêm `v` (`2xl` → `v2xl`); trùng từ khoá
/// hoặc thành viên enum thêm hậu tố `Value` (`default` → `defaultValue`).
String enumValueName(String figmaValue) {
  var name = _lowerCamel(figmaValue);
  if (RegExp('^[0-9]').hasMatch(name)) name = 'v$name';
  if (dartReservedWords.contains(name) || enumMemberNames.contains(name)) {
    name = '${name}Value';
  }
  return name;
}

/// Variant chỉ có hai giá trị `true` / `false` được sinh thành `bool`.
bool isBooleanVariant(List<String> options) {
  final lower = options.map((o) => o.toLowerCase()).toSet();
  return options.length == 2 && lower.containsAll(const {'true', 'false'});
}

/// Property `state` là trạng thái tương tác (hover, pressed…), Flutter tự quản
/// lý qua `WidgetState`. Vẫn sinh enum cho Widgetbook / golden test nhưng
/// không thành tham số widget.
bool isInteractionState(String propertyFigmaName) =>
    propertyName(propertyFigmaName) == 'state';
