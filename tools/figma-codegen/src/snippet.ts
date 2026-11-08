// Dựng snippet Dart từ dữ liệu instance đã đọc khỏi Figma. Hàm thuần, không
// gọi Figma API, để test được bằng vitest.
//
// Tham số và giá trị phải khớp đúng lớp `<Widget>Base` mà bộ sinh Dart
// (packages/ds_tokens/tool/components_generator.dart) tạo từ cùng hợp đồng.

import {
  type ComponentTier,
  componentClassName,
  enumTypeName,
  enumValueName,
  isBooleanVariant,
  isExportedComponent,
  isInteractionState,
  propertyName,
  stripPropertyId,
} from './naming';

/** Một property trong components.json / snowflakes.json. */
export interface ContractProperty {
  name: string;
  type: string;
  default?: unknown;
  options?: string[];
}

/** Một component trong components.json / snowflakes.json. */
export interface ContractComponent {
  name: string;
  key?: string;
  description?: string;
  properties?: ContractProperty[];
}

export interface ContractFile {
  components: ContractComponent[];
}

export interface Contracts {
  ds: ContractFile;
  snowflake: ContractFile;
}

/** Instance đọc từ Figma, chỉ giữ thứ cần cho snippet. */
export interface InstanceData {
  /** Tên component set (hoặc component đứng riêng) trong Figma. */
  componentName: string;
  /** Key của component set / component đứng riêng. */
  key: string;
  /** `instance.componentProperties`: tên property (kèm `#id`) → giá trị. */
  properties: Record<string, { type: string; value: string | boolean }>;
  /** Instance con đang gắn vào từng property INSTANCE_SWAP (null nếu đang ẩn). */
  swaps: Record<string, InstanceData | null>;
}

export interface SnippetOptions {
  /** In cả tham số đang bằng giá trị mặc định. */
  showDefaults: boolean;
}

interface Resolved {
  tier: ComponentTier;
  component: ContractComponent;
}

/** Tìm component trong hợp đồng: theo key trước, rồi theo tên. */
export function resolveComponent(
  contracts: Contracts,
  key: string,
  name: string,
): Resolved | null {
  const tiers: ComponentTier[] = ['ds', 'snowflake'];
  for (const tier of tiers) {
    const found = contracts[tier].components.find((c) => c.key !== undefined && c.key === key);
    if (found) return { tier, component: found };
  }
  for (const tier of tiers) {
    const found = contracts[tier].components.find((c) => c.name === name);
    if (found) return { tier, component: found };
  }
  return null;
}

function dartString(s: string): string {
  const escaped = s
    .replace(/\\/g, '\\\\')
    .replace(/'/g, "\\'")
    .replace(/\$/g, '\\$')
    .replace(/\n/g, '\\n');
  return `'${escaped}'`;
}

interface Arg {
  name: string;
  required: boolean;
  /** Dòng code, có thể nhiều dòng khi là widget lồng. */
  code: string;
}

const MAX_DEPTH = 4;

/** Snippet cho một instance. Kết quả không có dấu phẩy cuối. */
export function buildSnippet(
  data: InstanceData,
  contracts: Contracts,
  options: SnippetOptions,
  depth = 0,
): string {
  if (!isExportedComponent(data.componentName, 'ds')) {
    return `// "${data.componentName}" là element / component nội bộ, không có widget riêng.`;
  }
  const resolved = resolveComponent(contracts, data.key, data.componentName);
  if (!resolved) {
    return (
      `// "${data.componentName}" chưa có trong components.json / snowflakes.json.\n` +
      '// Chạy figma/export_components.js rồi `dart run tool/generate.dart` (packages/ds_tokens).'
    );
  }
  const { tier, component } = resolved;
  if (!isExportedComponent(component.name, tier)) {
    return `// "${component.name}" là component nền, không có widget riêng.`;
  }
  const cls = componentClassName(component.name, tier);

  const contractProps = new Map<string, ContractProperty>();
  for (const p of component.properties ?? []) contractProps.set(propertyName(p.name), p);

  const args: Arg[] = [];
  const warnings: string[] = [];

  for (const [figmaKey, prop] of Object.entries(data.properties)) {
    const name = propertyName(figmaKey);
    const contract = contractProps.get(name);
    if (!contract) {
      warnings.push(
        `// Figma có property "${stripPropertyId(figmaKey)}" mà hợp đồng chưa có: xuất lại components.json.`,
      );
      continue;
    }
    switch (contract.type) {
      case 'VARIANT': {
        if (isInteractionState(contract.name)) break;
        const value = String(prop.value);
        const isDefault = value === String(contract.default);
        if (isDefault && !options.showDefaults) break;
        if (isBooleanVariant(contract.options ?? [])) {
          args.push({ name, required: false, code: String(value.toLowerCase() === 'true') });
        } else {
          const enumName = enumTypeName(component.name, contract.name, tier);
          args.push({ name, required: false, code: `${enumName}.${enumValueName(value)}` });
        }
        break;
      }
      case 'BOOLEAN': {
        const value = prop.value === true;
        if (value === (contract.default === true) && !options.showDefaults) break;
        args.push({ name, required: false, code: String(value) });
        break;
      }
      case 'TEXT':
        args.push({ name, required: true, code: dartString(String(prop.value)) });
        break;
      case 'INSTANCE_SWAP': {
        const child = data.swaps[figmaKey];
        if (!child) break;
        const code =
          depth + 1 >= MAX_DEPTH
            ? `${shortName(child, contracts)}(/* lồng quá sâu, xem riêng */)`
            : buildSnippet(child, contracts, options, depth + 1);
        args.push({ name, required: false, code });
        break;
      }
      case 'SLOT':
        warnings.push(`// ${name}: slot, điền widget con.`);
        break;
      default:
        warnings.push(`// Kiểu property "${contract.type}" chưa hỗ trợ: ${name}.`);
    }
  }

  // Cùng thứ tự với constructor sinh ra: tham số required trước, rồi theo mã
  // ký tự (như String.compareTo của Dart, không theo locale).
  args.sort((a, b) => {
    if (a.required !== b.required) return a.required ? -1 : 1;
    return a.name < b.name ? -1 : a.name > b.name ? 1 : 0;
  });

  const lines: string[] = [];
  if (args.length === 0 && warnings.length === 0) {
    lines.push(`${cls}()`);
  } else {
    lines.push(`${cls}(`);
    for (const w of warnings) lines.push(`  ${w}`);
    for (const a of args) {
      const [first, ...rest] = a.code.split('\n');
      lines.push(`  ${a.name}: ${first}${rest.length === 0 ? ',' : ''}`);
      rest.forEach((l, i) => lines.push(`  ${l}${i === rest.length - 1 ? ',' : ''}`));
    }
    lines.push(')');
  }
  return lines.join('\n');
}

function shortName(data: InstanceData, contracts: Contracts): string {
  const resolved = resolveComponent(contracts, data.key, data.componentName);
  return resolved
    ? componentClassName(resolved.component.name, resolved.tier)
    : data.componentName;
}

/** Đường dẫn file widget ghi trong description: `(Flutter: apps/…/x.dart)`. */
export function widgetPathFromDescription(description: string | undefined): string | null {
  const match = /Flutter:\s*([^\s)]+\.dart)/.exec(description ?? '');
  return match ? match[1] : null;
}
