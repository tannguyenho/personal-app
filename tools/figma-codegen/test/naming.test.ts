// Ca chuẩn dùng chung với bộ sinh Dart: packages/ds_tokens/test/naming_cases.json.
import { describe, expect, it } from 'vitest';
import cases from '../../../packages/ds_tokens/test/naming_cases.json';
import {
  componentClassName,
  enumTypeName,
  enumValueName,
  isBooleanVariant,
  isExportedComponent,
  isInteractionState,
  propertyName,
  tokenFieldName,
} from '../src/naming';

type Case<I, O> = { in: I; out: O };

describe('ca tên chuẩn dùng chung với bộ sinh Dart', () => {
  it('componentClassName', () => {
    for (const c of cases.componentClassName as Case<string, string>[]) {
      expect(componentClassName(c.in), JSON.stringify(c)).toBe(c.out);
    }
  });
  it('isExportedComponent', () => {
    for (const c of cases.isExportedComponent as Case<string, boolean>[]) {
      expect(isExportedComponent(c.in), JSON.stringify(c)).toBe(c.out);
    }
  });
  it('snowflakeClassName', () => {
    for (const c of cases.snowflakeClassName as Case<string, string>[]) {
      expect(componentClassName(c.in, 'snowflake'), JSON.stringify(c)).toBe(c.out);
    }
  });
  it('isExportedSnowflake', () => {
    for (const c of cases.isExportedSnowflake as Case<string, boolean>[]) {
      expect(isExportedComponent(c.in, 'snowflake'), JSON.stringify(c)).toBe(c.out);
    }
  });
  it('propertyName', () => {
    for (const c of cases.propertyName as Case<string, string>[]) {
      expect(propertyName(c.in), JSON.stringify(c)).toBe(c.out);
    }
    for (const name of cases.propertyNameInvalid) {
      expect(() => propertyName(name), name).toThrow();
    }
  });
  it('enumTypeName', () => {
    for (const c of cases.enumTypeName) {
      expect(enumTypeName(c.component, c.property), JSON.stringify(c)).toBe(c.out);
    }
    for (const c of cases.snowflakeEnumTypeName) {
      expect(enumTypeName(c.component, c.property, 'snowflake'), JSON.stringify(c)).toBe(c.out);
    }
  });
  it('enumValueName', () => {
    for (const c of cases.enumValueName as Case<string, string>[]) {
      expect(enumValueName(c.in), JSON.stringify(c)).toBe(c.out);
    }
  });
  it('isBooleanVariant', () => {
    for (const c of cases.isBooleanVariant as Case<string[], boolean>[]) {
      expect(isBooleanVariant(c.in), JSON.stringify(c)).toBe(c.out);
    }
  });
  it('isInteractionState', () => {
    for (const c of cases.isInteractionState as Case<string, boolean>[]) {
      expect(isInteractionState(c.in), JSON.stringify(c)).toBe(c.out);
    }
  });
  it('tokenFieldName', () => {
    for (const c of cases.tokenFieldName as Case<string, string>[]) {
      expect(tokenFieldName(c.in), JSON.stringify(c)).toBe(c.out);
    }
  });
});
