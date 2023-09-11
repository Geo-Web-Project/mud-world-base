import { createClientComponents } from "./createClientComponents";
import { createSystemCalls } from "./createSystemCalls";
import { setupNetwork } from "./setupNetwork";
import { MUDChain } from "@latticexyz/common/chains";

export type SetupResult = Awaited<ReturnType<typeof setup>>;

export async function setup(networkParams: {
  chainId: Number;
  worlds: Partial<Record<string, { address: string; blockNumber?: number }>>;
  supportedChains: MUDChain[];
}) {
  const network = await setupNetwork(networkParams);
  const components = createClientComponents(network);
  const systemCalls = createSystemCalls(network, components);
  return {
    network,
    components,
    systemCalls,
  };
}
