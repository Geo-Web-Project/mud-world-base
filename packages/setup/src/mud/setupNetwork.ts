import {
  createPublicClient,
  fallback,
  webSocket,
  http,
  createWalletClient,
  Hex,
  encodePacked,
  ClientConfig,
  Chain,
  stringToHex,
  concatHex,
  keccak256,
  slice,
} from "viem";
import { createFaucetService } from "@latticexyz/services/faucet";
import { encodeEntity, syncToRecs } from "@latticexyz/store-sync/recs";
import { getNetworkConfig } from "./getNetworkConfig";
import { world } from "./world";
import { IWorld__factory } from "@geo-web/mud-world-base-contracts";
import {
  createBurnerAccount,
  getContract,
  transportObserver,
  ContractWrite,
  resourceIdToHex,
  resourceTypeIds,
  hexToResourceId,
} from "@latticexyz/common";
import { Subject, share } from "rxjs";
import mudConfig from "@geo-web/mud-world-base-contracts/mud.config";
import { MUDChain } from "@latticexyz/common/chains";
import { Component, Schema } from "@latticexyz/recs";

export type SetupNetworkResult = Awaited<ReturnType<typeof setupNetwork>>;

export function getTableIdForParcel(parcelId: bigint, tableName: string): Hex {
  const typeId = resourceTypeIds.namespace;
  return concatHex([
    stringToHex(typeId, { size: 2 }),
    slice(keccak256(encodePacked(["uint256"], [parcelId])), 1, 14),
    stringToHex(tableName.slice(0, 16), { size: 16 }),
  ]);
}

export function getTableIdsForParcel(mudConfig: any, parcelId: bigint): Hex[] {
  const tableNames = Object.keys(mudConfig.tables).filter((key) =>
    key.endsWith("Component")
  );
  return tableNames.map((tableName) => {
    return getTableIdForParcel(parcelId, tableName);
  });
}

export function getComponentForParcel<T extends Schema>(
  component: Component<T>,
  parcelId: bigint
): Component<T> {
  const resource = hexToResourceId(component.id as any);
  const tableId = getTableIdForParcel(parcelId, resource.name);
  return {...component, id: tableId};
}

export async function setupNetwork(networkParams: {
  chainId: Number;
  worlds: Partial<Record<string, { address: string; blockNumber?: number }>>;
  supportedChains: MUDChain[];
}): Promise<any> {
  const networkConfig = await getNetworkConfig(networkParams);

  const clientOptions = {
    chain: networkConfig.chain as Chain,
    transport: transportObserver(fallback([webSocket(), http()])),
    pollingInterval: 1000,
  } as const satisfies ClientConfig;

  const publicClient = createPublicClient(clientOptions);

  const burnerAccount = createBurnerAccount(networkConfig.privateKey as Hex);
  const burnerWalletClient = createWalletClient({
    ...clientOptions,
    account: burnerAccount,
  });

  const write$ = new Subject<ContractWrite>();
  const worldContract = getContract({
    address: networkConfig.worldAddress as Hex,
    abi: IWorld__factory.abi,
    publicClient,
    walletClient: burnerWalletClient,
    onWrite: (write) => write$.next(write),
  });

  const { components, latestBlock$, storedBlockLogs$, waitForTransaction } =
    await syncToRecs({
      world,
      config: mudConfig,
      address: networkConfig.worldAddress as Hex,
      publicClient,
      startBlock: BigInt(networkConfig.initialBlockNumber),
      // tableIds: getTableIdsForParcel(mudConfig, 320n),
    });

    // console.log(getTableIdsForParcel(mudConfig, 320n))

  // try {
  //   console.log("creating faucet client");
  //   const faucet = createFaucetClient({ url: "http://localhost:3002/trpc" });

  //   const drip = async () => {
  //     console.log("dripping");
  //     const tx = await faucet.drip.mutate({ address: burnerAccount.address });
  //     console.log("got drip", tx);
  //   };

  //   drip();
  //   setInterval(drip, 20_000);
  // } catch (e) {
  //   console.error(e);
  // }

  return {
    world,
    components,
    playerEntity: encodeEntity(
      { address: "address" },
      { address: burnerWalletClient.account.address }
    ),
    publicClient,
    walletClient: burnerWalletClient,
    latestBlock$,
    storedBlockLogs$,
    waitForTransaction,
    worldContract,
    write$: write$.asObservable().pipe(share()),
  };
}
