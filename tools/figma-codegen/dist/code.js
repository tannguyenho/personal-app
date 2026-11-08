"use strict";
(() => {
  // ../../packages/ds_tokens/components.json
  var components_default = {
    components: [
      {
        name: "Button",
        key: "a369e0b390d10fcc9a5f93727ff316a8554a8321",
        description: "Wakeup DsButton (Flutter: apps/desktop/lib/ds/ds_button.dart)",
        properties: [
          {
            name: "label#1:0",
            type: "TEXT",
            default: "Button"
          },
          {
            name: "disabled#1:5",
            type: "BOOLEAN",
            default: false
          },
          {
            name: "variant",
            type: "VARIANT",
            default: "primary",
            options: [
              "primary",
              "secondary"
            ]
          },
          {
            name: "size",
            type: "VARIANT",
            default: "md",
            options: [
              "md",
              "sm"
            ]
          }
        ]
      }
    ]
  };

  // ../../packages/ds_tokens/snowflakes.json
  var snowflakes_default = {
    components: []
  };

  // src/naming.ts
  var tierPrefix = { ds: "Ds", snowflake: "" };
  var dartReservedWords = /* @__PURE__ */ new Set([
    "assert",
    "break",
    "case",
    "catch",
    "class",
    "const",
    "continue",
    "default",
    "do",
    "else",
    "enum",
    "extends",
    "false",
    "final",
    "finally",
    "for",
    "if",
    "in",
    "is",
    "new",
    "null",
    "rethrow",
    "return",
    "super",
    "switch",
    "this",
    "throw",
    "true",
    "try",
    "var",
    "void",
    "while",
    "with"
  ]);
  var enumMemberNames = /* @__PURE__ */ new Set([
    "values",
    "index",
    "name",
    "hashCode",
    "runtimeType",
    "toString",
    "noSuchMethod",
    "figmaValue"
  ]);
  var widgetMemberNames = /* @__PURE__ */ new Set([
    "key",
    "build",
    "createElement",
    "hashCode",
    "runtimeType",
    "toString",
    "toStringShort",
    "noSuchMethod",
    "debugFillProperties"
  ]);
  var NamingError = class extends Error {
  };
  function words(input) {
    return input.split(/[^A-Za-z0-9]+/).filter((w) => w.length > 0).map((w) => w.length > 1 && w === w.toUpperCase() ? w.toLowerCase() : w);
  }
  var upperFirst = (s) => s[0].toUpperCase() + s.substring(1);
  var lowerFirst = (s) => s[0].toLowerCase() + s.substring(1);
  function lowerCamel(input) {
    const ws = words(input);
    if (ws.length === 0) throw new NamingError(`T\xEAn r\u1ED7ng sau khi \u0111\u1ED5i: ${input}`);
    return lowerFirst(ws[0]) + ws.slice(1).map(upperFirst).join("");
  }
  function stripPropertyId(figmaName) {
    return figmaName.replace(/#[^#]*$/, "");
  }
  function isExportedComponent(figmaName, tier = "ds") {
    const name = figmaName.trim();
    if (name.startsWith("--") || name.startsWith(".") || name.startsWith("_")) return false;
    if (tier === "snowflake" && /^Base\s*\//.test(name)) return false;
    return true;
  }
  function componentClassName(figmaName, tier = "ds") {
    const ws = words(figmaName);
    if (ws.length === 0) throw new NamingError(`T\xEAn component r\u1ED7ng: ${figmaName}`);
    const pascal = ws.map(upperFirst).join("");
    if (/^[0-9]/.test(pascal)) {
      throw new NamingError(`T\xEAn component kh\xF4ng \u0111\u01B0\u1EE3c b\u1EAFt \u0111\u1EA7u b\u1EB1ng s\u1ED1: ${figmaName}`);
    }
    return tierPrefix[tier] + pascal;
  }
  function propertyName(figmaName) {
    const name = lowerCamel(stripPropertyId(figmaName));
    if (/^[0-9]/.test(name) || dartReservedWords.has(name) || widgetMemberNames.has(name)) {
      throw new NamingError(`T\xEAn property kh\xF4ng d\xF9ng \u0111\u01B0\u1EE3c l\xE0m tham s\u1ED1 Dart: ${figmaName}`);
    }
    return name;
  }
  function enumTypeName(componentFigmaName, propertyFigmaName, tier = "ds") {
    return componentClassName(componentFigmaName, tier) + upperFirst(propertyName(propertyFigmaName));
  }
  function enumValueName(figmaValue) {
    let name = lowerCamel(figmaValue);
    if (/^[0-9]/.test(name)) name = `v${name}`;
    if (dartReservedWords.has(name) || enumMemberNames.has(name)) name = `${name}Value`;
    return name;
  }
  function isBooleanVariant(options) {
    const lower = new Set(options.map((o) => o.toLowerCase()));
    return options.length === 2 && lower.has("true") && lower.has("false");
  }
  function isInteractionState(propertyFigmaName) {
    return propertyName(propertyFigmaName) === "state";
  }
  function tokenFieldName(variableName) {
    const segments = variableName.split("/").slice(1);
    if (segments.length === 0) throw new NamingError(`T\xEAn token thi\u1EBFu nh\xF3m: ${variableName}`);
    let out = "";
    segments.forEach((segment, i) => {
      const s = segment.replace(/[^A-Za-z0-9]/g, "");
      if (s.length === 0) return;
      out += i === 0 ? lowerFirst(s) : upperFirst(s);
    });
    return /^[0-9]/.test(out) ? `v${out}` : out;
  }

  // src/snippet.ts
  function resolveComponent(contracts2, key, name) {
    const tiers = ["ds", "snowflake"];
    for (const tier of tiers) {
      const found = contracts2[tier].components.find((c) => c.key !== void 0 && c.key === key);
      if (found) return { tier, component: found };
    }
    for (const tier of tiers) {
      const found = contracts2[tier].components.find((c) => c.name === name);
      if (found) return { tier, component: found };
    }
    return null;
  }
  function dartString(s) {
    const escaped = s.replace(/\\/g, "\\\\").replace(/'/g, "\\'").replace(/\$/g, "\\$").replace(/\n/g, "\\n");
    return `'${escaped}'`;
  }
  var MAX_DEPTH = 4;
  function buildSnippet(data, contracts2, options, depth = 0) {
    var _a, _b;
    if (!isExportedComponent(data.componentName, "ds")) {
      return `// "${data.componentName}" l\xE0 element / component n\u1ED9i b\u1ED9, kh\xF4ng c\xF3 widget ri\xEAng.`;
    }
    const resolved = resolveComponent(contracts2, data.key, data.componentName);
    if (!resolved) {
      return `// "${data.componentName}" ch\u01B0a c\xF3 trong components.json / snowflakes.json.
// Ch\u1EA1y figma/export_components.js r\u1ED3i \`dart run tool/generate.dart\` (packages/ds_tokens).`;
    }
    const { tier, component } = resolved;
    if (!isExportedComponent(component.name, tier)) {
      return `// "${component.name}" l\xE0 component n\u1EC1n, kh\xF4ng c\xF3 widget ri\xEAng.`;
    }
    const cls = componentClassName(component.name, tier);
    const contractProps = /* @__PURE__ */ new Map();
    for (const p of (_a = component.properties) != null ? _a : []) contractProps.set(propertyName(p.name), p);
    const args = [];
    const warnings = [];
    for (const [figmaKey, prop] of Object.entries(data.properties)) {
      const name = propertyName(figmaKey);
      const contract = contractProps.get(name);
      if (!contract) {
        warnings.push(
          `// Figma c\xF3 property "${stripPropertyId(figmaKey)}" m\xE0 h\u1EE3p \u0111\u1ED3ng ch\u01B0a c\xF3: xu\u1EA5t l\u1EA1i components.json.`
        );
        continue;
      }
      switch (contract.type) {
        case "VARIANT": {
          if (isInteractionState(contract.name)) break;
          const value = String(prop.value);
          const isDefault = value === String(contract.default);
          if (isDefault && !options.showDefaults) break;
          if (isBooleanVariant((_b = contract.options) != null ? _b : [])) {
            args.push({ name, required: false, code: String(value.toLowerCase() === "true") });
          } else {
            const enumName = enumTypeName(component.name, contract.name, tier);
            args.push({ name, required: false, code: `${enumName}.${enumValueName(value)}` });
          }
          break;
        }
        case "BOOLEAN": {
          const value = prop.value === true;
          if (value === (contract.default === true) && !options.showDefaults) break;
          args.push({ name, required: false, code: String(value) });
          break;
        }
        case "TEXT":
          args.push({ name, required: true, code: dartString(String(prop.value)) });
          break;
        case "INSTANCE_SWAP": {
          const child = data.swaps[figmaKey];
          if (!child) break;
          const code = depth + 1 >= MAX_DEPTH ? `${shortName(child, contracts2)}(/* l\u1ED3ng qu\xE1 s\xE2u, xem ri\xEAng */)` : buildSnippet(child, contracts2, options, depth + 1);
          args.push({ name, required: false, code });
          break;
        }
        case "SLOT":
          warnings.push(`// ${name}: slot, \u0111i\u1EC1n widget con.`);
          break;
        default:
          warnings.push(`// Ki\u1EC3u property "${contract.type}" ch\u01B0a h\u1ED7 tr\u1EE3: ${name}.`);
      }
    }
    args.sort((a, b) => {
      if (a.required !== b.required) return a.required ? -1 : 1;
      return a.name < b.name ? -1 : a.name > b.name ? 1 : 0;
    });
    const lines = [];
    if (args.length === 0 && warnings.length === 0) {
      lines.push(`${cls}()`);
    } else {
      lines.push(`${cls}(`);
      for (const w of warnings) lines.push(`  ${w}`);
      for (const a of args) {
        const [first, ...rest] = a.code.split("\n");
        lines.push(`  ${a.name}: ${first}${rest.length === 0 ? "," : ""}`);
        rest.forEach((l, i) => lines.push(`  ${l}${i === rest.length - 1 ? "," : ""}`));
      }
      lines.push(")");
    }
    return lines.join("\n");
  }
  function shortName(data, contracts2) {
    const resolved = resolveComponent(contracts2, data.key, data.componentName);
    return resolved ? componentClassName(resolved.component.name, resolved.tier) : data.componentName;
  }
  function widgetPathFromDescription(description) {
    const match = /Flutter:\s*([^\s)]+\.dart)/.exec(description != null ? description : "");
    return match ? match[1] : null;
  }

  // src/code.ts
  var contracts = {
    ds: components_default,
    snowflake: snowflakes_default
  };
  var MAX_DEPTH2 = 4;
  async function readInstance(node, depth) {
    const main = await node.getMainComponentAsync();
    if (!main) return null;
    const owner = main.parent && main.parent.type === "COMPONENT_SET" ? main.parent : main;
    const properties = {};
    for (const [key, prop] of Object.entries(node.componentProperties)) {
      properties[key] = { type: prop.type, value: prop.value };
    }
    const swaps = {};
    if (depth < MAX_DEPTH2) {
      for (const [key, prop] of Object.entries(node.componentProperties)) {
        if (prop.type !== "INSTANCE_SWAP") continue;
        const child = node.findOne(
          (n) => n.type === "INSTANCE" && n.componentPropertyReferences !== null && n.componentPropertyReferences.mainComponent === key
        );
        swaps[key] = child && child.visible ? await readInstance(child, depth + 1) : null;
      }
    }
    return { componentName: owner.name, key: owner.key, properties, swaps };
  }
  async function ownerDescription(node) {
    const main = await node.getMainComponentAsync();
    if (!main) return void 0;
    const owner = main.parent && main.parent.type === "COMPONENT_SET" ? main.parent : main;
    return owner.description;
  }
  async function colorTokens(node) {
    const lines = [];
    const groups = [
      ["fill", "fills" in node ? node.fills : void 0],
      ["stroke", "strokes" in node ? node.strokes : void 0]
    ];
    for (const [label, paints] of groups) {
      if (!Array.isArray(paints)) continue;
      for (const paint of paints) {
        if (paint.type !== "SOLID" || !paint.boundVariables || !paint.boundVariables.color) continue;
        const variable = await figma.variables.getVariableByIdAsync(paint.boundVariables.color.id);
        if (!variable || variable.resolvedType !== "COLOR") continue;
        lines.push(`${label}: DsColors.${tokenFieldName(variable.name)} // ${variable.name}`);
      }
    }
    return lines;
  }
  figma.codegen.on("generate", async ({ node }) => {
    const prefs = figma.codegen.preferences.customSettings;
    const showDefaults = prefs.defaults === "show";
    const language = prefs.highlight === "TYPESCRIPT" ? "TYPESCRIPT" : "PLAINTEXT";
    if (node.type === "INSTANCE") {
      const data = await readInstance(node, 0);
      if (!data) {
        return [{ title: "Flutter", language, code: "// Kh\xF4ng \u0111\u1ECDc \u0111\u01B0\u1EE3c main component." }];
      }
      let code = buildSnippet(data, contracts, { showDefaults });
      const resolved = resolveComponent(contracts, data.key, data.componentName);
      const path = widgetPathFromDescription(
        resolved && resolved.component.description || await ownerDescription(node)
      );
      if (path) code = `// ${path}
${code}`;
      return [{ title: "Flutter", language, code }];
    }
    const tokens = await colorTokens(node);
    if (tokens.length > 0) {
      return [{ title: "Token", language, code: tokens.join("\n") }];
    }
    return [
      {
        title: "Flutter",
        language,
        code: "// Ch\u1ECDn m\u1ED9t instance c\u1EE7a DS component / Snowflake \u0111\u1EC3 xem snippet."
      }
    ];
  });
})();
