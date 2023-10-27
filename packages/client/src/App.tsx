import React from "react";
import {
  getComponentForParcel,
  getTableIdForParcel,
  getTableIdsForParcel,
  syncWorld,
  SyncWorldResult,
} from "@geo-web/mud-world-base-setup";
import {
  Has,
  runQuery,
  getComponentValue,
  defineSystem,
} from "@latticexyz/recs";
import { MUDChain } from "@latticexyz/common/chains";
import { optimismGoerli } from "viem/chains";

const chainId = import.meta.env.VITE_CHAIN_ID || 31337;
const world = {
  address: "0x000a18F809049257BfE86009de80990375475f4c",
  blockNumber: 16469636,
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

export const App = () => {
  const [worldConfig, setWorldConfig] = React.useState<
    SyncWorldResult | undefined
  >(undefined);

  React.useEffect(() => {
    (async () => {
      const _worldConfig = await syncWorld({
        chainId,
        world,
        mudChain,
        namespaces: ["320"],
      });
      setWorldConfig(_worldConfig);
    })();
  }, []);

  React.useEffect(() => {
    if (!worldConfig) return;

    const { components } = worldConfig;

    console.log(components);

    //   setInterval(() => {
    //     const matchingEntities = runQuery([Has(Augments)]);
    //     const entities = Array.from(matchingEntities.values()).map((entity) =>
    //       getComponentValue(Augments, entity)
    //     );
    //     console.log(entities);
    //   }, 1000);
  }, [worldConfig]);

  return <></>;
};
