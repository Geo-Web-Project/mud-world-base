import React from "react";
import { MUDChain } from "@latticexyz/common/chains";
import { optimismSepolia } from "viem/chains";
import { useMUD, MUDProvider } from "./MUDContext";
import { syncWorld, SyncWorldResult } from "@geo-web/mud-world-base-setup";
import { concatHex, stringToHex } from "viem";
import { resourceTypeIds } from "@latticexyz/common";

localStorage.debug = "*";

const chainId = import.meta.env.VITE_CHAIN_ID || 31337;
const world = {
  address: "0xed08ac7cbf41f2171e1d260418d24646b6e35519",
  blockNumber: 9445983,
};
const mudChain = {
  ...optimismSepolia,
  rpcUrls: {
    ...optimismSepolia.rpcUrls,
    default: {
      http: optimismSepolia.rpcUrls.default.http,
      webSocket: [import.meta.env.VITE_PUBLIC_WS_RPC_URL],
    },
  },
} as MUDChain;

const View = () => {
  const { tables, useStore } = useMUD();

  const typeId = resourceTypeIds.namespace;
  const namespaceId = concatHex([
    stringToHex(typeId, { size: 2 }),
    stringToHex(Number(2).toString(), { size: 14 }),
    stringToHex("", { size: 16 }),
  ]);

  const namespaceOwner = useStore((state: any) =>
    state.getRecord(tables.NamespaceOwner, { namespaceId })
  );

  console.log("namespaceOwner: " + JSON.stringify(namespaceOwner));

  return <></>;
};

export const App = () => {
  const [worldConfig, setWorldConfig] =
    React.useState<SyncWorldResult>(undefined);

  React.useEffect(() => {
    (async () => {
      const _worldConfig = await syncWorld({
        chainId,
        world,
        mudChain,
        namespaces: ["2"],
        indexerUrl: "https://mud-testnet.geoweb.network/trpc",
      });
      setWorldConfig(_worldConfig);
    })();
  }, []);

  if (!worldConfig) {
    return <></>;
  } else {
    return (
      <MUDProvider value={worldConfig}>
        <View />
      </MUDProvider>
    );
  }
};
