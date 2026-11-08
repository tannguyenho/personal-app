// Xuất component (component set và component đứng riêng) ra JSON (ADR-0008):
// chạy trên file design system → packages/ds_tokens/components.json; chạy trên
// file ❄️ [Snowflake] Wakeup → packages/ds_tokens/snowflakes.json. Chạy bằng
// Plugin API: qua Figma MCP `use_figma`, hoặc dán vào một plugin riêng. Kết
// quả trả về là chuỗi JSON.
//
// Định dạng: { components: [{ name, key, description, properties: [{ name,
// type, default, options? }] }] }
// - name của property giữ nguyên như Figma (kể cả hậu tố `#id` của property
//   không phải variant) để plugin Codegen đối chiếu được với
//   instance.componentProperties.
// - VARIANT có `options` theo đúng thứ tự trong Figma.
// - INSTANCE_SWAP: `default` là tên component mặc định.
// Lọc element (`--...`), component ẩn (`.`/`_`) và `Base / ...` của snowflake
// là việc của bộ sinh Dart,
// script này xuất tất cả.
// Tải từng trang bằng page.loadAsync(): `use_figma` không cho gọi
// figma.loadAllPagesAsync().
const out = { components: [] };

for (const page of figma.root.children) {
  await page.loadAsync();
  const nodes = page.findAllWithCriteria({ types: ['COMPONENT_SET', 'COMPONENT'] });
  for (const node of nodes) {
    // Variant nằm trong component set đã được xuất qua set.
    if (node.type === 'COMPONENT' && node.parent && node.parent.type === 'COMPONENT_SET') continue;

    const properties = [];
    const defs = node.componentPropertyDefinitions;
    for (const name of Object.keys(defs)) {
      const def = defs[name];
      const prop = { name, type: def.type, default: def.defaultValue };
      if (def.type === 'VARIANT') prop.options = def.variantOptions;
      if (def.type === 'INSTANCE_SWAP') {
        const target = await figma.getNodeByIdAsync(def.defaultValue);
        prop.default = target ? target.name : null;
      }
      properties.push(prop);
    }

    out.components.push({
      name: node.name,
      key: node.key,
      description: node.description,
      properties,
    });
  }
}

out.components.sort((a, b) => a.name.localeCompare(b.name));
return JSON.stringify(out, null, 4);
