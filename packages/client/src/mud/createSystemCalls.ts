import { getComponentValue } from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { worldSend, txReduced$, singletonEntity }: SetupNetworkResult,
  { Name, Url, MediaObject }: ClientComponents
) {
  const setName = async (name: string) => {
    const tx = await worldSend("geoweb_ProfileSystem_setName", [name]);
    await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
    return getComponentValue(Name, singletonEntity);
  };

  const setUrl = async (url: string) => {
    const tx = await worldSend("geoweb_ProfileSystem_setUrl", [url]);
    await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
    return getComponentValue(Url, singletonEntity);
  };

  return {
    setName,
    setUrl,
  };
}
