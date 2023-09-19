import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["types/ethers-contracts/index.ts"],
  target: "esnext",
  format: ["esm"],
  dts: false,
  sourcemap: true,
  clean: true,
  minify: true,
});
