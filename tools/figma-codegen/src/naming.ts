// Quy tắc đổi tên Figma → Dart, port 1-1 từ
// packages/ds_tokens/tool/naming.dart (bộ sinh hợp đồng) và fieldName trong
// packages/ds_tokens/tool/generator.dart (token). Ca chuẩn chung:
// packages/ds_tokens/test/naming_cases.json. Sửa quy tắc thì sửa cả hai phía.

export type ComponentTier = 'ds' | 'snowflake';

const tierPrefix: Record<ComponentTier, string> = { ds: 'Ds', snowflake: '' };

export const dartReservedWords = new Set([
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue',
  'default', 'do', 'else', 'enum', 'extends', 'false', 'final', 'finally',
  'for', 'if', 'in', 'is', 'new', 'null', 'rethrow', 'return', 'super',
  'switch', 'this', 'throw', 'true', 'try', 'var', 'void', 'while', 'with',
]);

export const enumMemberNames = new Set([
  'values', 'index', 'name', 'hashCode', 'runtimeType', 'toString',
  'noSuchMethod', 'figmaValue',
]);

export const widgetMemberNames = new Set([
  'key', 'build', 'createElement', 'hashCode', 'runtimeType', 'toString',
  'toStringShort', 'noSuchMethod', 'debugFillProperties',
]);

export class NamingError extends Error {}

function words(input: string): string[] {
  return input
    .split(/[^A-Za-z0-9]+/)
    .filter((w) => w.length > 0)
    .map((w) => (w.length > 1 && w === w.toUpperCase() ? w.toLowerCase() : w));
}

const upperFirst = (s: string) => s[0].toUpperCase() + s.substring(1);
const lowerFirst = (s: string) => s[0].toLowerCase() + s.substring(1);

function lowerCamel(input: string): string {
  const ws = words(input);
  if (ws.length === 0) throw new NamingError(`Tên rỗng sau khi đổi: ${input}`);
  return lowerFirst(ws[0]) + ws.slice(1).map(upperFirst).join('');
}

/** `label#12:3` → `label`. */
export function stripPropertyId(figmaName: string): string {
  return figmaName.replace(/#[^#]*$/, '');
}

/** Element `--...`, tên `.`/`_`, snowflake `Base / ...`: không có widget. */
export function isExportedComponent(figmaName: string, tier: ComponentTier = 'ds'): boolean {
  const name = figmaName.trim();
  if (name.startsWith('--') || name.startsWith('.') || name.startsWith('_')) return false;
  if (tier === 'snowflake' && /^Base\s*\//.test(name)) return false;
  return true;
}

/** `Button` → `DsButton`; snowflake `TaskCard` → `TaskCard`. */
export function componentClassName(figmaName: string, tier: ComponentTier = 'ds'): string {
  const ws = words(figmaName);
  if (ws.length === 0) throw new NamingError(`Tên component rỗng: ${figmaName}`);
  const pascal = ws.map(upperFirst).join('');
  if (/^[0-9]/.test(pascal)) {
    throw new NamingError(`Tên component không được bắt đầu bằng số: ${figmaName}`);
  }
  return tierPrefix[tier] + pascal;
}

/** `label#12:3` → `label`, `Show icon` → `showIcon`. */
export function propertyName(figmaName: string): string {
  const name = lowerCamel(stripPropertyId(figmaName));
  if (/^[0-9]/.test(name) || dartReservedWords.has(name) || widgetMemberNames.has(name)) {
    throw new NamingError(`Tên property không dùng được làm tham số Dart: ${figmaName}`);
  }
  return name;
}

/** `Button` + `variant` → `DsButtonVariant`. */
export function enumTypeName(
  componentFigmaName: string,
  propertyFigmaName: string,
  tier: ComponentTier = 'ds',
): string {
  return componentClassName(componentFigmaName, tier) + upperFirst(propertyName(propertyFigmaName));
}

/** `primary-solid` → `primarySolid`, `2xl` → `v2xl`, `default` → `defaultValue`. */
export function enumValueName(figmaValue: string): string {
  let name = lowerCamel(figmaValue);
  if (/^[0-9]/.test(name)) name = `v${name}`;
  if (dartReservedWords.has(name) || enumMemberNames.has(name)) name = `${name}Value`;
  return name;
}

export function isBooleanVariant(options: string[]): boolean {
  const lower = new Set(options.map((o) => o.toLowerCase()));
  return options.length === 2 && lower.has('true') && lower.has('false');
}

export function isInteractionState(propertyFigmaName: string): boolean {
  return propertyName(propertyFigmaName) === 'state';
}

/** Tên token → tên trường `DsColors`: `color/bg/primary` → `bgPrimary`. */
export function tokenFieldName(variableName: string): string {
  const segments = variableName.split('/').slice(1);
  if (segments.length === 0) throw new NamingError(`Tên token thiếu nhóm: ${variableName}`);
  let out = '';
  segments.forEach((segment, i) => {
    const s = segment.replace(/[^A-Za-z0-9]/g, '');
    if (s.length === 0) return;
    out += i === 0 ? lowerFirst(s) : upperFirst(s);
  });
  return /^[0-9]/.test(out) ? `v${out}` : out;
}
