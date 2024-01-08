import React from "react";
import { MUDChain } from "@latticexyz/common/chains";
import { optimismGoerli } from "viem/chains";
import { useMUD, MUDProvider } from "./MUDContext";
import { syncWorld, SyncWorldResult } from "@geo-web/mud-world-base-setup";

const chainId = import.meta.env.VITE_CHAIN_ID || 31337;
const world = {
  address: "0x3904285496739BF5030d79C0CF259A569806F759",
  blockNumber: 17280426,
};
const mudChain = {
  ...optimismGoerli,
  rpcUrls: {
    ...optimismGoerli.rpcUrls,
    default: {
      http: optimismGoerli.rpcUrls.default.http,
      webSocket: [import.meta.env.VITE_PUBLIC_WS_RPC_URL],
    },
  },
} as MUDChain;

const View = () => {
  const { tables, useStore } = useMUD();

  const records = useStore((state: any) =>
    Object.values(state.getRecords(tables.NameCom))
  );

  return (
    <>
      {records.map((record: any) => {
        return record.value.value;
      })}
    </>
  );
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
        namespaces: ["320"],
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
