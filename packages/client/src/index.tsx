import ReactDOM from "react-dom/client";
import { App } from "./App";
import { MUDProvider, setup } from "@geo-web/mud-world-base-setup";
import mudConfig from "@geo-web/mud-world-base-contracts/mud.config";
import worldsJson from "@geo-web/mud-world-base-contracts/worlds.json";
import {
  MUDChain,
  latticeTestnet,
  mudFoundry,
} from "@latticexyz/common/chains";
import { optimismGoerli } from "viem/chains";

const rootElement = document.getElementById("react-root");
if (!rootElement) throw new Error("React root not found");
const root = ReactDOM.createRoot(rootElement);

const chainId = import.meta.env.VITE_CHAIN_ID || 31337;
const worlds = worldsJson as Partial<
  Record<string, { address: string; blockNumber?: number }>
>;
const supportedChains: MUDChain[] = [
  latticeTestnet,
  mudFoundry,
  {
    ...optimismGoerli,
    rpcUrls: {
      ...optimismGoerli.rpcUrls,
      default: {
        http: optimismGoerli.rpcUrls.default.http,
        webSocket: [import.meta.env.VITE_PUBLIC_WS_RPC_URL],
      },
    },
  } as MUDChain,
];

// TODO: figure out if we actually want this to be async or if we should render something else in the meantime
setup({ chainId, worlds, supportedChains }).then(async (result: any) => {
  root.render(
    <MUDProvider value={result}>
      <App />
    </MUDProvider>
  );

  // https://vitejs.dev/guide/env-and-mode.html
  // if (import.meta.env.DEV) {
  //   const { mount: mountDevTools } = await import("@latticexyz/dev-tools");
  //   mountDevTools({
  //     config: mudConfig,
  //     publicClient: result.network.publicClient,
  //     walletClient: result.network.walletClient,
  //     latestBlock$: result.network.latestBlock$,
  //     storedBlockLogs$: result.network.storedBlockLogs$,
  //     worldAddress: result.network.worldContract.address,
  //     worldAbi: result.network.worldContract.abi,
  //     write$: result.network.write$,
  //     recsWorld: result.network.world,
  //   });
  // }
});
