import {
  createPublicClient,
  fallback,
  webSocket,
  http,
  Hex,
  ClientConfig,
  Chain,
} from "viem";
import { syncToRecs } from "@latticexyz/store-sync/recs";
import { transportObserver } from "@latticexyz/common";
import mudConfig from "@geo-web/mud-world-base-contracts/mud.config";
import { MUDChain } from "@latticexyz/common/chains";
import { createWorld } from "@latticexyz/recs";
import {
  createClientComponents,
  getTableIdsForNamespace,
} from "./createClientComponents";

export type SyncWorldResult = Awaited<ReturnType<typeof syncWorld>>;

export async function syncWorld(params: {
  chainId: Number;
  world: { address: string; blockNumber: number };
  mudChain: MUDChain;
  namespaces: string[];
}): Promise<any> {
  const clientOptions = {
    chain: params.mudChain as Chain,
    transport: transportObserver(fallback([webSocket(), http()])),
    pollingInterval: 1000,
  } as ClientConfig;

  const publicClient = createPublicClient(clientOptions);

  const world = createWorld();

  const { components } = await syncToRecs({
    world,
    config: mudConfig as any,
    address: params.world.address as Hex,
    publicClient,
    startBlock: BigInt(params.world.blockNumber),
    filters: params.namespaces
      .flatMap((namespace) => getTableIdsForNamespace(world, namespace))
      .map((tableId) => {
        return { tableId };
      }),
  });

  return {
    world,
    components: createClientComponents(
      { world, components },
      params.namespaces
    ),
    publicClient,
  };
}
