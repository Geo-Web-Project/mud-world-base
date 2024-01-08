import {
  createPublicClient,
  fallback,
  webSocket,
  http,
  Hex,
  ClientConfig,
  Chain,
  stringToHex,
  concatHex,
} from "viem";
import { transportObserver } from "@latticexyz/common";
import mudConfig from "@geo-web/mud-world-base-contracts/mud.config";
import { MUDChain } from "@latticexyz/common/chains";
import { syncToZustand } from "@latticexyz/store-sync/zustand";
import { resourceTypeIds } from "@latticexyz/common";
import { resolveConfig } from "@latticexyz/store";

export type SyncWorldResult = Awaited<ReturnType<typeof syncWorld>>;

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

export function getTableIdsForNamespace(namespace: string): Hex[] {
  const tableNames = Object.keys(resolveConfig(mudConfig).tables).filter(
    (key) => key.endsWith("Com") || key.endsWith("Augments")
  );
  return tableNames.map((tableName) => {
    return getTableIdForNamespace(namespace, tableName);
  });
}

export function getTableForNamespace(namespace: string, table: any): any {
  return {
    ...table,
    namespace: namespace,
    tableId: getTableIdForNamespace(namespace, table.name),
  };
}

export function getTablesForNamespace(namespace: string): any[] {
  const tableNames = Object.keys(mudConfig.tables).filter(
    (key) => key.endsWith("Com") || key.endsWith("Augments")
  );
  return tableNames.map((tableName) => {
    const table = (resolveConfig(mudConfig).tables as any)[tableName];
    return getTableForNamespace(namespace, table);
  });
}

export async function syncWorld(params: {
  chainId: Number;
  world: { address: string; blockNumber: number };
  mudChain: MUDChain;
  namespaces: string[];
  indexerUrl: string;
}): Promise<any> {
  const clientOptions = {
    chain: params.mudChain as Chain,
    transport: transportObserver(fallback([webSocket(), http()])),
    pollingInterval: 1000,
  } as ClientConfig;

  const publicClient = createPublicClient(clientOptions);

  const extraTables = params.namespaces
    .map((namespace) => getTablesForNamespace(namespace))
    .reduceRight((prev, cur) => {
      let newTables = { ...prev };
      for (const table of cur) {
        newTables[table.name] = table;
      }
      return newTables;
    }, {} as any);

  const {
    tables,
    useStore,
    latestBlock$,
    storedBlockLogs$,
    waitForTransaction,
  } = await syncToZustand({
    config: mudConfig,
    address: params.world.address as Hex,
    publicClient,
    startBlock: BigInt(params.world.blockNumber),
    tables: extraTables,
    filters: params.namespaces
      .flatMap((namespace) => getTableIdsForNamespace(namespace))
      .map((tableId) => {
        return { tableId };
      }),
    indexerUrl,
  });

  return {
    tables,
    useStore,
    latestBlock$,
    storedBlockLogs$,
    waitForTransaction,
    publicClient,
  };
}
