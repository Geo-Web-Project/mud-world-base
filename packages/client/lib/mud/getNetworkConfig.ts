import { getBurnerPrivateKey } from "@latticexyz/common";
import { supportedChains } from "./supportedChains";

export async function getNetworkConfig({
  chainId,
  worlds,
}: {
  chainId: Number;
  worlds: Partial<Record<string, { address: string; blockNumber?: number }>>;
}) {
  const chainIndex = supportedChains.findIndex((c) => c.id === chainId);
  const chain = supportedChains[chainIndex];
  if (!chain) {
    throw new Error(`Chain ${chainId} not found`);
  }

  const world = worlds[chain.id.toString()];
  const worldAddress = world?.address;
  if (!worldAddress) {
    throw new Error(
      `No world address found for chain ${chainId}. Did you run \`mud deploy\`?`
    );
  }

  const initialBlockNumber = world?.blockNumber ?? 0n;

  return {
    privateKey: getBurnerPrivateKey(),
    chainId,
    chain,
    faucetServiceUrl: chain.faucetUrl,
    worldAddress,
    initialBlockNumber,
  };
}
