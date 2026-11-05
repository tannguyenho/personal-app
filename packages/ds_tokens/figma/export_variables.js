// Xuất toàn bộ Figma Variables ra JSON cho packages/ds_tokens/tokens.json
// (ADR-0008). Chạy bằng Plugin API: qua Figma MCP `use_figma`, hoặc dán vào
// một plugin riêng. Kết quả trả về là chuỗi JSON.
//
// Định dạng: { collections: [{ name, modes: [..], variables: [{ name, type,
// scopes, codeSyntax, values: { <mode>: "#RRGGBB" | number | string |
// { alias: "<tên token>" } } }] }] }
const toHex = (c) => {
  const h = (x) => Math.round(x * 255).toString(16).padStart(2, '0').toUpperCase();
  const a = c.a === undefined || c.a === 1 ? '' : h(c.a);
  return `#${h(c.r)}${h(c.g)}${h(c.b)}${a}`;
};

const collections = await figma.variables.getLocalVariableCollectionsAsync();
const out = { collections: [] };
for (const col of collections) {
  const modes = col.modes.map((m) => ({ id: m.modeId, name: m.name.toLowerCase() }));
  const variables = [];
  for (const id of col.variableIds) {
    const v = await figma.variables.getVariableByIdAsync(id);
    const values = {};
    for (const m of modes) {
      const raw = v.valuesByMode[m.id];
      if (raw && raw.type === 'VARIABLE_ALIAS') {
        const target = await figma.variables.getVariableByIdAsync(raw.id);
        values[m.name] = { alias: target.name };
      } else if (v.resolvedType === 'COLOR') {
        values[m.name] = toHex(raw);
      } else {
        values[m.name] = raw;
      }
    }
    variables.push({
      name: v.name,
      type: v.resolvedType,
      scopes: v.scopes,
      codeSyntax: v.codeSyntax,
      values,
    });
  }
  out.collections.push({ name: col.name, modes: modes.map((m) => m.name), variables });
}
return JSON.stringify(out, null, 4);
