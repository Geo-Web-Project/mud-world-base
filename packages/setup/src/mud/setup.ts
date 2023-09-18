import { createClientComponents } from "./createClientComponents";
import { setupNetwork } from "./setupNetwork";
import { MUDChain } from "@latticexyz/common/chains";

export type SetupResult = Awaited<ReturnType<typeof setup>>;

export async function setup(networkParams: {
  chainId: Number;
  worlds: Partial<Record<string, { address: string; blockNumber?: number }>>;
  supportedChains: MUDChain[];
}): Promise<any> {
  const network = await setupNetwork(networkParams);
  const components = createClientComponents(network);
  return {
    network,
    components,
  };
}
