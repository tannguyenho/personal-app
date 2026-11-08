// Plugin Codegen của Wakeup (#31, ADR-0008): chọn instance trong Dev Mode →
// snippet Flutter khớp lớp hợp đồng sinh từ cùng components.json /
// snowflakes.json. Chọn node khác có bind Variables màu → danh sách token.

import dsContract from '../../../packages/ds_tokens/components.json';
import snowflakeContract from '../../../packages/ds_tokens/snowflakes.json';
import { tokenFieldName } from './naming';
import {
  type Contracts,
  type ContractFile,
  type InstanceData,
  buildSnippet,
  resolveComponent,
  widgetPathFromDescription,
} from './snippet';

const contracts: Contracts = {
  ds: dsContract as ContractFile,
  snowflake: snowflakeContract as ContractFile,
};

type Language = CodegenResult['language'];

const MAX_DEPTH = 4;

async function readInstance(node: InstanceNode, depth: number): Promise<InstanceData | null> {
  const main = await node.getMainComponentAsync();
  if (!main) return null;
  const owner = main.parent && main.parent.type === 'COMPONENT_SET' ? main.parent : main;

  const properties: InstanceData['properties'] = {};
  for (const [key, prop] of Object.entries(node.componentProperties)) {
    properties[key] = { type: prop.type, value: prop.value };
  }

  // Instance con đang gắn vào từng property INSTANCE_SWAP.
  const swaps: InstanceData['swaps'] = {};
  if (depth < MAX_DEPTH) {
    for (const [key, prop] of Object.entries(node.componentProperties)) {
      if (prop.type !== 'INSTANCE_SWAP') continue;
      const child = node.findOne(
        (n) =>
          n.type === 'INSTANCE' &&
          n.componentPropertyReferences !== null &&
          n.componentPropertyReferences.mainComponent === key,
      ) as InstanceNode | null;
      swaps[key] = child && child.visible ? await readInstance(child, depth + 1) : null;
    }
  }

  return { componentName: owner.name, key: owner.key, properties, swaps };
}

async function ownerDescription(node: InstanceNode): Promise<string | undefined> {
  const main = await node.getMainComponentAsync();
  if (!main) return undefined;
  const owner = main.parent && main.parent.type === 'COMPONENT_SET' ? main.parent : main;
  return owner.description;
}

async function colorTokens(node: SceneNode): Promise<string[]> {
  const lines: string[] = [];
  const groups: Array<[string, unknown]> = [
    ['fill', 'fills' in node ? node.fills : undefined],
    ['stroke', 'strokes' in node ? node.strokes : undefined],
  ];
  for (const [label, paints] of groups) {
    if (!Array.isArray(paints)) continue;
    for (const paint of paints as Paint[]) {
      if (paint.type !== 'SOLID' || !paint.boundVariables || !paint.boundVariables.color) continue;
      const variable = await figma.variables.getVariableByIdAsync(paint.boundVariables.color.id);
      if (!variable || variable.resolvedType !== 'COLOR') continue;
      lines.push(`${label}: DsColors.${tokenFieldName(variable.name)} // ${variable.name}`);
    }
  }
  return lines;
}

figma.codegen.on('generate', async ({ node }) => {
  const prefs = figma.codegen.preferences.customSettings;
  const showDefaults = prefs.defaults === 'show';
  const language: Language = prefs.highlight === 'TYPESCRIPT' ? 'TYPESCRIPT' : 'PLAINTEXT';

  if (node.type === 'INSTANCE') {
    const data = await readInstance(node, 0);
    if (!data) {
      return [{ title: 'Flutter', language, code: '// Không đọc được main component.' }];
    }
    let code = buildSnippet(data, contracts, { showDefaults });
    const resolved = resolveComponent(contracts, data.key, data.componentName);
    const path = widgetPathFromDescription(
      (resolved && resolved.component.description) || (await ownerDescription(node)),
    );
    if (path) code = `// ${path}\n${code}`;
    return [{ title: 'Flutter', language, code }];
  }

  const tokens = await colorTokens(node);
  if (tokens.length > 0) {
    return [{ title: 'Token', language, code: tokens.join('\n') }];
  }
  return [
    {
      title: 'Flutter',
      language,
      code: '// Chọn một instance của DS component / Snowflake để xem snippet.',
    },
  ];
});
