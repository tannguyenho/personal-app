import { describe, expect, it } from 'vitest';
import dsContract from '../../../packages/ds_tokens/components.json';
import {
  type ContractFile,
  type Contracts,
  type InstanceData,
  buildSnippet,
  widgetPathFromDescription,
} from '../src/snippet';

// Hợp đồng thật (components.json) + snowflake và icon mẫu cho test.
const contracts: Contracts = {
  ds: {
    components: [
      ...(dsContract as ContractFile).components,
      {
        name: 'Icon',
        key: 'icon-key',
        properties: [{ name: 'name', type: 'VARIANT', default: 'check', options: ['check', 'x'] }],
      },
      {
        name: 'Chip',
        key: 'chip-key',
        properties: [
          { name: 'state', type: 'VARIANT', default: 'default', options: ['default', 'hover'] },
          { name: 'selected', type: 'VARIANT', default: 'false', options: ['false', 'true'] },
          { name: 'leading#4:1', type: 'INSTANCE_SWAP', default: 'Icon' },
          { name: 'label#4:2', type: 'TEXT', default: 'Chip' },
        ],
      },
    ],
  },
  snowflake: {
    components: [
      {
        name: 'TaskCard',
        key: 'task-card-key',
        properties: [{ name: 'title#3:1', type: 'TEXT', default: 'Task' }],
      },
      { name: 'Base / TaskRow', key: 'task-row-key', properties: [] },
    ],
  },
};

const button = (overrides: Partial<InstanceData['properties']> = {}): InstanceData => ({
  componentName: 'Button',
  key: 'a369e0b390d10fcc9a5f93727ff316a8554a8321',
  properties: {
    'label#1:0': { type: 'TEXT', value: 'Lưu' },
    'disabled#1:5': { type: 'BOOLEAN', value: false },
    variant: { type: 'VARIANT', value: 'primary' },
    size: { type: 'VARIANT', value: 'md' },
    ...overrides,
  } as InstanceData['properties'],
  swaps: {},
});

const hide = { showDefaults: false };

describe('buildSnippet', () => {
  it('bỏ tham số đang bằng mặc định, TEXT luôn in', () => {
    expect(buildSnippet(button(), contracts, hide)).toBe(`DsButton(\n  label: 'Lưu',\n)`);
  });

  it('in tham số khác mặc định, đúng thứ tự constructor sinh ra', () => {
    const code = buildSnippet(
      button({
        variant: { type: 'VARIANT', value: 'secondary' },
        size: { type: 'VARIANT', value: 'sm' },
        'disabled#1:5': { type: 'BOOLEAN', value: true },
      }),
      contracts,
      hide,
    );
    expect(code).toBe(
      [
        'DsButton(',
        "  label: 'Lưu',",
        '  disabled: true,',
        '  size: DsButtonSize.sm,',
        '  variant: DsButtonVariant.secondary,',
        ')',
      ].join('\n'),
    );
  });

  it('showDefaults in cả giá trị mặc định', () => {
    const code = buildSnippet(button(), contracts, { showDefaults: true });
    expect(code).toContain('variant: DsButtonVariant.primary,');
    expect(code).toContain('disabled: false,');
  });

  it('escape chuỗi Dart', () => {
    const code = buildSnippet(
      button({ 'label#1:0': { type: 'TEXT', value: "It's $5" } }),
      contracts,
      hide,
    );
    expect(code).toContain("label: 'It\\'s \\$5',");
  });

  it('state bỏ qua, variant true/false thành bool, instance swap lồng', () => {
    const chip: InstanceData = {
      componentName: 'Chip',
      key: 'chip-key',
      properties: {
        state: { type: 'VARIANT', value: 'hover' },
        selected: { type: 'VARIANT', value: 'true' },
        'leading#4:1': { type: 'INSTANCE_SWAP', value: '1:23' },
        'label#4:2': { type: 'TEXT', value: 'Hôm nay' },
      },
      swaps: {
        'leading#4:1': {
          componentName: 'Icon',
          key: 'icon-key',
          properties: { name: { type: 'VARIANT', value: 'x' } },
          swaps: {},
        },
      },
    };
    expect(buildSnippet(chip, contracts, hide)).toBe(
      [
        'DsChip(',
        "  label: 'Hôm nay',",
        '  leading: DsIcon(',
        '    name: DsIconName.x,',
        '  ),',
        '  selected: true,',
        ')',
      ].join('\n'),
    );
  });

  it('snowflake giữ tên Figma, không tiền tố', () => {
    const card: InstanceData = {
      componentName: 'TaskCard',
      key: 'task-card-key',
      properties: { 'title#3:1': { type: 'TEXT', value: 'Viết báo cáo' } },
      swaps: {},
    };
    expect(buildSnippet(card, contracts, hide)).toBe(`TaskCard(\n  title: 'Viết báo cáo',\n)`);
  });

  it('tìm theo tên khi key khác (component được publish lại)', () => {
    const code = buildSnippet({ ...button(), key: 'khac' }, contracts, hide);
    expect(code.startsWith('DsButton(')).toBe(true);
  });

  it('báo khi component chưa có trong hợp đồng, element, Base', () => {
    const unknown = { componentName: 'Tooltip', key: 'x', properties: {}, swaps: {} };
    expect(buildSnippet(unknown, contracts, hide)).toContain('chưa có trong components.json');
    const element = { componentName: '--card / Price', key: 'y', properties: {}, swaps: {} };
    expect(buildSnippet(element, contracts, hide)).toContain('không có widget riêng');
    const base = { componentName: 'Base / TaskRow', key: 'task-row-key', properties: {}, swaps: {} };
    expect(buildSnippet(base, contracts, hide)).toContain('component nền');
  });

  it('báo khi Figma có property mà hợp đồng chưa có', () => {
    const code = buildSnippet(
      button({ 'iconLeading#9:9': { type: 'BOOLEAN', value: true } }),
      contracts,
      hide,
    );
    expect(code).toContain('// Figma có property "iconLeading" mà hợp đồng chưa có');
  });
});

describe('widgetPathFromDescription', () => {
  it('đọc đường dẫn file từ description', () => {
    expect(
      widgetPathFromDescription('Wakeup DsButton (Flutter: apps/desktop/lib/ds/ds_button.dart)'),
    ).toBe('apps/desktop/lib/ds/ds_button.dart');
    expect(widgetPathFromDescription('Không có')).toBeNull();
    expect(widgetPathFromDescription(undefined)).toBeNull();
  });
});
