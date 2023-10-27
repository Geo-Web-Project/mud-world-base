import { defineComponent } from "@latticexyz/recs";
import { SyncWorldResult } from "./syncWorld";
import { stringToHex, concatHex, Hex } from "viem";
import { resourceTypeIds } from "@latticexyz/common";
import { World, Component } from "@latticexyz/recs";

export type ClientComponents = ReturnType<typeof createClientComponents>;

export function getTableIdForNamespace(
  namespace: string,
  tableName: string
): Hex {
  const typeId = resourceTypeIds.table;
  return concatHex([
    stringToHex(typeId, { size: 2 }),
    stringToHex(namespace, { size: 14 }),
    stringToHex(tableName.slice(0, 16), { size: 16 }),
  ]);
}

export function getTableIdsForNamespace(
  world: World,
  namespace: string
): Hex[] {
  const tableNames = Object.keys(world.components).filter(
    (key) => key.endsWith("Com") || key.endsWith("Augments")
  );
  return tableNames.map((tableName) => {
    return getTableIdForNamespace(namespace, tableName);
  });
}

export function getComponentsForNamespace(
  world: World,
  components: any,
  namespace: string
): Record<string, Component> {
  const tableNames = world.components
    .map((component) => component.metadata?.componentName as string | undefined)
    .filter(
      (key) =>
        key != undefined && (key.endsWith("Com") || key.endsWith("Augments"))
    ) as string[];
  return tableNames
    .map((tableName) => {
      return {
        [`${namespace}:${tableName}`]: defineComponent(
          world,
          components[tableName].schema,
          {
            id: getTableIdForNamespace(namespace, tableName),
          }
        ),
      };
    })
    .reduceRight((prev, cur) => {
      return {
        ...prev,
        ...cur,
      };
    }, {} as Record<string, Component>);
}

export function createClientComponents(
  { world, components }: SyncWorldResult,
  namespaces: string[]
): any {
  const namespaceComponents = namespaces
    .map((namespace) => {
      return getComponentsForNamespace(world, components, namespace);
    })
    .reduceRight((prev, cur) => {
      return {
        ...prev,
        ...cur,
      };
    }, {} as Record<string, Component>);

  console.log(namespaces);
  console.log(
    namespaces.map((namespace) => {
      return getComponentsForNamespace(world, components, namespace);
    })
  );

  return {
    ...components,
    PCOOwnership: defineComponent(world, components.PCOOwnership.schema, {
      id: concatHex([
        stringToHex(resourceTypeIds.table, { size: 2 }),
        stringToHex("world", { size: 14 }),
        stringToHex("PCOOwnership".slice(0, 16), { size: 16 }),
      ]),
    }),
    ...namespaceComponents,
  };
}
